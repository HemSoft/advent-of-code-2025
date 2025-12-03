with open("input.txt", "r") as f:
    lines = f.readlines()

pos = 50
count = 0

for line in lines:
    line = line.strip()
    if not line:
        continue

    dir = line[0]
    amount = int(line[1:])

    if dir == 'R':
        pos = (pos + amount) % 100
    elif dir == 'L':
        pos = (pos - amount) % 100

    if pos == 0:
        count += 1

print(f"Day 01 Part 1: {count}")
