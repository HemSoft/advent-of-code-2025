using System.Globalization;

var input = File.ReadAllText("input.txt").Trim();
// Normalize line endings to \n just in case
input = input.Replace("\r\n", "\n");
var parts = input.Split("\n\n");
var rangesLines = parts[0].Split('\n', StringSplitOptions.RemoveEmptyEntries);
var idsLines = parts[1].Split('\n', StringSplitOptions.RemoveEmptyEntries);

var ranges = new List<(long Start, long End)>();
foreach (var line in rangesLines)
{
    var split = line.Trim().Split('-');
    ranges.Add((long.Parse(split[0]), long.Parse(split[1])));
}

long part1 = 0;
foreach (var line in idsLines)
{
    var id = long.Parse(line.Trim());
    bool isFresh = false;
    foreach (var range in ranges)
    {
        if (id >= range.Start && id <= range.End)
        {
            isFresh = true;
            break;
        }
    }
    if (isFresh)
    {
        part1++;
    }
}

Console.WriteLine($"Day 05 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
ranges.Sort((a, b) => a.Start.CompareTo(b.Start));
var mergedRanges = new List<(long Start, long End)>();

if (ranges.Count > 0)
{
    long currStart = ranges[0].Start;
    long currEnd = ranges[0].End;

    for (int i = 1; i < ranges.Count; i++)
    {
        long nextStart = ranges[i].Start;
        long nextEnd = ranges[i].End;

        if (nextStart <= currEnd + 1)
        {
            currEnd = Math.Max(currEnd, nextEnd);
        }
        else
        {
            mergedRanges.Add((currStart, currEnd));
            currStart = nextStart;
            currEnd = nextEnd;
        }
    }
    mergedRanges.Add((currStart, currEnd));
}

long part2 = 0;
foreach (var range in mergedRanges)
{
    part2 += (range.End - range.Start + 1);
}

Console.WriteLine($"Day 05 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
