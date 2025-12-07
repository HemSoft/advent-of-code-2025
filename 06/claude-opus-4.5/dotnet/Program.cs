using System.Globalization;

var lines = File.ReadAllLines("input.txt");

// Find the max width and pad all lines to that width
int maxWidth = lines.Max(l => l.Length);
var grid = lines.Select(l => l.PadRight(maxWidth)).ToArray();
int rows = grid.Length;
int cols = maxWidth;

// The last row contains operators
string operatorRow = grid[rows - 1];

// Find column groups (problems) by identifying separator columns (all spaces)
var problems = new List<(List<long> numbers, char op)>();
int colStart = 0;

while (colStart < cols)
{
    // Skip separator columns (columns that are all spaces in data rows)
    while (colStart < cols && IsSeparatorColumn(grid, colStart, rows - 1))
        colStart++;

    if (colStart >= cols)
        break;

    // Find the end of this problem (next separator column)
    int colEnd = colStart;
    while (colEnd < cols && !IsSeparatorColumn(grid, colEnd, rows - 1))
        colEnd++;

    // Extract numbers and operator from this problem
    var numbers = new List<long>();
    char op = ' ';

    for (int r = 0; r < rows - 1; r++)
    {
        string segment = grid[r].Substring(colStart, colEnd - colStart).Trim();
        if (!string.IsNullOrEmpty(segment) && long.TryParse(segment, out long num))
            numbers.Add(num);
    }

    // Get operator from the operator row within this column range
    string opSegment = operatorRow.Substring(colStart, colEnd - colStart).Trim();
    if (opSegment.Length > 0)
        op = opSegment[0];

    if (numbers.Count > 0 && (op == '+' || op == '*'))
        problems.Add((numbers, op));

    colStart = colEnd;
}

// Calculate the grand total
long part1 = 0;
foreach (var (numbers, op) in problems)
{
    long result = numbers[0];
    for (int i = 1; i < numbers.Count; i++)
    {
        if (op == '+')
            result += numbers[i];
        else
            result *= numbers[i];
    }
    part1 += result;
}

Console.WriteLine($"Day 06 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2: Read columns right-to-left, digits top-to-bottom form numbers
long part2 = 0;
colStart = 0;
while (colStart < cols)
{
    while (colStart < cols && IsSeparatorColumn(grid, colStart, rows - 1))
        colStart++;

    if (colStart >= cols)
        break;

    int colEnd = colStart;
    while (colEnd < cols && !IsSeparatorColumn(grid, colEnd, rows - 1))
        colEnd++;

    // Get operator
    string opSegment = operatorRow.Substring(colStart, colEnd - colStart).Trim();
    char op = opSegment.Length > 0 ? opSegment[0] : ' ';

    // Read columns right-to-left within this problem block
    var numbers2 = new List<long>();
    for (int c = colEnd - 1; c >= colStart; c--)
    {
        var digits = new List<char>();
        for (int r = 0; r < rows - 1; r++)
        {
            char ch = grid[r][c];
            if (char.IsDigit(ch))
                digits.Add(ch);
        }
        if (digits.Count > 0)
        {
            long num = long.Parse(new string(digits.ToArray()));
            numbers2.Add(num);
        }
    }

    if (numbers2.Count > 0 && (op == '+' || op == '*'))
    {
        long result = numbers2[0];
        for (int i = 1; i < numbers2.Count; i++)
        {
            if (op == '+')
                result += numbers2[i];
            else
                result *= numbers2[i];
        }
        part2 += result;
    }

    colStart = colEnd;
}
Console.WriteLine($"Day 06 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");

static bool IsSeparatorColumn(string[] grid, int col, int dataRowCount)
{
    for (int r = 0; r < dataRowCount; r++)
    {
        if (col < grid[r].Length && grid[r][col] != ' ')
            return false;
    }
    return true;
}
