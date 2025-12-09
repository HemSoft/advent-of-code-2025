with open("input.txt") as f:
    lines = [line.strip() for line in f if line.strip()]

points = []
for line in lines:
    x, y, z = map(int, line.split(','))
    points.append((x, y, z))

n = len(points)

# Calculate all pairwise squared distances
pairs = []
for i in range(n):
    for j in range(i + 1, n):
        dx = points[i][0] - points[j][0]
        dy = points[i][1] - points[j][1]
        dz = points[i][2] - points[j][2]
        dist_sq = dx * dx + dy * dy + dz * dz
        pairs.append((dist_sq, i, j))

# Sort by distance
pairs.sort()

# Union-Find
parent = list(range(n))
rank = [0] * n

def find(x):
    if parent[x] != x:
        parent[x] = find(parent[x])
    return parent[x]

def unite(x, y):
    px, py = find(x), find(y)
    if px == py:
        return False
    if rank[px] < rank[py]:
        px, py = py, px
    parent[py] = px
    if rank[px] == rank[py]:
        rank[px] += 1
    return True

# Connect the 1000 shortest pairs for Part 1
connections = min(1000, len(pairs))
for i in range(connections):
    _, a, b = pairs[i]
    unite(a, b)

# Count circuit sizes
from collections import Counter
circuit_sizes = Counter(find(i) for i in range(n))

# Get top 3 largest
top3 = sorted(circuit_sizes.values(), reverse=True)[:3]
part1 = 1
for size in top3:
    part1 *= size

print(f"Day 08 Part 1: {part1}")

# Part 2: Reset and find the last connection that unifies all into one circuit
parent = list(range(n))
rank = [0] * n

num_circuits = n
last_i, last_j = -1, -1

for dist_sq, i, j in pairs:
    if num_circuits <= 1:
        break
    if unite(i, j):
        num_circuits -= 1
        last_i, last_j = i, j

part2 = points[last_i][0] * points[last_j][0]
print(f"Day 08 Part 2: {part2}")
