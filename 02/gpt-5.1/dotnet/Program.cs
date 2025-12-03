using System.Globalization;
using System.Numerics;

namespace Day02;

internal static class Program
{
    private static void Main()
    {
        var input = File.ReadAllText("input.txt").Trim();

        long part1 = SumInvalidIdsPart1(input);
        Console.WriteLine($"Day 02 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

        long part2 = SumInvalidIdsPart2(input);
        Console.WriteLine($"Day 02 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
    }

    private static long SumInvalidIdsPart1(string input)
    {
        long sum = 0;
        var ranges = input.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

        foreach (var range in ranges)
        {
            var parts = range.Split('-', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            if (parts.Length != 2)
            {
                continue;
            }

            if (!long.TryParse(parts[0], NumberStyles.None, CultureInfo.InvariantCulture, out var start))
            {
                continue;
            }

            if (!long.TryParse(parts[1], NumberStyles.None, CultureInfo.InvariantCulture, out var end))
            {
                continue;
            }

            if (end < start)
            {
                (start, end) = (end, start);
            }

            int minLen = DigitsCount(start);
            int maxLen = DigitsCount(end);

            for (int len = minLen; len <= maxLen; len++)
            {
                if (len % 2 != 0)
                {
                    continue;
                }

                long pow10 = Pow10(len / 2);
                long first = Pow10(len - 1);
                long last = Pow10(len) - 1;

                long low = long.Max(start, first);
                long high = long.Min(end, last);

                if (low > high)
                {
                    continue;
                }

                long aStart = (long)Math.Ceiling(low / (double)(pow10 + 1));
                long aEnd = high / (pow10 + 1);

                if (aStart > aEnd)
                {
                    continue;
                }

                long count = aEnd - aStart + 1;
                long termsSum = checked((aStart + aEnd) * count / 2);
                long contrib = checked(termsSum * (pow10 + 1));

                sum = checked(sum + contrib);
            }
        }

        return sum;
    }

    private static long SumInvalidIdsPart2(string input)
    {
        long sum = 0;
        var ranges = input.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

        foreach (var range in ranges)
        {
            var parts = range.Split('-', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            if (parts.Length != 2)
            {
                continue;
            }

            if (!long.TryParse(parts[0], NumberStyles.None, CultureInfo.InvariantCulture, out var start))
            {
                continue;
            }

            if (!long.TryParse(parts[1], NumberStyles.None, CultureInfo.InvariantCulture, out var end))
            {
                continue;
            }

            if (end < start)
            {
                (start, end) = (end, start);
            }

            int minLen = DigitsCount(start);
            int maxLen = DigitsCount(end);

            for (int len = minLen; len <= maxLen; len++)
            {
                for (int k = 2; k * k <= len; k++)
                {
                    if (len % k != 0)
                    {
                        continue;
                    }

                    int baseLen = len / k;
                    long pow10Base = Pow10(baseLen);
                    long first = Pow10(len - 1);
                    long last = Pow10(len) - 1;

                    long low = long.Max(start, first);
                    long high = long.Min(end, last);

                    if (low > high)
                    {
                        continue;
                    }

                    // Geometric series factor: 1 + 10^baseLen + ... + 10^{(k-1)*baseLen}
                    long geom = 0;
                    long factor = 1;
                    for (int i = 0; i < k; i++)
                    {
                        geom += factor;
                        factor *= pow10Base;
                    }

                    long aStart = (long)Math.Ceiling(low / (double)geom);
                    long aEnd = high / geom;

                    if (aStart > aEnd)
                    {
                        continue;
                    }

                    long count = aEnd - aStart + 1;
                    long termsSum = (aStart + aEnd) * count / 2;
                    long contrib = termsSum * geom;
                    sum += contrib;
                }
            }
        }

        return sum;
    }

    private static int DigitsCount(long n)
    {
        n = Math.Abs(n);
        int count = 1;
        while (n >= 10)
        {
            n /= 10;
            count++;
        }

        return count;
    }

    private static long Pow10(int exp)
    {
        long result = 1;
        for (int i = 0; i < exp; i++)
        {
            result *= 10;
        }

        return result;
    }
}
