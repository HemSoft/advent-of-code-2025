using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;

class Program
{
    static void Main()
    {
        string[] lines;
        try
        {
            lines = File.ReadAllLines("input.txt");
        }
        catch (Exception)
        {
            Console.WriteLine("Error reading input.txt");
            return;
        }

        if (lines.Length == 0)
            return;

        int width = lines[0].Length;
        int height = lines.Length;

        int startCol = -1;
        int startRow = -1;

        for (int r = 0; r < height; r++)
        {
            int idx = lines[r].IndexOf('S');
            if (idx != -1)
            {
                startCol = idx;
                startRow = r;
                break;
            }
        }

        if (startCol == -1)
        {
            Console.WriteLine("Start not found");
            return;
        }

        HashSet<int> activeBeams = new HashSet<int>();
        activeBeams.Add(startCol);
        long totalSplits = 0;

        for (int r = startRow + 1; r < height; r++)
        {
            HashSet<int> nextBeams = new HashSet<int>();
            string line = lines[r];

            foreach (int c in activeBeams)
            {
                if (c < 0 || c >= width)
                    continue;

                char ch = line[c];
                if (ch == '^')
                {
                    totalSplits++;
                    if (c - 1 >= 0)
                        nextBeams.Add(c - 1);
                    if (c + 1 < width)
                        nextBeams.Add(c + 1);
                }
                else
                {
                    nextBeams.Add(c);
                }
            }
            activeBeams = nextBeams;
            if (activeBeams.Count == 0)
                break;
        }

        Console.WriteLine($"Day 07 Part 1: {totalSplits}");

        // Part 2
        Dictionary<(int, int), long> memo = new Dictionary<(int, int), long>();

        long CountPaths(int r, int c)
        {
            if (c < 0 || c >= width)
                return 1;

            if (memo.ContainsKey((r, c)))
                return memo[(r, c)];

            for (int currR = r + 1; currR < height; currR++)
            {
                if (lines[currR][c] == '^')
                {
                    long res = CountPaths(currR, c - 1) + CountPaths(currR, c + 1);
                    memo[(r, c)] = res;
                    return res;
                }
            }

            memo[(r, c)] = 1;
            return 1;
        }

        long part2Ans = CountPaths(startRow, startCol);
        Console.WriteLine($"Day 07 Part 2: {part2Ans}");
    }
}
