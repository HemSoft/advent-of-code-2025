using System.Globalization;

var input = File.ReadAllText("input.txt").TrimEnd();
var lines = input.Split(['\n', '\r'], StringSplitOptions.RemoveEmptyEntries);

// Parse fresh ranges and available ingredient IDs
var ranges = new List<(long start, long end)>();
var availableIds = new List<long>();

var index = 0;
while (index < lines.Length && lines[index].IndexOf('-') >= 0)
{
	var line = lines[index].Trim();
	if (line.Length == 0)
	{
		index++;
		continue;
	}
	var parts = line.Split('-', 2, StringSplitOptions.TrimEntries);
	if (parts.Length == 2 &&
		long.TryParse(parts[0], NumberStyles.Integer, CultureInfo.InvariantCulture, out var start) &&
		long.TryParse(parts[1], NumberStyles.Integer, CultureInfo.InvariantCulture, out var end))
	{
		if (end < start)
		{
			(start, end) = (end, start);
		}
		ranges.Add((start, end));
	}
	index++;
}

// Remaining non-empty lines are available ingredient IDs
for (; index < lines.Length; index++)
{
	var line = lines[index].Trim();
	if (line.Length == 0)
	{
		continue;
	}
	if (long.TryParse(line, NumberStyles.Integer, CultureInfo.InvariantCulture, out var id))
	{
		availableIds.Add(id);
	}
}

// Merge overlapping/adjacent ranges
ranges.Sort((a, b) =>
{
	var cmp = a.start.CompareTo(b.start);
	return cmp != 0 ? cmp : a.end.CompareTo(b.end);
});

var merged = new List<(long start, long end)>();
foreach (var range in ranges)
{
	if (merged.Count == 0)
	{
		merged.Add(range);
		continue;
	}

	var last = merged[^1];
	if (range.start <= last.end + 1)
	{
		var newEnd = range.end > last.end ? range.end : last.end;
		merged[^1] = (last.start, newEnd);
	}
	else
	{
		merged.Add(range);
	}
}

// Part 1: count available IDs that fall within any merged range
long part1 = 0;
foreach (var id in availableIds)
{
	foreach (var (start, end) in merged)
	{
		if (id < start)
		{
			break;
		}
		if (id <= end)
		{
			part1++;
			break;
		}
	}
}

Console.WriteLine($"Day 05 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2: count all unique IDs covered by any merged range
long part2 = 0;
foreach (var (start, end) in merged)
{
	part2 += (end - start + 1);
}

Console.WriteLine($"Day 05 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");