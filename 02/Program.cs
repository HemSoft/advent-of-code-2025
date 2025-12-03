var input = await File.ReadAllTextAsync("input.txt").ConfigureAwait(false);

// Parse ranges: "start-end" separated by commas
var ranges = input.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
    .Select(r =>
    {
        var parts = r.Split('-');
        return (Start: long.Parse(parts[0], System.Globalization.CultureInfo.InvariantCulture),
                End: long.Parse(parts[1], System.Globalization.CultureInfo.InvariantCulture));
    })
    .ToArray();

// Part 1: An "invalid" ID is one where the digits form a pattern repeated exactly twice.
// e.g., 55 = "5" + "5", 6464 = "64" + "64", 123123 = "123" + "123"
static bool IsInvalidPart1(long id)
{
    var s = id.ToString(System.Globalization.CultureInfo.InvariantCulture);
    if (s.Length % 2 != 0) return false;
    var half = s.Length / 2;
    return s[..half] == s[half..];
}

// Part 2: An "invalid" ID is one where the digits form a pattern repeated at least twice.
// e.g., 12341234 (2x), 123123123 (3x), 1212121212 (5x), 1111111 (7x)
static bool IsInvalidPart2(long id)
{
    var s = id.ToString(System.Globalization.CultureInfo.InvariantCulture);
    // Try all possible pattern lengths from 1 to s.Length/2
    for (var patternLen = 1; patternLen <= s.Length / 2; patternLen++)
    {
        if (s.Length % patternLen != 0) continue;
        var pattern = s[..patternLen];
        var repetitions = s.Length / patternLen;
        if (repetitions < 2) continue;

        var allMatch = true;
        for (var i = 1; i < repetitions && allMatch; i++)
        {
            if (s.Substring(i * patternLen, patternLen) != pattern)
                allMatch = false;
        }
        if (allMatch) return true;
    }
    return false;
}

// Part 1: Sum all invalid IDs (pattern repeated exactly twice).
long part1 = 0;
foreach (var (start, end) in ranges)
{
    for (var id = start; id <= end; id++)
    {
        if (IsInvalidPart1(id))
            part1 += id;
    }
}

Console.WriteLine($"Day 02 Part 1: {part1}");

// Part 2: Sum all invalid IDs (pattern repeated at least twice).
long part2 = 0;
foreach (var (start, end) in ranges)
{
    for (var id = start; id <= end; id++)
    {
        if (IsInvalidPart2(id))
            part2 += id;
    }
}

Console.WriteLine($"Day 02 Part 2: {part2}");
