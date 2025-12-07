using System.Globalization;

var input = File.ReadAllText("input.txt").Trim();
var sections = input.Split(["\n\n", "\r\n\r\n"], StringSplitOptions.None);

var ranges = sections[0]
    .Split(['\n', '\r'], StringSplitOptions.RemoveEmptyEntries)
    .Select(line =>
    {
        var parts = line.Split('-');
        return (Start: long.Parse(parts[0]), End: long.Parse(parts[1]));
    })
    .ToList();

var ingredients = sections[1]
    .Split(['\n', '\r'], StringSplitOptions.RemoveEmptyEntries)
    .Select(long.Parse)
    .ToList();

// Part 1
long part1 = ingredients.Count(id => ranges.Any(r => id >= r.Start && id <= r.End));
Console.WriteLine($"Day 05 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2: Merge overlapping ranges and count total unique IDs
var sorted = ranges.OrderBy(r => r.Start).ThenBy(r => r.End).ToList();
var merged = new List<(long Start, long End)>();

foreach (var range in sorted)
{
    if (merged.Count == 0 || merged[^1].End < range.Start - 1)
    {
        merged.Add(range);
    }
    else
    {
        var last = merged[^1];
        merged[^1] = (last.Start, Math.Max(last.End, range.End));
    }
}

long part2 = merged.Sum(r => r.End - r.Start + 1);
Console.WriteLine($"Day 05 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
