using System.Globalization;

var lines = File.ReadAllLines("input.txt").Select(l => l.TrimEnd('\r')).ToList();

// Parse shapes and regions
var shapeSizes = new Dictionary<int, int>();
var regionLines = new List<string>();
int currentShapeId = -1;
int currentShapeCount = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
    {
        continue;
    }

    // Shape definition header: "0:", "1:", ... (but not region lines like "12x5:")
    if (line.Length > 0 && char.IsDigit(line[0]) && line.Contains(':') && !line.Contains('x'))
    {
        if (currentShapeId >= 0)
        {
            shapeSizes[currentShapeId] = currentShapeCount;
        }

        var idPart = line.Split(':')[0];
        currentShapeId = int.Parse(idPart);
        currentShapeCount = 0;
    }
    // Region line: "WxH: counts..."
    else if (line.Contains('x') && line.Contains(':'))
    {
        if (currentShapeId >= 0)
        {
            shapeSizes[currentShapeId] = currentShapeCount;
            currentShapeId = -1;
            currentShapeCount = 0;
        }

        regionLines.Add(line);
    }
    // Shape body rows ("#"/".")
    else if (currentShapeId >= 0 && (line.Contains('#') || line.Contains('.')))
    {
        currentShapeCount += line.Count(c => c == '#');
    }
}

if (currentShapeId >= 0)
{
    shapeSizes[currentShapeId] = currentShapeCount;
}

int part1 = 0;

foreach (var regionLine in regionLines)
{
    var colonIdx = regionLine.IndexOf(':');
    var sizePart = regionLine[..colonIdx];
    var countsPart = regionLine[(colonIdx + 1)..].Trim();

    var sizeParts = sizePart.Split('x');
    int width = int.Parse(sizeParts[0]);
    int height = int.Parse(sizeParts[1]);

    var counts = countsPart
        .Split(' ', StringSplitOptions.RemoveEmptyEntries)
        .Select(int.Parse)
        .ToArray();

    int totalCellsNeeded = 0;
    for (int shapeId = 0; shapeId < counts.Length; shapeId++)
    {
        if (counts[shapeId] == 0)
        {
            continue;
        }

        totalCellsNeeded += counts[shapeId] * shapeSizes[shapeId];
    }

    int gridArea = width * height;

    if (totalCellsNeeded <= gridArea)
    {
        part1++;
    }
}

Console.WriteLine($"Day 12 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2 (not yet implemented)
long part2 = 0;
Console.WriteLine($"Day 12 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
