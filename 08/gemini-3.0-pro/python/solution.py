import math
import sys

def solve():
    try:
        with open("input.txt", "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print("Error: input.txt not found")
        return

    points = []
    for line in lines:
        if line.strip():
            parts = line.strip().split(',')
            if len(parts) == 3:
                x, y, z = map(int, parts)
                points.append((x, y, z))

    pairs = []
    for i in range(len(points)):
        for j in range(i + 1, len(points)):
            p1 = points[i]
            p2 = points[j]
            dist_sq = (p1[0]-p2[0])**2 + (p1[1]-p2[1])**2 + (p1[2]-p2[2])**2
            dist = math.sqrt(dist_sq)
            pairs.append((dist, i, j))

    # Sort by distance
    pairs.sort(key=lambda x: x[0])

    # Union-Find
    parent = list(range(len(points)))
    def find(i):
        if parent[i] == i:
            return i
        parent[i] = find(parent[i])
        return parent[i]

    def union(i, j):
        root_i = find(i)
        root_j = find(j)
        if root_i != root_j:
            parent[root_i] = root_j
            return True
        return False

    # Connect 1000 shortest
    limit = 1000
    if len(pairs) < limit:
        limit = len(pairs)
        
    for k in range(limit):
        dist, i, j = pairs[k]
        union(i, j)

    # Count sizes
    from collections import Counter
    counts = Counter()
    for i in range(len(points)):
        counts[find(i)] += 1
    
    sizes = sorted(counts.values(), reverse=True)
    
    result = 0
    if len(sizes) >= 3:
        result = sizes[0] * sizes[1] * sizes[2]
    elif len(sizes) > 0:
        result = 1
        for s in sizes:
            result *= s
            
    print(f"Day 08 Part 1: {result}")

    # Part 2
    parent = list(range(len(points)))
    num_components = len(points)
    part2_result = 0
    
    # print(f"DEBUG: Starting Part 2 with {num_components} components and {len(pairs)} pairs")

    for dist, i, j in pairs:
        if union(i, j):
            num_components -= 1
            # if num_components % 100 == 0:
            #     print(f"DEBUG: {num_components} components remaining")
            if num_components == 1:
                part2_result = points[i][0] * points[j][0]
                break
    
    print(f"Day 08 Part 2: {part2_result}")

if __name__ == "__main__":
    solve()