total_joltage_part1 = 0
total_joltage_part2 = 0

with open("input.txt") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue

        max_joltage_part1 = 0
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
                    max_joltage_part1 = d1 * 10 + d2
                    found = True
                    break

            if found:
                break

        total_joltage_part1 += max_joltage_part1

        # Part 2: choose exactly 12 digits to form the largest possible number
        digits = line
        target_length = 12
        chosen = []
        start = 0

        for pos in range(target_length):
            remaining_needed = target_length - pos - 1
            best_digit = None
            best_index = -1

            for d in range(9, -1, -1):
                ch = str(d)
                last_index = digits.rfind(ch, start)
                if last_index == -1:
                    continue

                if last_index <= len(digits) - 1 - remaining_needed:
                    best_digit = ch
                    best_index = last_index
                    break

            if best_index == -1:
                best_digit = digits[start]
                best_index = start

            chosen.append(best_digit)
            start = best_index + 1

        line_joltage_part2 = int("".join(chosen))
        total_joltage_part2 += line_joltage_part2

print(f"Day 03 Part 1: {total_joltage_part1}")
print(f"Day 03 Part 2: {total_joltage_part2}")
