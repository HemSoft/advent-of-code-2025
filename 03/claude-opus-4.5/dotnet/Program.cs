var lines = File.ReadAllLines("input.txt").Where(l => !string.IsNullOrWhiteSpace(l)).ToArray();

static int MaxJoltage(string line)
{
    int maxJoltage = 0;
    int n = line.Length;

    // Precompute suffix maximum (max digit from position i+1 to end)
    int[] suffixMax = new int[n];
    suffixMax[n - 1] = 0; // No digit after the last position
    for (int i = n - 2; i >= 0; i--)
    {
        suffixMax[i] = Math.Max(line[i + 1] - '0', suffixMax[i + 1]);
    }

    // For each position i, compute digit[i] * 10 + suffixMax[i]
    for (int i = 0; i < n - 1; i++)
    {
        int tensDigit = line[i] - '0';
        int unitsDigit = suffixMax[i];
        int joltage = tensDigit * 10 + unitsDigit;
        maxJoltage = Math.Max(maxJoltage, joltage);
    }

    return maxJoltage;
}

static long MaxJoltagePart2(string line, int k = 12)
{
    int n = line.Length;
    if (n < k)
        return 0;
    if (n == k)
    {
        return long.Parse(line);
    }

    // Greedy: pick k digits to form largest number
    // For each position, pick largest digit while ensuring enough remain
    char[] result = new char[k];
    int startIdx = 0;

    for (int i = 0; i < k; i++)
    {
        int remaining = k - i;
        int endIdx = n - remaining; // Last valid index to pick from

        char maxDigit = '0';
        int maxPos = startIdx;

        for (int j = startIdx; j <= endIdx; j++)
        {
            if (line[j] > maxDigit)
            {
                maxDigit = line[j];
                maxPos = j;
            }
        }

        result[i] = maxDigit;
        startIdx = maxPos + 1;
    }

    return long.Parse(new string(result));
}

// Part 1
long part1 = lines.Sum(line => (long)MaxJoltage(line));
Console.WriteLine($"Day 03 Part 1: {part1}");

// Part 2
long part2 = lines.Sum(line => MaxJoltagePart2(line));
Console.WriteLine($"Day 03 Part 2: {part2}");
