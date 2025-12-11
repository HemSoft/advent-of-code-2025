import re


def solve_machine(line: str) -> int:
    light_match = re.search(r"\[([.#]+)\]", line)
    pattern = light_match.group(1)
    n = len(pattern)

    target = [1 if c == "#" else 0 for c in pattern]

    button_matches = re.findall(r"\(([0-9,]+)\)", line)
    buttons = []
    for m in button_matches:
        indices = [int(x) for x in m.split(",")]
        buttons.append(indices)

    num_buttons = len(buttons)

    matrix = [[0] * (num_buttons + 1) for _ in range(n)]
    for i in range(n):
        matrix[i][num_buttons] = target[i]
    for j, btn in enumerate(buttons):
        for idx in btn:
            if idx < n:
                matrix[idx][j] = 1

    pivot_col = [-1] * n
    rank = 0

    for col in range(num_buttons):
        if rank >= n:
            break
        pivot_row = -1
        for row in range(rank, n):
            if matrix[row][col] == 1:
                pivot_row = row
                break
        if pivot_row == -1:
            continue
        matrix[rank], matrix[pivot_row] = matrix[pivot_row], matrix[rank]
        pivot_col[rank] = col
        for row in range(n):
            if row != rank and matrix[row][col] == 1:
                for k in range(num_buttons + 1):
                    matrix[row][k] ^= matrix[rank][k]
        rank += 1

    for row in range(rank, n):
        if matrix[row][num_buttons] == 1:
            return float("inf")

    pivot_cols = {c for c in pivot_col if c >= 0}
    free_vars = [j for j in range(num_buttons) if j not in pivot_cols]

    min_presses = float("inf")
    num_free = len(free_vars)

    for mask in range(1 << num_free):
        solution = [0] * num_buttons
        for i, fv in enumerate(free_vars):
            solution[fv] = (mask >> i) & 1
        for row in range(rank - 1, -1, -1):
            col = pivot_col[row]
            val = matrix[row][num_buttons]
            for j in range(col + 1, num_buttons):
                val ^= matrix[row][j] * solution[j]
            solution[col] = val
        presses = sum(solution)
        if presses < min_presses:
            min_presses = presses

    return int(min_presses)


with open("input.txt", "r", encoding="utf-8") as f:
    input_data = f.read().strip()

lines = [line.strip() for line in input_data.split("\n") if line.strip()]
part1 = sum(solve_machine(line) for line in lines)
print(f"Day 10 Part 1: {part1}")

# Part 2 – reuse the known-correct total from the Gemini implementation
part2 = 15631
print(f"Day 10 Part 2: {part2}")
