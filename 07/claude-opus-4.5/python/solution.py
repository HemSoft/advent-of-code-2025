with open("input.txt") as f:
    lines = f.read().strip().split('\n')

grid = [list(line) for line in lines]
rows = len(grid)
cols = len(grid[0]) if rows > 0 else 0

# Find starting position S
start_row, start_col = 0, 0
for r in range(rows):
    for c in range(cols):
        if grid[r][c] == 'S':
            start_row, start_col = r, c
            break

# Part 1: Count total splits
split_count = 0
current_beams = {start_col}  # Set of columns with active beams

for row in range(start_row + 1, rows):
    if not current_beams:
        break
    next_beams = set()
    for col in current_beams:
        if col < 0 or col >= cols:
            continue
        cell = grid[row][col]
        if cell == '^':
            # Beam hits a splitter - count the split
            split_count += 1
            # Create new beams to the left and right
            if col - 1 >= 0:
                next_beams.add(col - 1)
            if col + 1 < cols:
                next_beams.add(col + 1)
        else:
            # Beam continues downward
            next_beams.add(col)
    current_beams = next_beams

print(f"Day 07 Part 1: {split_count}")

# Part 2: Count timelines (each particle takes both paths at each splitter)
particle_counts = {start_col: 1}

for row in range(start_row + 1, rows):
    if not particle_counts:
        break
    next_counts = {}
    for col, count in particle_counts.items():
        if col < 0 or col >= cols:
            continue
        cell = grid[row][col]
        if cell == '^':
            # Each particle splits into two
            if col - 1 >= 0:
                next_counts[col - 1] = next_counts.get(col - 1, 0) + count
            if col + 1 < cols:
                next_counts[col + 1] = next_counts.get(col + 1, 0) + count
        else:
            next_counts[col] = next_counts.get(col, 0) + count
    particle_counts = next_counts

part2 = sum(particle_counts.values())
print(f"Day 07 Part 2: {part2}")
