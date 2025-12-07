using System.Globalization;

var lines = File.ReadAllLines("input.txt");

// Part 1
long part1 = Solve(lines);
Console.WriteLine($"Day 06 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
long part2 = SolvePart2(lines);
Console.WriteLine($"Day 06 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");

static long Solve(string[] lines)
{
    if (lines.Length == 0)
    {
        return 0;
    }

    int height = lines.Length;
    int width = 0;
    for (int i = 0; i < height; i++)
    {
        if (lines[i].Length > width)
        {
            width = lines[i].Length;
        }
    }

    // Pad lines to equal width for safe column access
    var grid = new string[height];
    for (int i = 0; i < height; i++)
    {
        var line = lines[i].TrimEnd('\r', '\n');
        if (line.Length < width)
        {
            line = line.PadRight(width, ' ');
        }

        grid[i] = line;
    }

    // Identify contiguous column ranges that form individual problems.
    var ranges = new List<(int Start, int End)>();
    bool inBlock = false;
    int startCol = 0;

    for (int x = 0; x < width; x++)
    {
        bool allSpace = true;
        for (int y = 0; y < height; y++)
        {
            if (grid[y][x] != ' ')
            {
                allSpace = false;
                break;
            }
        }

        if (allSpace)
        {
            if (inBlock)
            {
                ranges.Add((startCol, x - 1));
                inBlock = false;
            }
        }
        else if (!inBlock)
        {
            inBlock = true;
            startCol = x;
        }
    }

    if (inBlock)
    {
        ranges.Add((startCol, width - 1));
    }

    long total = 0;

    foreach (var range in ranges)
    {
        int start = range.Start;
        int end = range.End;

        // Find operator in bottom row within this range
        char op = '\0';
        for (int x = start; x <= end; x++)
        {
            char c = grid[height - 1][x];
            if (c == '+' || c == '*')
            {
                op = c;
                break;
            }
        }

        if (op == '\0')
        {
            continue;
        }

        var nums = new List<long>();
        for (int y = 0; y < height - 1; y++)
        {
            string segment = grid[y].Substring(start, end - start + 1);
            string s = segment.Trim();
            if (s.Length == 0)
            {
                continue;
            }

            nums.Add(long.Parse(s, CultureInfo.InvariantCulture));
        }

        if (nums.Count == 0)
        {
            continue;
        }

        long value;
        if (op == '+')
        {
            value = 0;
            foreach (var n in nums)
            {
                value += n;
            }
        }
        else
        {
            value = 1;
            foreach (var n in nums)
            {
                value *= n;
            }
        }

        total += value;
    }

    return total;
}

static long SolvePart2(string[] lines)
{
    if (lines.Length == 0)
    {
        return 0;
    }

    int height = lines.Length;
    int width = 0;
    for (int i = 0; i < height; i++)
    {
        if (lines[i].Length > width)
        {
            width = lines[i].Length;
        }
    }

    var grid = new string[height];
    for (int i = 0; i < height; i++)
    {
        var line = lines[i].TrimEnd('\r', '\n');
        if (line.Length < width)
        {
            line = line.PadRight(width, ' ');
        }

        grid[i] = line;
    }

    var ranges = new List<(int Start, int End)>();
    bool inBlock = false;
    int startCol = 0;

    for (int x = 0; x < width; x++)
    {
        bool allSpace = true;
        for (int y = 0; y < height; y++)
        {
            if (grid[y][x] != ' ')
            {
                allSpace = false;
                break;
            }
        }

        if (allSpace)
        {
            if (inBlock)
            {
                ranges.Add((startCol, x - 1));
                inBlock = false;
            }
        }
        else if (!inBlock)
        {
            inBlock = true;
            startCol = x;
        }
    }

    if (inBlock)
    {
        ranges.Add((startCol, width - 1));
    }

    long total = 0;

    foreach (var range in ranges)
    {
        int start = range.Start;
        int end = range.End;

        char op = '\0';
        for (int x = start; x <= end; x++)
        {
            char c = grid[height - 1][x];
            if (c == '+' || c == '*')
            {
                op = c;
                break;
            }
        }

        if (op == '\0')
        {
            continue;
        }

        var nums = new List<long>();

        for (int x = end; x >= start; x--)
        {
            string digits = string.Empty;
            for (int y = 0; y < height - 1; y++)
            {
                char c = grid[y][x];
                if (c >= '0' && c <= '9')
                {
                    digits += c;
                }
            }

            if (digits.Length > 0)
            {
                nums.Add(long.Parse(digits, CultureInfo.InvariantCulture));
            }
        }

        if (nums.Count == 0)
        {
            continue;
        }

        long value;
        if (op == '+')
        {
            value = 0;
            foreach (var n in nums)
            {
                value += n;
            }
        }
        else
        {
            value = 1;
            foreach (var n in nums)
            {
                value *= n;
            }
        }

        total += value;
    }

    return total;
}
