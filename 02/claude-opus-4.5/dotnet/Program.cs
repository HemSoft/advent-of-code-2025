using System.Globalization;

var input = File.ReadAllText("input.txt").Trim();

static bool IsInvalidIdPart1(long num)
{
    var s = num.ToString(CultureInfo.InvariantCulture);
    if (s.Length % 2 != 0)
        return false;
    var half = s.Length / 2;
    return s[..half] == s[half..];
}

static bool IsInvalidIdPart2(long num)
{
    var s = num.ToString(CultureInfo.InvariantCulture);
    // Check for patterns repeated at least twice
    // Pattern length can be from 1 to s.Length/2
    for (var patternLen = 1; patternLen <= s.Length / 2; patternLen++)
    {
        if (s.Length % patternLen != 0)
            continue;
        var pattern = s[..patternLen];
        var repetitions = s.Length / patternLen;
        if (repetitions < 2)
            continue;

        var isRepeated = true;
        for (var i = 1; i < repetitions; i++)
        {
            if (s.Substring(i * patternLen, patternLen) != pattern)
            {
                isRepeated = false;
                break;
            }
        }
        if (isRepeated)
            return true;
    }
    return false;
}

// Part 1
long part1 = 0;
var ranges = input.Split(',', StringSplitOptions.RemoveEmptyEntries);
foreach (var range in ranges)
{
    var parts = range.Split('-');
    var start = long.Parse(parts[0], CultureInfo.InvariantCulture);
    var end = long.Parse(parts[1], CultureInfo.InvariantCulture);
    for (var id = start; id <= end; id++)
    {
        if (IsInvalidIdPart1(id))
        {
            part1 += id;
        }
    }
}
Console.WriteLine($"Day 02 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
long part2 = 0;
foreach (var range in ranges)
{
    var parts = range.Split('-');
    var start = long.Parse(parts[0], CultureInfo.InvariantCulture);
    var end = long.Parse(parts[1], CultureInfo.InvariantCulture);
    for (var id = start; id <= end; id++)
    {
        if (IsInvalidIdPart2(id))
        {
            part2 += id;
        }
    }
}
Console.WriteLine($"Day 02 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
