with open("input.txt") as f:
    lines = [line.strip() for line in f if line.strip()]

def max_joltage(line: str) -> int:
    n = len(line)
    if n < 2:
        return 0

    # Precompute suffix maximum
    suffix_max = [0] * n
    for i in range(n - 2, -1, -1):
        digit = int(line[i + 1])
        suffix_max[i] = max(digit, suffix_max[i + 1])

    # Find max joltage
    max_j = 0
    for i in range(n - 1):
        tens_digit = int(line[i])
        units_digit = suffix_max[i]
        joltage = tens_digit * 10 + units_digit
        max_j = max(max_j, joltage)

    return max_j

def max_joltage_part2(line: str, k: int = 12) -> int:
    n = len(line)
    if n < k:
        return 0
    if n == k:
        return int(line)

    # Greedy: pick k digits to form largest number
    result = []
    start_idx = 0

    for i in range(k):
        remaining = k - i
        end_idx = n - remaining

        max_digit = '0'
        max_pos = start_idx

        for j in range(start_idx, end_idx + 1):
            if line[j] > max_digit:
                max_digit = line[j]
                max_pos = j

        result.append(max_digit)
        start_idx = max_pos + 1

    return int(''.join(result))

# Part 1
part1 = sum(max_joltage(line) for line in lines)
print(f"Day 03 Part 1: {part1}")

# Part 2
part2 = sum(max_joltage_part2(line) for line in lines)
print(f"Day 03 Part 2: {part2}")
