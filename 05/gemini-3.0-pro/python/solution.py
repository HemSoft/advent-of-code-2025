with open("input.txt") as f:
    input_data = f.read().strip()

parts = input_data.split("\n\n")
ranges_lines = parts[0].splitlines()
ids_lines = parts[1].splitlines()

ranges = []
for line in ranges_lines:
    start, end = map(int, line.split('-'))
    ranges.append((start, end))

part1 = 0
for line in ids_lines:
    id_val = int(line)
    is_fresh = False
    for start, end in ranges:
        if start <= id_val <= end:
            is_fresh = True
            break
    if is_fresh:
        part1 += 1

print(f"Day 05 Part 1: {part1}")

# Part 2
ranges.sort()
merged_ranges = []
if ranges:
    curr_start, curr_end = ranges[0]
    for i in range(1, len(ranges)):
        next_start, next_end = ranges[i]
        if next_start <= curr_end + 1:
            curr_end = max(curr_end, next_end)
        else:
            merged_ranges.append((curr_start, curr_end))
            curr_start, curr_end = next_start, next_end
    merged_ranges.append((curr_start, curr_end))

part2 = 0
for start, end in merged_ranges:
    part2 += (end - start + 1)

print(f"Day 05 Part 2: {part2}")
