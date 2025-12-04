with open("input.txt") as f:
    lines = f.readlines()

total_joltage = 0

for line in lines:
    line = line.strip()
    if not line:
        continue

    max_joltage = 0
    found = False

    for d1 in range(9, 0, -1):
        c1 = str(d1)
        idx1 = line.find(c1)

        if idx1 == -1:
            continue

        for d2 in range(9, 0, -1):
            c2 = str(d2)
            idx2 = line.rfind(c2)

            if idx2 == -1:
                continue

            if idx1 < idx2:
                max_joltage = d1 * 10 + d2
                found = True
                break

        if found:
            break

    total_joltage += max_joltage

print(f"Day 03 Part 1: {total_joltage}")

total_joltage_part2 = 0

for line in lines:
    line = line.strip()
    if not line:
        continue

    result = ""
    current_index = 0
    digits_needed = 12
    length = len(line)

    for i in range(digits_needed):
        remaining_needed = digits_needed - 1 - i
        search_end_index = length - 1 - remaining_needed

        best_digit = -1
        best_digit_index = -1

        for d in range(9, 0, -1):
            c = str(d)
            idx = line.find(c, current_index)

            if idx != -1 and idx <= search_end_index:
                best_digit = d
                best_digit_index = idx
                break

        if best_digit != -1:
            result += str(best_digit)
            current_index = best_digit_index + 1

    if len(result) == 12:
        total_joltage_part2 += int(result)

print(f"Day 03 Part 2: {total_joltage_part2}")
