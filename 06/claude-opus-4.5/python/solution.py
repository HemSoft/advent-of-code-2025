with open("input.txt") as f:
    lines = f.read().rstrip('\n').split('\n')

# Remove trailing empty lines
while lines and lines[-1].strip() == '':
    lines.pop()

# Find max width and pad lines
max_width = max(len(line) for line in lines)
grid = [line.ljust(max_width) for line in lines]
rows = len(grid)
cols = max_width
operator_row = grid[rows - 1]

def is_separator_column(col):
    for r in range(rows - 1):
        if col < len(grid[r]) and grid[r][col] != ' ':
            return False
    return True

problems = []
col_start = 0

while col_start < cols:
    # Skip separator columns
    while col_start < cols and is_separator_column(col_start):
        col_start += 1
    if col_start >= cols:
        break

    # Find end of this problem
    col_end = col_start
    while col_end < cols and not is_separator_column(col_end):
        col_end += 1

    # Extract numbers and operator
    numbers = []
    op = ' '

    for r in range(rows - 1):
        segment = grid[r][col_start:col_end].strip()
        if segment and segment.isdigit():
            numbers.append(int(segment))

    # Get operator
    op_segment = operator_row[col_start:col_end].strip()
    if op_segment:
        op = op_segment[0]

    if numbers and op in ('+', '*'):
        problems.append((numbers, op))

    col_start = col_end

# Calculate grand total
part1 = 0
for numbers, op in problems:
    if op == '+':
        result = sum(numbers)
    else:
        result = 1
        for n in numbers:
            result *= n
    part1 += result

print(f"Day 06 Part 1: {part1}")

# Part 2: Read columns right-to-left, digits top-to-bottom form numbers
part2 = 0
col_start = 0

while col_start < cols:
    while col_start < cols and is_separator_column(col_start):
        col_start += 1
    if col_start >= cols:
        break

    col_end = col_start
    while col_end < cols and not is_separator_column(col_end):
        col_end += 1

    # Get operator
    op_segment = operator_row[col_start:col_end].strip()
    op = op_segment[0] if op_segment else ' '

    # Read columns right-to-left within this problem block
    numbers2 = []
    for c in range(col_end - 1, col_start - 1, -1):
        digits = []
        for r in range(rows - 1):
            ch = grid[r][c]
            if ch.isdigit():
                digits.append(ch)
        if digits:
            numbers2.append(int(''.join(digits)))

    if numbers2 and op in ('+', '*'):
        if op == '+':
            result = sum(numbers2)
        else:
            result = 1
            for n in numbers2:
                result *= n
        part2 += result

    col_start = col_end

print(f"Day 06 Part 2: {part2}")
