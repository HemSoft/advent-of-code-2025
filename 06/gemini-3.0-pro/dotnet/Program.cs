using System.Globalization;

var lines = File.ReadAllLines("input.txt");
if (lines.Length == 0) return;

int width = lines.Max(l => l.Length);
var paddedLines = lines.Select(l => l.PadRight(width)).ToArray();

var blocks = new List<(int start, int end)>();
int startCol = -1;

for (int col = 0; col < width; col++)
{
    bool isEmpty = true;
    for (int row = 0; row < paddedLines.Length; row++)
    {
        if (paddedLines[row][col] != ' ')
        {
            isEmpty = false;
            break;
        }
    }

    if (isEmpty)
    {
        if (startCol != -1)
        {
            blocks.Add((startCol, col - 1));
            startCol = -1;
        }
    }
    else
    {
        if (startCol == -1)
        {
            startCol = col;
        }
    }
}

if (startCol != -1)
{
    blocks.Add((startCol, width - 1));
}

long totalSumP1 = 0;
foreach (var block in blocks)
{
    totalSumP1 += ProcessBlock(paddedLines, block.start, block.end);
}
Console.WriteLine($"Day 06 Part 1: {totalSumP1.ToString(CultureInfo.InvariantCulture)}");

long totalSumP2 = 0;
foreach (var block in blocks)
{
    totalSumP2 += ProcessBlockPart2(paddedLines, block.start, block.end);
}
Console.WriteLine($"Day 06 Part 2: {totalSumP2.ToString(CultureInfo.InvariantCulture)}");

long ProcessBlock(string[] lines, int start, int end)
{
    var numbers = new List<long>();
    char op = ' ';

    foreach (var line in lines)
    {
        var segment = line.Substring(start, end - start + 1).Trim();
        if (string.IsNullOrWhiteSpace(segment))
            continue;

        if (segment == "+" || segment == "*")
        {
            op = segment[0];
        }
        else if (long.TryParse(segment, out long num))
        {
            numbers.Add(num);
        }
    }

    if (op == '+')
    {
        return numbers.Sum();
    }
    else if (op == '*')
    {
        return numbers.Aggregate(1L, (a, b) => a * b);
    }
    return 0;
}

long ProcessBlockPart2(string[] lines, int start, int end)
{
    var numbers = new List<long>();
    char? op = null;

    for (int col = start; col <= end; col++)
    {
        var chars = new List<char>();
        for (int row = 0; row < lines.Length; row++)
        {
            if (lines[row][col] != ' ')
            {
                chars.Add(lines[row][col]);
            }
        }

        if (chars.Count == 0)
            continue;

        char lastChar = chars[chars.Count - 1];
        if (lastChar == '+' || lastChar == '*')
        {
            op = lastChar;
            chars.RemoveAt(chars.Count - 1);
        }

        if (chars.Count > 0)
        {
            string numStr = new string(chars.ToArray());
            if (long.TryParse(numStr, out long num))
            {
                numbers.Add(num);
            }
        }
    }

    if (op == '+')
    {
        return numbers.Sum();
    }
    else if (op == '*')
    {
        return numbers.Aggregate(1L, (a, b) => a * b);
    }
    return 0;
}
