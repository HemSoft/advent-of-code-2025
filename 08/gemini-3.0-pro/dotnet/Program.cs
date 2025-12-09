using System.Globalization;

var lines = File.ReadAllLines("input.txt");
var points = new List<(int x, int y, int z)>();

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line)) continue;
    var parts = line.Split(',');
    if (parts.Length == 3)
    {
        points.Add((int.Parse(parts[0]), int.Parse(parts[1]), int.Parse(parts[2])));
    }
}

var pairs = new List<(double dist, int i, int j)>();
for (int i = 0; i < points.Count; i++)
{
    for (int j = i + 1; j < points.Count; j++)
    {
        var p1 = points[i];
        var p2 = points[j];
        double distSq = Math.Pow(p1.x - p2.x, 2) + Math.Pow(p1.y - p2.y, 2) + Math.Pow(p1.z - p2.z, 2);
        double dist = Math.Sqrt(distSq);
        pairs.Add((dist, i, j));
    }
}

pairs.Sort((a, b) => a.dist.CompareTo(b.dist));

int[] parent = Enumerable.Range(0, points.Count).ToArray();

int Find(int i)
{
    if (parent[i] == i) return i;
    parent[i] = Find(parent[i]);
    return parent[i];
}

void Union(int i, int j)
{
    int rootI = Find(i);
    int rootJ = Find(j);
    if (rootI != rootJ)
    {
        parent[rootI] = rootJ;
    }
}

int limit = Math.Min(1000, pairs.Count);
for (int k = 0; k < limit; k++)
{
    Union(pairs[k].i, pairs[k].j);
}

var counts = new Dictionary<int, int>();
for (int i = 0; i < points.Count; i++)
{
    int root = Find(i);
    if (!counts.ContainsKey(root)) counts[root] = 0;
    counts[root]++;
}

var sizes = counts.Values.OrderByDescending(x => x).ToList();

long result = 0;
if (sizes.Count >= 3)
{
    result = (long)sizes[0] * sizes[1] * sizes[2];
}
else if (sizes.Count > 0)
{
    result = 1;
    foreach (var s in sizes) result *= s;
}

Console.WriteLine($"Day 08 Part 1: {result.ToString(CultureInfo.InvariantCulture)}");

// Part 2
parent = Enumerable.Range(0, points.Count).ToArray();
int numComponents = points.Count;
long part2Result = 0;

foreach (var pair in pairs)
{
    int rootI = Find(pair.i);
    int rootJ = Find(pair.j);
    if (rootI != rootJ)
    {
        parent[rootI] = rootJ;
        numComponents--;
        if (numComponents == 1)
        {
            part2Result = (long)points[pair.i].x * points[pair.j].x;
            break;
        }
    }
}

Console.WriteLine($"Day 08 Part 2: {part2Result.ToString(CultureInfo.InvariantCulture)}");