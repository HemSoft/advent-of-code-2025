using System.Globalization;

var lines = File.ReadAllLines("input.txt").Select(l => l.TrimEnd('\r')).ToList();

// Parse shapes and regions
var shapes = new Dictionary<int, List<(int r, int c)>>();
var regionLines = new List<string>();
int currentShapeId = -1;
List<string> currentShapeRows = [];

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
    {
        continue;
    }

    // Check if this is a shape definition (starts with digit and colon)
    if (line.Length > 0 && char.IsDigit(line[0]) && line.Contains(':') && !line.Contains('x'))
    {
        if (currentShapeId >= 0 && currentShapeRows.Count > 0)
        {
            shapes[currentShapeId] = ParseShape(currentShapeRows);
        }
        currentShapeId = int.Parse(line.Split(':')[0]);
        currentShapeRows = [];
    }
    else if (line.Contains('x') && line.Contains(':'))
    {
        // This is a region line
        if (currentShapeId >= 0 && currentShapeRows.Count > 0)
        {
            shapes[currentShapeId] = ParseShape(currentShapeRows);
            currentShapeId = -1;
            currentShapeRows = [];
        }
        regionLines.Add(line);
    }
    else if (currentShapeId >= 0 && (line.Contains('#') || line.Contains('.')))
    {
        currentShapeRows.Add(line);
    }
}

if (currentShapeId >= 0 && currentShapeRows.Count > 0)
{
    shapes[currentShapeId] = ParseShape(currentShapeRows);
}

// Get shape sizes
var shapeSizes = shapes.ToDictionary(kvp => kvp.Key, kvp => kvp.Value.Count);

int part1 = 0;

foreach (var regionLine in regionLines)
{
    var colonIdx = regionLine.IndexOf(':');
    var sizePart = regionLine[..colonIdx];
    var countsPart = regionLine[(colonIdx + 1)..].Trim();

    var sizeParts = sizePart.Split('x');
    int width = int.Parse(sizeParts[0]);
    int height = int.Parse(sizeParts[1]);

    var counts = countsPart.Split(' ', StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray();

    // Calculate total cells needed
    int totalCellsNeeded = 0;
    for (int shapeId = 0; shapeId < counts.Length; shapeId++)
    {
        totalCellsNeeded += counts[shapeId] * shapeSizes[shapeId];
    }

    int gridArea = width * height;

    // If total cells <= grid area, the presents can fit
    if (totalCellsNeeded <= gridArea)
    {
        part1++;
    }
}

Console.WriteLine($"Day 12 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
long part2 = 0;
Console.WriteLine($"Day 12 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");

static List<(int r, int c)> ParseShape(List<string> rows)
{
    var cells = new List<(int r, int c)>();
    for (int r = 0; r < rows.Count; r++)
    {
        for (int c = 0; c < rows[r].Length; c++)
        {
            if (rows[r][c] == '#')
            {
                cells.Add((r, c));
            }
        }
    }
    return cells;
}
