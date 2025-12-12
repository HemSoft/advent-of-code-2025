using System.Globalization;

var lines = File.ReadAllLines("input.txt").Where(l => !string.IsNullOrWhiteSpace(l)).ToArray();

var graph = new Dictionary<string, List<string>>();

foreach (var line in lines)
{
    var parts = line.Split(':');
    var source = parts[0].Trim();
    var destinations = parts[1].Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries).ToList();
    graph[source] = destinations;
}

var memo1 = new Dictionary<string, long>();

long CountPaths(string current, string target)
{
    if (current == target)
        return 1;

    if (memo1.TryGetValue(current, out var cached))
        return cached;

    if (!graph.TryGetValue(current, out var neighbors))
        return 0;

    long count = 0;
    foreach (var neighbor in neighbors)
        count += CountPaths(neighbor, target);

    memo1[current] = count;
    return count;
}

var memo2 = new Dictionary<(string, bool, bool), long>();

long CountPathsWithRequired(string current, string target, bool visitedDac, bool visitedFft)
{
    if (current == "dac")
        visitedDac = true;
    if (current == "fft")
        visitedFft = true;

    if (current == target)
        return visitedDac && visitedFft ? 1 : 0;

    var key = (current, visitedDac, visitedFft);
    if (memo2.TryGetValue(key, out var cached))
        return cached;

    if (!graph.TryGetValue(current, out var neighbors))
        return 0;

    long count = 0;
    foreach (var neighbor in neighbors)
        count += CountPathsWithRequired(neighbor, target, visitedDac, visitedFft);

    memo2[key] = count;
    return count;
}

// Part 1
long part1 = CountPaths("you", "out");
Console.WriteLine($"Day 11 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
long part2 = CountPathsWithRequired("svr", "out", false, false);
Console.WriteLine($"Day 11 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
