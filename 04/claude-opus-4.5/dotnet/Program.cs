using System.Globalization;

var lines = File.ReadAllLines("input.txt");
var grid = lines.Where(l => !string.IsNullOrEmpty(l)).ToArray();
var rows = grid.Length;
var cols = grid[0].Length;

// Part 1: Count rolls with fewer than 4 adjacent rolls
int part1 = 0;
int[] dx = [-1, -1, -1, 0, 0, 1, 1, 1];
int[] dy = [-1, 0, 1, -1, 1, -1, 0, 1];

for (int r = 0; r < rows; r++)
{
    for (int c = 0; c < cols; c++)
    {
        if (grid[r][c] != '@')
            continue;

        int adjacentRolls = 0;
        for (int d = 0; d < 8; d++)
        {
            int nr = r + dx[d];
            int nc = c + dy[d];
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc] == '@')
            {
                adjacentRolls++;
            }
        }

        if (adjacentRolls < 4)
        {
            part1++;
        }
    }
}

Console.WriteLine($"Day 04 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2: Iteratively remove accessible rolls until none remain
char[][] mutableGrid = grid.Select(row => row.ToCharArray()).ToArray();
long part2 = 0;

while (true)
{
    var toRemove = new List<(int r, int c)>();

    for (int r = 0; r < rows; r++)
    {
        for (int c = 0; c < cols; c++)
        {
            if (mutableGrid[r][c] != '@')
                continue;

            int adjacentRolls = 0;
            for (int d = 0; d < 8; d++)
            {
                int nr = r + dx[d];
                int nc = c + dy[d];
                if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && mutableGrid[nr][nc] == '@')
                {
                    adjacentRolls++;
                }
            }

            if (adjacentRolls < 4)
            {
                toRemove.Add((r, c));
            }
        }
    }

    if (toRemove.Count == 0)
        break;

    foreach (var (r, c) in toRemove)
    {
        mutableGrid[r][c] = '.';
    }

    part2 += toRemove.Count;
}

Console.WriteLine($"Day 04 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
