using System.Text;

var lines = File.ReadAllLines("input.txt");

long totalJoltage = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
        continue;

    int maxJoltage = 0;
    bool found = false;

    for (int d1 = 9; d1 >= 1; d1--)
    {
        char c1 = (char)('0' + d1);
        int idx1 = line.IndexOf(c1);

        if (idx1 == -1)
            continue;

        for (int d2 = 9; d2 >= 1; d2--)
        {
            char c2 = (char)('0' + d2);
            int idx2 = line.LastIndexOf(c2);

            if (idx2 == -1)
                continue;

            if (idx1 < idx2)
            {
                maxJoltage = d1 * 10 + d2;
                found = true;
                break;
            }
        }
        if (found)
            break;
    }
    totalJoltage += maxJoltage;
}

Console.WriteLine($"Day 03 Part 1: {totalJoltage}");

long totalJoltagePart2 = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
        continue;

    StringBuilder result = new StringBuilder();
    int currentIndex = 0;
    int digitsNeeded = 12;

    for (int i = 0; i < digitsNeeded; i++)
    {
        int remainingNeeded = digitsNeeded - 1 - i;
        // The last index we can pick is such that we have enough chars left
        // Last valid index = Length - 1 - remainingNeeded
        int searchEndIndex = line.Length - 1 - remainingNeeded;

        int bestDigit = -1;
        int bestDigitIndex = -1;

        // Search for the largest digit in the valid range [currentIndex, searchEndIndex]
        for (int d = 9; d >= 1; d--)
        {
            char c = (char)('0' + d);
            int idx = line.IndexOf(c, currentIndex);

            if (idx != -1 && idx <= searchEndIndex)
            {
                bestDigit = d;
                bestDigitIndex = idx;
                break; // Found the largest possible digit
            }
        }

        if (bestDigit != -1)
        {
            result.Append(bestDigit);
            currentIndex = bestDigitIndex + 1;
        }
        else
        {
            // Should not happen given problem constraints if input is valid
            break;
        }
    }

    if (result.Length == 12)
    {
        totalJoltagePart2 += long.Parse(result.ToString());
    }
}

Console.WriteLine($"Day 03 Part 2: {totalJoltagePart2}");
