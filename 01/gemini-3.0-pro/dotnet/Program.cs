using System;
using System.IO;

var lines = File.ReadAllLines("input.txt");
int pos = 50;
int count = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line)) continue;

    char dir = line[0];
    int amount = int.Parse(line.Substring(1));

    if (dir == 'R')
    {
        pos = (pos + amount) % 100;
    }
    else if (dir == 'L')
    {
        pos = (pos - amount) % 100;
        if (pos < 0) pos += 100;
    }

    if (pos == 0)
    {
        count++;
    }
}

Console.WriteLine($"Day 01 Part 1: {count}");
