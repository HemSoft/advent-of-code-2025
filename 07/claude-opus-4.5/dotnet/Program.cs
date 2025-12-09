using System.Globalization;

var lines = File.ReadAllLines("input.txt");
var grid = lines.Select(l => l.ToCharArray()).ToArray();
int rows = grid.Length;
int cols = grid[0].Length;

// Find starting position S
int startRow = 0, startCol = 0;
for (int r = 0; r < rows; r++)
{
    for (int c = 0; c < cols; c++)
    {
        if (grid[r][c] == 'S')
        {
            startRow = r;
            startCol = c;
            break;
        }
    }
}

// Part 1: Count total splits
// Track which cells have active beams passing through them at each row level
// A beam at (row, col) moves downward. When hitting ^, splits left and right.
// Use sets to track active beam columns at each row, avoiding duplicates
long splitCount = 0;
var currentBeams = new HashSet<int> { startCol }; // Columns with active beams

for (int row = startRow + 1; row < rows && currentBeams.Count > 0; row++)
{
    var nextBeams = new HashSet<int>();
    foreach (int col in currentBeams)
    {
        if (col < 0 || col >= cols)
            continue;

        char cell = grid[row][col];
        if (cell == '^')
        {
            // Beam hits a splitter - count the split
            splitCount++;
            // Create new beams to the left and right
            if (col - 1 >= 0)
                nextBeams.Add(col - 1);
            if (col + 1 < cols)
                nextBeams.Add(col + 1);
        }
        else
        {
            // Beam continues downward
            nextBeams.Add(col);
        }
    }
    currentBeams = nextBeams;
}

Console.WriteLine($"Day 07 Part 1: {splitCount.ToString(CultureInfo.InvariantCulture)}");

// Part 2: Count timelines (each particle takes both paths at each splitter)
// Track count of particles at each column position
var particleCounts = new Dictionary<int, long> { { startCol, 1L } };

for (int row = startRow + 1; row < rows && particleCounts.Count > 0; row++)
{
    var nextCounts = new Dictionary<int, long>();
    foreach (var (col, count) in particleCounts)
    {
        if (col < 0 || col >= cols)
            continue;

        char cell = grid[row][col];
        if (cell == '^')
        {
            // Each particle splits into two (left and right)
            if (col - 1 >= 0)
            {
                if (!nextCounts.ContainsKey(col - 1))
                    nextCounts[col - 1] = 0;
                nextCounts[col - 1] += count;
            }
            if (col + 1 < cols)
            {
                if (!nextCounts.ContainsKey(col + 1))
                    nextCounts[col + 1] = 0;
                nextCounts[col + 1] += count;
            }
        }
        else
        {
            // Particle continues downward
            if (!nextCounts.ContainsKey(col))
                nextCounts[col] = 0;
            nextCounts[col] += count;
        }
    }
    particleCounts = nextCounts;
}

// Sum all remaining particles - each represents a unique timeline
long part2 = particleCounts.Values.Sum();
Console.WriteLine($"Day 07 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
