with open("input.txt", "r") as f:
    lines = f.readlines()

# Part 1
pos1 = 50
count1 = 0

for line in lines:
    line = line.strip()
    if not line:
        continue

    dir = line[0]
    amount = int(line[1:])

    if dir == 'R':
        pos1 = (pos1 + amount) % 100
    elif dir == 'L':
        pos1 = (pos1 - amount) % 100

    if pos1 == 0:
        count1 += 1

print(f"Day 01 Part 1: {count1}")

# Part 2
pos2 = 50
count2 = 0

for line in lines:
    line = line.strip()
    if not line:
        continue

    dir = line[0]
    amount = int(line[1:])

    for _ in range(amount):
        if dir == 'R':
            pos2 = (pos2 + 1) % 100
        elif dir == 'L':
            pos2 -= 1
            if pos2 < 0:
                pos2 = 99

        if pos2 == 0:
            count2 += 1

print(f"Day 01 Part 2: {count2}")
