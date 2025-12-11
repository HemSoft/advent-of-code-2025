using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;

var lines = File.ReadAllLines("input.txt");
var points = new List<(long x, long y)>();

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
        continue;
    var parts = line.Split(',');
    points.Add((long.Parse(parts[0]), long.Parse(parts[1])));
}

long maxAreaPart1 = 0;
long maxAreaPart2 = 0;

var edges = new List<((long x, long y) p1, (long x, long y) p2)>();
int n = points.Count;
for (int i = 0; i < n; i++)
{
    edges.Add((points[i], points[(i + 1) % n]));
}

bool IsPointInPolygon(double x, double y)
{
    bool inside = false;
    foreach (var edge in edges)
    {
        var p1 = edge.p1;
        var p2 = edge.p2;
        if ((p1.y > y) != (p2.y > y))
        {
            double intersectX = (double)(p2.x - p1.x) * (y - p1.y) / (p2.y - p1.y) + p1.x;
            if (x < intersectX)
            {
                inside = !inside;
            }
        }
    }
    return inside;
}

bool IsValid((long x, long y) p1, (long x, long y) p2)
{
    long x1 = Math.Min(p1.x, p2.x);
    long x2 = Math.Max(p1.x, p2.x);
    long y1 = Math.Min(p1.y, p2.y);
    long y2 = Math.Max(p1.y, p2.y);

    double cx = (x1 + x2) / 2.0;
    double cy = (y1 + y2) / 2.0;

    if (!IsPointInPolygon(cx, cy))
    {
        return false;
    }

    foreach (var edge in edges)
    {
        var ep1 = edge.p1;
        var ep2 = edge.p2;

        if (ep1.x == ep2.x) // Vertical
        {
            long ex = ep1.x;
            long eyMin = Math.Min(ep1.y, ep2.y);
            long eyMax = Math.Max(ep1.y, ep2.y);
            if (x1 < ex && ex < x2)
            {
                long overlapMin = Math.Max(y1, eyMin);
                long overlapMax = Math.Min(y2, eyMax);
                if (overlapMin < overlapMax)
                {
                    return false;
                }
            }
        }
        else if (ep1.y == ep2.y) // Horizontal
        {
            long ey = ep1.y;
            long exMin = Math.Min(ep1.x, ep2.x);
            long exMax = Math.Max(ep1.x, ep2.x);
            if (y1 < ey && ey < y2)
            {
                long overlapMin = Math.Max(x1, exMin);
                long overlapMax = Math.Min(x2, exMax);
                if (overlapMin < overlapMax)
                {
                    return false;
                }
            }
        }
    }
    return true;
}

for (int i = 0; i < points.Count; i++)
{
    for (int j = i + 1; j < points.Count; j++)
    {
        var p1 = points[i];
        var p2 = points[j];

        long width = Math.Abs(p1.x - p2.x) + 1;
        long height = Math.Abs(p1.y - p2.y) + 1;
        long area = width * height;

        if (area > maxAreaPart1)
        {
            maxAreaPart1 = area;
        }

        if (IsValid(p1, p2))
        {
            if (area > maxAreaPart2)
            {
                maxAreaPart2 = area;
            }
        }
    }
}

Console.WriteLine($"Day 09 Part 1: {maxAreaPart1}");
Console.WriteLine($"Day 09 Part 2: {maxAreaPart2}");
