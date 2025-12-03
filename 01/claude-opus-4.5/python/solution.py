with open("input.txt") as f:
    lines = [line.strip() for line in f if line.strip()]

position = 50
zero_count_part1 = 0
zero_count_part2 = 0

for line in lines:
    direction = line[0]
    distance = int(line[1:])

    if direction == 'L':
        new_position = (position - distance) % 100
        first_hit = 100 if position == 0 else position
    else:
        new_position = (position + distance) % 100
        first_hit = 100 if position == 0 else (100 - position)

    if new_position == 0:
        zero_count_part1 += 1

    if first_hit <= distance:
        zero_count_part2 += 1 + (distance - first_hit) // 100

    position = new_position

print(f"Day 01 Part 1: {zero_count_part1}")
print(f"Day 01 Part 2: {zero_count_part2}")
