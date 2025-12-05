using System.Globalization;

var lines = File.ReadAllLines("input.txt");
lines = Array.FindAll(lines, static line => !string.IsNullOrWhiteSpace(line));

static long CountAccessibleRolls(string[] grid)
{
    var height = grid.Length;
    if (height == 0)
    {
        return 0L;
    }

    var width = grid[0].Length;
    var accessible = 0L;

    var dRows = new[] { -1, -1, -1, 0, 0, 1, 1, 1 };
    var dCols = new[] { -1, 0, 1, -1, 1, -1, 0, 1 };

    for (var r = 0; r < height; r++)
    {
        var row = grid[r];

        for (var c = 0; c < width; c++)
        {
            if (row[c] != '@')
            {
                continue;
            }

            var neighborCount = 0;

            for (var i = 0; i < dRows.Length; i++)
            {
                var nr = r + dRows[i];
                var nc = c + dCols[i];

                if (nr < 0 || nr >= height || nc < 0 || nc >= width)
                {
                    continue;
                }

                if (grid[nr][nc] == '@')
                {
                    neighborCount++;
                }
            }

            if (neighborCount < 4)
            {
                accessible++;
            }
        }
    }

    return accessible;
}

static long CountRemovableRolls(string[] grid)
{
    var height = grid.Length;
    if (height == 0)
    {
        return 0L;
    }

    var width = grid[0].Length;

    var board = new char[height][];
    for (var r = 0; r < height; r++)
    {
        board[r] = grid[r].ToCharArray();
    }

    var dRows = new[] { -1, -1, -1, 0, 0, 1, 1, 1 };
    var dCols = new[] { -1, 0, 1, -1, 1, -1, 0, 1 };

    var totalRemoved = 0L;

    while (true)
    {
        var toRemove = new bool[height, width];
        var removedThisRound = 0L;

        for (var r = 0; r < height; r++)
        {
            for (var c = 0; c < width; c++)
            {
                if (board[r][c] != '@')
                {
                    continue;
                }

                var neighborCount = 0;

                for (var i = 0; i < dRows.Length; i++)
                {
                    var nr = r + dRows[i];
                    var nc = c + dCols[i];

                    if (nr < 0 || nr >= height || nc < 0 || nc >= width)
                    {
                        continue;
                    }

                    if (board[nr][nc] == '@')
                    {
                        neighborCount++;
                    }
                }

                if (neighborCount < 4)
                {
                    toRemove[r, c] = true;
                    removedThisRound++;
                }
            }
        }

        if (removedThisRound == 0)
        {
            break;
        }

        for (var r = 0; r < height; r++)
        {
            for (var c = 0; c < width; c++)
            {
                if (toRemove[r, c])
                {
                    board[r][c] = '.';
                }
            }
        }

        totalRemoved += removedThisRound;
    }

    return totalRemoved;
}

// Part 1
var part1 = CountAccessibleRolls(lines);
Console.WriteLine($"Day 04 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
var part2 = CountRemovableRolls(lines);
Console.WriteLine($"Day 04 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
