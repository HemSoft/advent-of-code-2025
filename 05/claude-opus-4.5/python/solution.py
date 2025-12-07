with open("input.txt") as f:
    input_data = f.read().strip()

sections = input_data.split("\n\n")

ranges = []
for line in sections[0].split("\n"):
    start, end = line.strip().split("-")
    ranges.append((int(start), int(end)))

ingredients = [int(line.strip()) for line in sections[1].split("\n") if line.strip()]

# Part 1
part1 = sum(1 for id in ingredients if any(start <= id <= end for start, end in ranges))
print(f"Day 05 Part 1: {part1}")

# Part 2: Merge overlapping ranges and count total unique IDs
sorted_ranges = sorted(ranges, key=lambda r: (r[0], r[1]))
merged = []

for start, end in sorted_ranges:
    if not merged or merged[-1][1] < start - 1:
        merged.append([start, end])
    else:
        merged[-1][1] = max(merged[-1][1], end)

part2 = sum(end - start + 1 for start, end in merged)
print(f"Day 05 Part 2: {part2}")
