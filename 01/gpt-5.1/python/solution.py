position = 50
zero_count = 0

with open("input.txt") as f:
    for raw in f:
        line = raw.strip()
        if not line:
            continue

        dir = line[0]
        distance = int(line[1:]) % 100

        if dir == "R":
            position = (position + distance) % 100
        elif dir == "L":
            position = (position - distance) % 100
            if position < 0:
                position += 100

        if position == 0:
            zero_count += 1

# Part 1
part1 = zero_count
print(f"Day 01 Part 1: {part1}")

# Part 2
part2 = 0
print(f"Day 01 Part 2: {part2}")
