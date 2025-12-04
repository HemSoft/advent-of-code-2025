using System.Globalization;

var lines = File.ReadAllLines("input.txt");

long totalJoltagePart1 = 0;
long totalJoltagePart2 = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
    {
        continue;
    }

    var span = line.AsSpan();

    // Part 1: original two-digit logic
    var maxJoltagePart1 = 0;
    var found = false;

    for (var d1 = 9; d1 >= 1 && !found; d1--)
    {
        var c1 = (char)('0' + d1);
        var idx1 = span.IndexOf(c1);
        if (idx1 < 0)
        {
            continue;
        }

        for (var d2 = 9; d2 >= 1; d2--)
        {
            var c2 = (char)('0' + d2);
            var idx2 = span.LastIndexOf(c2);
            if (idx2 < 0)
            {
                continue;
            }

            if (idx1 < idx2)
            {
                maxJoltagePart1 = d1 * 10 + d2;
                found = true;
                break;
            }
        }
    }

    totalJoltagePart1 += maxJoltagePart1;

    // Part 2: choose exactly 12 digits to form the largest possible number in order
    // Greedy from left to right: at each step choose the largest digit whose last
    // occurrence still leaves enough digits to reach length 12.
    var digits = line.Trim();
    const int targetLength = 12;
    var chosen = new char[targetLength];
    var start = 0;

    for (var pos = 0; pos < targetLength; pos++)
    {
        // We must leave (targetLength - pos - 1) characters after the chosen index.
        var remainingNeeded = targetLength - pos - 1;
        var bestDigit = '\0';
        var bestIndex = -1;

        for (var d = 9; d >= 0; d--)
        {
            var ch = (char)('0' + d);
            var lastIndex = digits.LastIndexOf(ch, digits.Length - 1, digits.Length - start);
            if (lastIndex < start)
            {
                continue;
            }

            if (lastIndex <= digits.Length - 1 - remainingNeeded)
            {
                bestDigit = ch;
                bestIndex = lastIndex;
                break;
            }
        }

        if (bestIndex == -1)
        {
            // Fallback: should not happen with valid inputs.
            bestDigit = digits[start];
            bestIndex = start;
        }

        chosen[pos] = bestDigit;
        start = bestIndex + 1;
    }

    long lineJoltagePart2 = 0;
    foreach (var ch in chosen)
    {
        lineJoltagePart2 = lineJoltagePart2 * 10 + (ch - '0');
    }

    totalJoltagePart2 += lineJoltagePart2;
}

Console.WriteLine($"Day 03 Part 1: {totalJoltagePart1.ToString(CultureInfo.InvariantCulture)}");
Console.WriteLine($"Day 03 Part 2: {totalJoltagePart2.ToString(CultureInfo.InvariantCulture)}");
