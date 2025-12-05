using System;
using System.IO;

var lines = File.ReadAllLines("input.txt");

// Part 1
int pos1 = 50;
int count1 = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
        continue;

    char dir = line[0];
    int amount = int.Parse(line.Substring(1));

    if (dir == 'R')
    {
        pos1 = (pos1 + amount) % 100;
    }
    else if (dir == 'L')
    {
        pos1 = (pos1 - amount) % 100;
        if (pos1 < 0)
            pos1 += 100;
    }

    if (pos1 == 0)
    {
        count1++;
    }
}

Console.WriteLine($"Day 01 Part 1: {count1}");

// Part 2
int pos2 = 50;
int count2 = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
        continue;

    char dir = line[0];
    int amount = int.Parse(line.Substring(1));

    for (int i = 0; i < amount; i++)
    {
        if (dir == 'R')
        {
            pos2 = (pos2 + 1) % 100;
        }
        else if (dir == 'L')
        {
            pos2--;
            if (pos2 < 0)
                pos2 = 99;
        }

        if (pos2 == 0)
        {
            count2++;
        }
    }
}

Console.WriteLine($"Day 01 Part 2: {count2}");
