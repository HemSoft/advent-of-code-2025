namespace AdventOfCode
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using System.Globalization;

    class Program
    {
        static void Main(string[] args)
        {
            string inputFile = "input.txt";
            if (args.Length > 0)
                inputFile = args[0];

            if (!File.Exists(inputFile))
            {
                Console.WriteLine($"Input file {inputFile} not found.");
                return;
            }

            var content = File.ReadAllText(inputFile).Replace("\r\n", "\n");
            var parts = content.Split(new[] { "\n\n" }, StringSplitOptions.RemoveEmptyEntries);

            var shapes = new Dictionary<int, List<HashSet<(int r, int c)>>>();
            var regions = new List<RegionTask>();

            foreach (var part in parts)
            {
                var lines = part.Trim().Split('\n');
                if (lines.Length == 0)
                    continue;

                if (lines[0].Contains(":"))
                {
                    if (lines[0].Contains("x")) // Region block
                    {
                        foreach (var line in lines)
                        {
                            if (!string.IsNullOrWhiteSpace(line))
                                ParseRegion(line, regions);
                        }
                    }
                    else // Shape
                    {
                        ParseShape(lines, shapes);
                    }
                }
            }

            long solvedCount = 0;
            foreach (var region in regions)
            {
                if (Solve(region, shapes))
                {
                    solvedCount++;
                }
            }

            Console.WriteLine($"Day 12 Part 1: {solvedCount}");
        }

        static void ParseShape(string[] lines, Dictionary<int, List<HashSet<(int r, int c)>>> shapes)
        {
            var header = lines[0].Trim().Trim(':');
            if (!int.TryParse(header, out int id))
                return;

            var points = new HashSet<(int r, int c)>();
            for (int r = 1; r < lines.Length; r++)
            {
                for (int c = 0; c < lines[r].Length; c++)
                {
                    if (lines[r][c] == '#')
                    {
                        points.Add((r - 1, c));
                    }
                }
            }
            shapes[id] = GenerateVariations(points);
        }

        static void ParseRegion(string line, List<RegionTask> regions)
        {
            var p = line.Split(':');
            var dims = p[0].Split('x');
            int w = int.Parse(dims[0]);
            int h = int.Parse(dims[1]);
            var counts = p[1].Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray();
            regions.Add(new RegionTask { W = w, H = h, Counts = counts });
        }

        static List<HashSet<(int r, int c)>> GenerateVariations(HashSet<(int r, int c)> original)
        {
            var variations = new List<HashSet<(int r, int c)>>();
            var current = original;
            for (int i = 0; i < 2; i++) // Flip
            {
                for (int j = 0; j < 4; j++) // Rotate
                {
                    var normalized = Normalize(current);
                    if (!variations.Any(v => SetEquals(v, normalized)))
                    {
                        variations.Add(normalized);
                    }
                    current = Rotate(current);
                }
                current = Flip(original);
            }
            return variations;
        }

        static HashSet<(int r, int c)> Rotate(HashSet<(int r, int c)> points)
        {
            return points.Select(p => (p.c, -p.r)).ToHashSet();
        }

        static HashSet<(int r, int c)> Flip(HashSet<(int r, int c)> points)
        {
            return points.Select(p => (p.r, -p.c)).ToHashSet();
        }

        static HashSet<(int r, int c)> Normalize(HashSet<(int r, int c)> points)
        {
            if (points.Count == 0)
                return points;
            int minR = points.Min(p => p.r);
            int minC = points.Min(p => p.c);
            return points.Select(p => (p.r - minR, p.c - minC)).ToHashSet();
        }

        static bool SetEquals(HashSet<(int r, int c)> a, HashSet<(int r, int c)> b)
        {
            if (a.Count != b.Count)
                return false;
            return a.All(b.Contains);
        }

        class RegionTask
        {
            public int W, H;
            public int[] Counts;
        }

        class AnchoredShape
        {
            public List<(int dr, int dc)> Points;
        }

        class SolverContext
        {
            public int W, H;
            public Dictionary<int, int> Counts;
            public List<int> Types;
            public Dictionary<int, List<AnchoredShape>> AnchoredShapes;
        }

        static bool Solve(RegionTask region, Dictionary<int, List<HashSet<(int r, int c)>>> shapes)
        {
            var presents = new List<int>();
            int totalArea = 0;
            for (int i = 0; i < region.Counts.Length; i++)
            {
                for (int j = 0; j < region.Counts[i]; j++)
                {
                    presents.Add(i);
                    totalArea += shapes[i][0].Count;
                }
            }

            if (totalArea > region.W * region.H)
                return false;

            int maxSkips = (region.W * region.H) - totalArea;
            bool[] grid = new bool[region.W * region.H];

            var presentTypes = presents.Distinct().OrderByDescending(x => shapes[x][0].Count).ToList();
            var counts = new Dictionary<int, int>();
            foreach (var p in presents)
            {
                if (!counts.ContainsKey(p))
                    counts[p] = 0;
                counts[p]++;
            }

            var anchoredShapes = new Dictionary<int, List<AnchoredShape>>();
            foreach (var type in presentTypes)
            {
                anchoredShapes[type] = new List<AnchoredShape>();
                foreach (var v in shapes[type])
                {
                    var sorted = v.OrderBy(p => p.r).ThenBy(p => p.c).ToList();
                    var anchor = sorted[0];
                    var points = sorted.Select(p => (p.r - anchor.r, p.c - anchor.c)).ToList();
                    anchoredShapes[type].Add(new AnchoredShape { Points = points });
                }
            }

            var ctx = new SolverContext
            {
                W = region.W,
                H = region.H,
                Counts = counts,
                Types = presentTypes,
                AnchoredShapes = anchoredShapes
            };

            return Backtrack(0, grid, ctx, maxSkips);
        }

        static bool Backtrack(int idx, bool[] grid, SolverContext ctx, int skipsLeft)
        {
            while (idx < grid.Length && grid[idx])
            {
                idx++;
            }

            if (idx == grid.Length)
            {
                return ctx.Counts.Values.All(c => c == 0);
            }

            int r = idx / ctx.W;
            int c = idx % ctx.W;

            foreach (var type in ctx.Types)
            {
                if (ctx.Counts[type] > 0)
                {
                    var variations = ctx.AnchoredShapes[type];
                    foreach (var shape in variations)
                    {
                        bool fits = true;
                        foreach (var pt in shape.Points)
                        {
                            int pr = r + pt.dr;
                            int pc = c + pt.dc;
                            if (pr < 0 || pr >= ctx.H || pc < 0 || pc >= ctx.W)
                            { fits = false; break; }
                            if (grid[pr * ctx.W + pc])
                            { fits = false; break; }
                        }

                        if (fits)
                        {
                            foreach (var pt in shape.Points)
                            {
                                grid[(r + pt.dr) * ctx.W + (c + pt.dc)] = true;
                            }
                            ctx.Counts[type]--;

                            if (Backtrack(idx + 1, grid, ctx, skipsLeft))
                                return true;

                            ctx.Counts[type]++;
                            foreach (var pt in shape.Points)
                            {
                                grid[(r + pt.dr) * ctx.W + (c + pt.dc)] = false;
                            }
                        }
                    }
                }
            }

            if (skipsLeft > 0)
            {
                grid[idx] = true;
                if (Backtrack(idx + 1, grid, ctx, skipsLeft - 1))
                    return true;
                grid[idx] = false;
            }

            return false;
        }
    }
}
