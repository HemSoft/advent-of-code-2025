using System;
using System.IO;
using System.Linq;
using System.Numerics;

string inputPath = "input.txt";
if (!File.Exists(inputPath))
{
    Console.WriteLine("Error: input.txt not found.");
    return;
}

string input = File.ReadAllText(inputPath).Trim();
string[] ranges = input.Split(',', StringSplitOptions.RemoveEmptyEntries);

BigInteger totalSum = 0;

foreach (var range in ranges)
{
    var parts = range.Trim().Split('-');
    if (parts.Length != 2)
        continue;

    long start = long.Parse(parts[0]);
    long end = long.Parse(parts[1]);

    for (long i = start; i <= end; i++)
    {
        if (IsInvalidId(i))
        {
            totalSum += i;
        }
    }
}

Console.WriteLine($"Day 02 Part 1: {totalSum}");

BigInteger totalSumPart2 = 0;

foreach (var range in ranges)
{
    var parts = range.Trim().Split('-');
    if (parts.Length != 2)
        continue;

    long start = long.Parse(parts[0]);
    long end = long.Parse(parts[1]);

    for (long i = start; i <= end; i++)
    {
        if (IsInvalidIdPart2(i))
        {
            totalSumPart2 += i;
        }
    }
}

Console.WriteLine($"Day 02 Part 2: {totalSumPart2}");

static bool IsInvalidId(long id)
{
    string s = id.ToString();
    if (s.Length % 2 != 0)
        return false;

    int halfLen = s.Length / 2;
    ReadOnlySpan<char> span = s.AsSpan();
    return span.Slice(0, halfLen).SequenceEqual(span.Slice(halfLen));
}

static bool IsInvalidIdPart2(long id)
{
    string s = id.ToString();
    int len = s.Length;
    ReadOnlySpan<char> span = s.AsSpan();

    for (int patternLen = 1; patternLen <= len / 2; patternLen++)
    {
        if (len % patternLen != 0)
            continue;

        int repetitions = len / patternLen;
        // Must be repeated at least twice (which is guaranteed if patternLen <= len / 2)

        bool isMatch = true;
        ReadOnlySpan<char> pattern = span.Slice(0, patternLen);

        for (int i = 1; i < repetitions; i++)
        {
            if (!span.Slice(i * patternLen, patternLen).SequenceEqual(pattern))
            {
                isMatch = false;
                break;
            }
        }

        if (isMatch)
            return true;
    }

    return false;
}
