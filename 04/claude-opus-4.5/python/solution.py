with open("input.txt") as f:
    lines = f.read().strip().split('\n')

grid = [line for line in lines if line]
rows = len(grid)
cols = len(grid[0])

# Part 1: Count rolls with fewer than 4 adjacent rolls
dx = [-1, -1, -1, 0, 0, 1, 1, 1]
dy = [-1, 0, 1, -1, 1, -1, 0, 1]

part1 = 0
for r in range(rows):
    for c in range(cols):
        if grid[r][c] != '@':
            continue

        adjacent_rolls = 0
        for d in range(8):
            nr, nc = r + dx[d], c + dy[d]
            if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] == '@':
                adjacent_rolls += 1

        if adjacent_rolls < 4:
            part1 += 1

print(f"Day 04 Part 1: {part1}")

# Part 2: Iteratively remove accessible rolls until none remain
mutable_grid = [list(row) for row in grid]

part2 = 0

while True:
    to_remove = []

    for r in range(rows):
        for c in range(cols):
            if mutable_grid[r][c] != '@':
                continue

            adjacent_rolls = 0
            for d in range(8):
                nr, nc = r + dx[d], c + dy[d]
                if 0 <= nr < rows and 0 <= nc < cols and mutable_grid[nr][nc] == '@':
                    adjacent_rolls += 1

            if adjacent_rolls < 4:
                to_remove.append((r, c))

    if not to_remove:
        break

    for r, c in to_remove:
        mutable_grid[r][c] = '.'

    part2 += len(to_remove)

print(f"Day 04 Part 2: {part2}")
