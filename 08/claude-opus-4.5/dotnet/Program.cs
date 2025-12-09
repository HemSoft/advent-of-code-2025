using System.Globalization;

var lines = File.ReadAllLines("input.txt").Where(l => !string.IsNullOrWhiteSpace(l)).ToArray();
var points = lines.Select(line =>
{
    var parts = line.Split(',');
    return (X: long.Parse(parts[0]), Y: long.Parse(parts[1]), Z: long.Parse(parts[2]));
}).ToArray();

int n = points.Length;

// Calculate all pairwise distances
var pairs = new List<(long distSq, int i, int j)>();
for (int i = 0; i < n; i++)
{
    for (int j = i + 1; j < n; j++)
    {
        long dx = points[i].X - points[j].X;
        long dy = points[i].Y - points[j].Y;
        long dz = points[i].Z - points[j].Z;
        long distSq = dx * dx + dy * dy + dz * dz;
        pairs.Add((distSq, i, j));
    }
}

// Sort by distance
pairs.Sort((a, b) => a.distSq.CompareTo(b.distSq));

// Union-Find
int[] parent = new int[n];
int[] rank = new int[n];
for (int i = 0; i < n; i++) parent[i] = i;

int Find(int x)
{
    if (parent[x] != x)
        parent[x] = Find(parent[x]);
    return parent[x];
}

bool Unite(int x, int y)
{
    int px = Find(x), py = Find(y);
    if (px == py)
        return false;
    if (rank[px] < rank[py])
        (px, py) = (py, px);
    parent[py] = px;
    if (rank[px] == rank[py])
        rank[px]++;
    return true;
}

// Connect the 1000 shortest pairs for Part 1
int connections = Math.Min(1000, pairs.Count);
for (int i = 0; i < connections; i++)
{
    Unite(pairs[i].i, pairs[i].j);
}

// Count circuit sizes
var circuitSizes = new Dictionary<int, int>();
for (int i = 0; i < n; i++)
{
    int root = Find(i);
    circuitSizes.TryAdd(root, 0);
    circuitSizes[root]++;
}

// Get top 3 largest
var top3 = circuitSizes.Values.OrderByDescending(x => x).Take(3).ToList();
long part1 = top3.Aggregate(1L, (a, b) => a * b);

Console.WriteLine($"Day 08 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2: Reset and find the last connection that unifies all into one circuit
for (int i = 0; i < n; i++)
{
    parent[i] = i;
    rank[i] = 0;
}

int numCircuits = n;
int lastI = -1, lastJ = -1;

for (int i = 0; i < pairs.Count && numCircuits > 1; i++)
{
    if (Unite(pairs[i].i, pairs[i].j))
    {
        numCircuits--;
        lastI = pairs[i].i;
        lastJ = pairs[i].j;
    }
}

long part2 = points[lastI].X * points[lastJ].X;
Console.WriteLine($"Day 08 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
