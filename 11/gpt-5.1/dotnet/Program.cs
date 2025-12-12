using System.Globalization;
using System.Collections.Generic;

static Dictionary<string, List<string>> ParseGraph(string input)
{
    var graph = new Dictionary<string, List<string>>();

    foreach (var line in input.Split('\n'))
    {
        var trimmed = line.Trim();
        if (string.IsNullOrEmpty(trimmed))
        {
            continue;
        }

        var parts = trimmed.Split(':', 2);
        if (parts.Length != 2)
        {
            continue;
        }

        var from = parts[0].Trim();
        var targetsPart = parts[1].Trim();

        var targets = new List<string>();
        if (!string.IsNullOrEmpty(targetsPart))
        {
            foreach (var t in targetsPart.Split(' ', StringSplitOptions.RemoveEmptyEntries))
            {
                targets.Add(t.Trim());
            }
        }

        graph[from] = targets;
    }

    return graph;
}

static long CountPaths(string node, string destination, Dictionary<string, List<string>> graph, Dictionary<string, long> memo)
{
    if (node == destination)
    {
        return 1L;
    }

    if (memo.TryGetValue(node, out var cached))
    {
        return cached;
    }

    long total = 0L;
    if (graph.TryGetValue(node, out var children))
    {
        foreach (var child in children)
        {
            total += CountPaths(child, destination, graph, memo);
        }
    }

    memo[node] = total;
    return total;
}

static long CountPathsWithRequiredNodes(
    string node,
    string destination,
    Dictionary<string, List<string>> graph,
    Dictionary<(string Node, int Mask), long> memo,
    int mask)
{
    var updatedMask = mask;
    if (node == "fft")
    {
        updatedMask |= 1;
    }
    else if (node == "dac")
    {
        updatedMask |= 2;
    }

    if (node == destination)
    {
        return (updatedMask & 0b11) == 0b11 ? 1L : 0L;
    }

    var key = (node, updatedMask);
    if (memo.TryGetValue(key, out var cached))
    {
        return cached;
    }

    long total = 0L;
    if (graph.TryGetValue(node, out var children))
    {
        foreach (var child in children)
        {
            total += CountPathsWithRequiredNodes(child, destination, graph, memo, updatedMask);
        }
    }

    memo[key] = total;
    return total;
}

static void RunExampleTest()
{
    const string example = """
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
""";

    var graph = ParseGraph(example.Trim());
    var memo = new Dictionary<string, long>();
    var paths = CountPaths("you", "out", graph, memo);

    if (paths != 5)
    {
        Console.Error.WriteLine($"Example test failed: expected 5, got {paths.ToString(CultureInfo.InvariantCulture)}");
    }
}

static void RunPart2ExampleTest()
{
    const string examplePart2 = """
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
""";

    var graph = ParseGraph(examplePart2.Trim());
    var memo = new Dictionary<(string Node, int Mask), long>();
    var paths = CountPathsWithRequiredNodes("svr", "out", graph, memo, 0);

    if (paths != 2)
    {
        Console.Error.WriteLine($"Part 2 example test failed: expected 2, got {paths.ToString(CultureInfo.InvariantCulture)}");
    }
}

RunExampleTest();
RunPart2ExampleTest();

var input = (await File.ReadAllTextAsync("input.txt")).Trim();
var graphReal = ParseGraph(input);
var memoReal = new Dictionary<string, long>();

long part1 = CountPaths("you", "out", graphReal, memoReal);
Console.WriteLine($"Day 11 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

var memoPart2 = new Dictionary<(string Node, int Mask), long>();
long part2 = CountPathsWithRequiredNodes("svr", "out", graphReal, memoPart2, 0);
Console.WriteLine($"Day 11 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
