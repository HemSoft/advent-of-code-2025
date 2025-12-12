import sys
import os

sys.setrecursionlimit(5000)

def solve():
    input_file = "input.txt"
    if len(sys.argv) > 1:
        input_file = sys.argv[1]

    if not os.path.exists(input_file):
        print(f"Input file {input_file} not found.")
        return

    with open(input_file) as f:
        content = f.read().replace("\r\n", "\n")

    parts = content.split("\n\n")
    shapes = {}
    regions = []

    for part in parts:
        lines = part.strip().split("\n")
        if not lines: continue

        if ":" in lines[0]:
            if "x" in lines[0]: # Region
                for line in lines:
                    if line.strip():
                        parse_region(line, regions)
            else: # Shape
                parse_shape(lines, shapes)

    solved_count = 0
    for region in regions:
        if solve_region(region, shapes):
            solved_count += 1

    print(f"Day 12 Part 1: {solved_count}")
    # print(f"Day 12 Part 2: 0")

def parse_shape(lines, shapes):
    header = lines[0].strip().rstrip(":")
    try:
        id = int(header)
    except ValueError:
        return

    points = set()
    for r in range(1, len(lines)):
        for c in range(len(lines[r])):
            if lines[r][c] == '#':
                points.add((r - 1, c))

    shapes[id] = generate_variations(points)

def parse_region(line, regions):
    p = line.split(":")
    dims = p[0].split("x")
    w = int(dims[0])
    h = int(dims[1])
    counts = [int(x) for x in p[1].strip().split()]
    regions.append({"w": w, "h": h, "counts": counts})

def generate_variations(original):
    variations = []
    current = original
    for i in range(2): # Flip
        for j in range(4): # Rotate
            normalized = normalize(current)
            if normalized not in variations:
                variations.append(normalized)
            current = rotate(current)
        current = flip(original)
    return variations

def rotate(points):
    return set((c, -r) for r, c in points)

def flip(points):
    return set((r, -c) for r, c in points)

def normalize(points):
    if not points: return frozenset()
    min_r = min(p[0] for p in points)
    min_c = min(p[1] for p in points)
    return frozenset((r - min_r, c - min_c) for r, c in points)

def solve_region(region, shapes):
    presents = []
    total_area = 0
    for i, count in enumerate(region["counts"]):
        for _ in range(count):
            presents.append(i)
            # Area of shape i is len(shapes[i][0])
            total_area += len(shapes[i][0])

    if total_area > region["w"] * region["h"]:
        return False

    max_skips = (region["w"] * region["h"]) - total_area
    grid = [False] * (region["w"] * region["h"])

    # Sort present types by size descending
    present_types = sorted(list(set(presents)), key=lambda x: len(shapes[x][0]), reverse=True)
    counts = {}
    for p in presents:
        counts[p] = counts.get(p, 0) + 1

    anchored_shapes = {}
    for type_id in present_types:
        anchored_shapes[type_id] = []
        for v in shapes[type_id]:
            # Sort points to find anchor
            sorted_pts = sorted(list(v))
            anchor = sorted_pts[0]
            points = [(p[0] - anchor[0], p[1] - anchor[1]) for p in sorted_pts]
            anchored_shapes[type_id].append(points)

    ctx = {
        "w": region["w"],
        "h": region["h"],
        "counts": counts,
        "types": present_types,
        "anchored_shapes": anchored_shapes
    }

    return backtrack(0, grid, ctx, max_skips)

def backtrack(idx, grid, ctx, skips_left):
    while idx < len(grid) and grid[idx]:
        idx += 1

    if idx == len(grid):
        return all(c == 0 for c in ctx["counts"].values())

    r = idx // ctx["w"]
    c = idx % ctx["w"]

    for type_id in ctx["types"]:
        if ctx["counts"][type_id] > 0:
            variations = ctx["anchored_shapes"][type_id]
            for shape in variations:
                fits = True
                for dr, dc in shape:
                    pr, pc = r + dr, c + dc
                    if pr < 0 or pr >= ctx["h"] or pc < 0 or pc >= ctx["w"]:
                        fits = False
                        break
                    if grid[pr * ctx["w"] + pc]:
                        fits = False
                        break

                if fits:
                    # Place
                    for dr, dc in shape:
                        grid[(r + dr) * ctx["w"] + (c + dc)] = True
                    ctx["counts"][type_id] -= 1

                    if backtrack(idx + 1, grid, ctx, skips_left):
                        return True

                    # Backtrack
                    ctx["counts"][type_id] += 1
                    for dr, dc in shape:
                        grid[(r + dr) * ctx["w"] + (c + dc)] = False

    if skips_left > 0:
        grid[idx] = True
        if backtrack(idx + 1, grid, ctx, skips_left - 1):
            return True
        grid[idx] = False

    return False

if __name__ == "__main__":
    solve()
