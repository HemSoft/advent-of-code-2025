with open("input.txt") as f:
    input_data = f.read().strip()

def is_invalid_id_part1(num: int) -> bool:
    s = str(num)
    if len(s) % 2 != 0:
        return False
    half = len(s) // 2
    return s[:half] == s[half:]

def is_invalid_id_part2(num: int) -> bool:
    s = str(num)
    # Check for patterns repeated at least twice
    for pattern_len in range(1, len(s) // 2 + 1):
        if len(s) % pattern_len != 0:
            continue
        pattern = s[:pattern_len]
        repetitions = len(s) // pattern_len
        if repetitions < 2:
            continue
        if pattern * repetitions == s:
            return True
    return False

# Part 1
part1 = 0
for range_str in input_data.split(','):
    if not range_str:
        continue
    start_str, end_str = range_str.split('-')
    start, end = int(start_str), int(end_str)
    for id_num in range(start, end + 1):
        if is_invalid_id_part1(id_num):
            part1 += id_num
print(f"Day 02 Part 1: {part1}")

# Part 2
part2 = 0
for range_str in input_data.split(','):
    if not range_str:
        continue
    start_str, end_str = range_str.split('-')
    start, end = int(start_str), int(end_str)
    for id_num in range(start, end + 1):
        if is_invalid_id_part2(id_num):
            part2 += id_num
print(f"Day 02 Part 2: {part2}")
