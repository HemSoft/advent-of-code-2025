using System.Globalization;

var lines = File.ReadAllLines("input.txt");

int position = 50;
int zeroCount = 0;

foreach (var raw in lines)
{
    var line = raw.Trim();
    if (line.Length == 0)
    {
        continue;
    }

    char dir = line[0];
    if (!int.TryParse(line.AsSpan(1), NumberStyles.Integer, CultureInfo.InvariantCulture, out var distance))
    {
        continue;
    }

    distance %= 100;

    if (dir == 'R')
    {
        position = (position + distance) % 100;
    }
    else if (dir == 'L')
    {
        position = (position - distance) % 100;
        if (position < 0)
        {
            position += 100;
        }
    }

    if (position == 0)
    {
        zeroCount++;
    }
}

long part1 = zeroCount;
Console.WriteLine($"Day 01 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2 (not implemented yet)
long part2 = 0;
Console.WriteLine($"Day 01 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
