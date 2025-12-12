with open("input.txt") as f:
    lines = [line.rstrip('\r\n') for line in f.readlines()]

# Parse shapes and regions
shapes = {}
region_lines = []
current_shape_id = -1
current_shape_rows = []

for line in lines:
    if not line.strip():
        continue
    
    # Check if this is a shape definition (starts with digit and colon)
    if line[0].isdigit() and ':' in line and 'x' not in line:
        if current_shape_id >= 0 and current_shape_rows:
            shapes[current_shape_id] = sum(row.count('#') for row in current_shape_rows)
        current_shape_id = int(line.split(':')[0])
        current_shape_rows = []
    elif 'x' in line and ':' in line:
        # This is a region line
        if current_shape_id >= 0 and current_shape_rows:
            shapes[current_shape_id] = sum(row.count('#') for row in current_shape_rows)
            current_shape_id = -1
            current_shape_rows = []
        region_lines.append(line)
    elif current_shape_id >= 0 and ('#' in line or '.' in line):
        current_shape_rows.append(line)

if current_shape_id >= 0 and current_shape_rows:
    shapes[current_shape_id] = sum(row.count('#') for row in current_shape_rows)

part1 = 0

for region_line in region_lines:
    colon_idx = region_line.index(':')
    size_part = region_line[:colon_idx]
    counts_part = region_line[colon_idx + 1:].strip()
    
    width, height = map(int, size_part.split('x'))
    counts = list(map(int, counts_part.split()))
    
    total_cells_needed = sum(counts[i] * shapes[i] for i in range(len(counts)))
    grid_area = width * height
    
    if total_cells_needed <= grid_area:
        part1 += 1

print(f"Day 12 Part 1: {part1}")

# Part 2
part2 = 0
print(f"Day 12 Part 2: {part2}")
