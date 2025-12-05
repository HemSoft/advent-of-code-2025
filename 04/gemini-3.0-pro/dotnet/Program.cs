using System.Globalization;

var lines = File.ReadAllLines("input.txt");
int rows = lines.Length;
int cols = rows > 0 ? lines[0].Length : 0;

var grid = new char[rows][];
for (int i = 0; i < rows; i++)
{
    grid[i] = lines[i].ToCharArray();
}

long totalRemoved = 0;
int iteration = 0;

while (true)
{
    iteration++;
    var toRemove = new List<(int r, int c)>();

    for (int r = 0; r < rows; r++)
    {
        for (int c = 0; c < cols; c++)
        {
            if (grid[r][c] == '@')
            {
                int neighborCount = 0;
                for (int dr = -1; dr <= 1; dr++)
                {
                    for (int dc = -1; dc <= 1; dc++)
                    {
                        if (dr == 0 && dc == 0)
                            continue;

                        int nr = r + dr;
                        int nc = c + dc;

                        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols)
                        {
                            if (grid[nr][nc] == '@')
                            {
                                neighborCount++;
                            }
                        }
                    }
                }

                if (neighborCount < 4)
                {
                    toRemove.Add((r, c));
                }
            }
        }
    }

    if (toRemove.Count == 0)
    {
        break;
    }

    if (iteration == 1)
    {
        Console.WriteLine($"Day 04 Part 1: {toRemove.Count.ToString(CultureInfo.InvariantCulture)}");
    }

    totalRemoved += toRemove.Count;

    foreach (var (r, c) in toRemove)
    {
        grid[r][c] = '.';
    }
}

Console.WriteLine($"Day 04 Part 2: {totalRemoved.ToString(CultureInfo.InvariantCulture)}");
