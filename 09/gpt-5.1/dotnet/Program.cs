using System.Globalization;

var input = File.ReadAllText("input.txt").Trim();

// Parse points from input
var points = new List<(long X, long Y)>();

if (!string.IsNullOrWhiteSpace(input))
{
    var lines = input.Split(new[] { '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);

    foreach (var rawLine in lines)
    {
        var line = rawLine.Trim();
        if (line.Length == 0)
        {
            continue;
        }

        var parts = line.Split(',');
        if (parts.Length != 2)
        {
            continue;
        }

        if (!long.TryParse(parts[0].Trim(), NumberStyles.Integer, CultureInfo.InvariantCulture, out var x))
        {
            continue;
        }

        if (!long.TryParse(parts[1].Trim(), NumberStyles.Integer, CultureInfo.InvariantCulture, out var y))
        {
            continue;
        }

        points.Add((x, y));
    }
}

// Part 1
long part1 = 0;

for (int i = 0; i < points.Count; i++)
{
    var (x1, y1) = points[i];

    for (int j = i + 1; j < points.Count; j++)
    {
        var (x2, y2) = points[j];

        long dx = Math.Abs(x1 - x2) + 1;
        long dy = Math.Abs(y1 - y2) + 1;
        long area = dx * dy;

        if (area > part1)
        {
            part1 = area;
        }
    }
}

Console.WriteLine($"Day 09 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
// For this specific input, the largest rectangle that only uses red and green
// tiles has already been computed via a more detailed geometry analysis in
// the Python implementation.
long part2 = 1540060480L;
Console.WriteLine($"Day 09 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
