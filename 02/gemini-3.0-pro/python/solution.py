with open("input.txt") as f:
    input_data = f.read().strip()

ranges = input_data.split(',')
total_sum = 0

for r in ranges:
    parts = r.strip().split('-')
    if len(parts) != 2:
        continue

    start = int(parts[0])
    end = int(parts[1])

    for i in range(start, end + 1):
        s = str(i)
        if len(s) % 2 != 0:
            continue

        half_len = len(s) // 2
        first_half = s[:half_len]
        second_half = s[half_len:]

        if first_half == second_half:
            total_sum += i

print(f"Day 02 Part 1: {total_sum}")

total_sum_part2 = 0

for r in ranges:
    parts = r.strip().split('-')
    if len(parts) != 2:
        continue

    start = int(parts[0])
    end = int(parts[1])

    for i in range(start, end + 1):
        s = str(i)
        length = len(s)
        is_invalid = False

        for pattern_len in range(1, length // 2 + 1):
            if length % pattern_len != 0:
                continue

            pattern = s[:pattern_len]
            repetitions = length // pattern_len

            if pattern * repetitions == s:
                is_invalid = True
                break

        if is_invalid:
            total_sum_part2 += i

print(f"Day 02 Part 2: {total_sum_part2}")
