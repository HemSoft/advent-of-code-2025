from __future__ import annotations


def solve(lines: list[str]) -> int:
    """Solve Part 1: compute grand total of all problems.

    The input is a rectangular-ish grid of digits/spaces with the last row
    containing '+' or '*' operators. Problems are separated by columns that
    are entirely spaces.
    """

    if not lines:
        return 0

    height = len(lines)
    width = max(len(line) for line in lines)

    # Pad lines to equal width for safe column access
    grid = [line.rstrip("\n").ljust(width) for line in lines]

    # Identify contiguous column ranges that form individual problems.
    problem_ranges: list[tuple[int, int]] = []
    in_block = False
    start_col = 0

    for x in range(width):
        all_space = True
        for y in range(height):
            if grid[y][x] != " ":
                all_space = False
                break

        if all_space:
            if in_block:
                problem_ranges.append((start_col, x - 1))
                in_block = False
        else:
            if not in_block:
                in_block = True
                start_col = x

    if in_block:
        problem_ranges.append((start_col, width - 1))

    total = 0

    for start, end in problem_ranges:
        # Find operator in bottom row within this range
        op = None
        for x in range(start, end + 1):
            c = grid[height - 1][x]
            if c in ("+", "*"):
                op = c
                break

        if op is None:
            # No operator found; skip malformed block.
            continue

        nums: list[int] = []
        for y in range(height - 1):  # all rows except the operator row
            segment = grid[y][start : end + 1]
            s = segment.strip()
            if not s:
                continue
            nums.append(int(s))

        if not nums:
            continue

        if op == "+":
            value = sum(nums)
        else:  # op == '*'
            value = 1
            for n in nums:
                value *= n

        total += value

    return total


def solve_part2(lines: list[str]) -> int:
    """Solve Part 2: interpret each problem column-wise right-to-left.

    Each contiguous non-space column block is a problem. Within a block, the
    operator is still taken from the bottom row. The operands are now formed
    by reading each column (except the operator row) as a top-to-bottom digit
    string, and columns are processed from right to left.
    """

    if not lines:
        return 0

    height = len(lines)
    width = max(len(line) for line in lines)

    grid = [line.rstrip("\n").ljust(width) for line in lines]

    problem_ranges: list[tuple[int, int]] = []
    in_block = False
    start_col = 0

    for x in range(width):
        all_space = True
        for y in range(height):
            if grid[y][x] != " ":
                all_space = False
                break

        if all_space:
            if in_block:
                problem_ranges.append((start_col, x - 1))
                in_block = False
        else:
            if not in_block:
                in_block = True
                start_col = x

    if in_block:
        problem_ranges.append((start_col, width - 1))

    total = 0

    for start, end in problem_ranges:
        op = None
        for x in range(start, end + 1):
            c = grid[height - 1][x]
            if c in ("+", "*"):
                op = c
                break

        if op is None:
            continue

        nums: list[int] = []

        for x in range(end, start - 1, -1):
            digits: list[str] = []
            for y in range(height - 1):
                c = grid[y][x]
                if c.isdigit():
                    digits.append(c)

            if digits:
                nums.append(int("".join(digits)))

        if not nums:
            continue

        if op == "+":
            value = sum(nums)
        else:
            value = 1
            for n in nums:
                value *= n

        total += value

    return total


if __name__ == "__main__":
    with open("input.txt", encoding="utf-8") as f:
        raw_lines = f.read().splitlines()

    part1 = solve(raw_lines)
    print(f"Day 06 Part 1: {part1}")

    part2 = solve_part2(raw_lines)
    print(f"Day 06 Part 2: {part2}")
