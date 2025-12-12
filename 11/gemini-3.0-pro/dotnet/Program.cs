using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

class Program
{
    static Dictionary<string, List<string>> graph = new();
    static Dictionary<string, long> memo1 = new();
    static Dictionary<(string, int), long> memo2 = new();

    static void Main(string[] args)
    {
        string inputPath = "input.txt";
        if (!File.Exists(inputPath))
        {
            Console.WriteLine("Error: input.txt not found.");
            return;
        }

        var lines = File.ReadAllLines(inputPath);

        foreach (var line in lines)
        {
            if (string.IsNullOrWhiteSpace(line))
                continue;
            var parts = line.Split(": ");
            var source = parts[0];
            var targets = parts[1].Split(' ');
            graph[source] = new List<string>(targets);
        }

        long paths1 = CountPathsP1("you");
        Console.WriteLine($"Day 11 Part 1: {paths1}");

        long paths2 = CountPathsP2("svr", 0);
        Console.WriteLine($"Day 11 Part 2: {paths2}");
    }

    static long CountPathsP1(string current)
    {
        if (current == "out")
            return 1;
        if (memo1.ContainsKey(current))
            return memo1[current];

        if (!graph.ContainsKey(current))
        {
            return 0;
        }

        long total = 0;
        foreach (var neighbor in graph[current])
        {
            total += CountPathsP1(neighbor);
        }

        memo1[current] = total;
        return total;
    }

    static long CountPathsP2(string current, int mask)
    {
        if (current == "dac")
            mask |= 1;
        else if (current == "fft")
            mask |= 2;

        if (current == "out")
            return mask == 3 ? 1 : 0;

        var key = (current, mask);
        if (memo2.ContainsKey(key))
            return memo2[key];

        if (!graph.ContainsKey(current))
        {
            return 0;
        }

        long total = 0;
        foreach (var neighbor in graph[current])
        {
            total += CountPathsP2(neighbor, mask);
        }

        memo2[key] = total;
        return total;
    }
}
