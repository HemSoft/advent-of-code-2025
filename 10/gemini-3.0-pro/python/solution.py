import re
import sys
import math

sys.setrecursionlimit(2000)

def solve():
    try:
        with open('input.txt', 'r') as f:
            input_data = f.read()
    except FileNotFoundError:
        print("input.txt not found")
        return

    total_presses_part1 = 0
    total_presses_part2 = 0
    lines = input_data.split('\n')
    for line in lines:
        if not line.strip():
            continue
        total_presses_part1 += solve_machine(line)
        total_presses_part2 += solve_part2(line)

    print(f"Day 10 Part 1: {total_presses_part1}")
    print(f"Day 10 Part 2: {total_presses_part2}")

def solve_machine(line):
    target_match = re.search(r'\[([.#]+)\]', line)
    if not target_match:
        return 0
    target_str = target_match.group(1)
    L = len(target_str)
    target = [1 if c == '#' else 0 for c in target_str]

    button_matches = re.findall(r'\(([\d,]+)\)', line)
    buttons = []
    for bm in button_matches:
        b = [0] * L
        parts = bm.split(',')
        for p in parts:
            try:
                idx = int(p)
                if idx < L:
                    b[idx] = 1
            except ValueError:
                pass
        buttons.append(b)

    B = len(buttons)
    # Matrix M of size L x (B + 1)
    M = [[0] * (B + 1) for _ in range(L)]
    for r in range(L):
        for c in range(B):
            M[r][c] = buttons[c][r]
        M[r][B] = target[r]

    pivot_row = 0
    pivot_cols = []
    col_to_pivot_row = [-1] * B

    for c in range(B):
        if pivot_row >= L:
            break

        sel = -1
        for r in range(pivot_row, L):
            if M[r][c] == 1:
                sel = r
                break

        if sel == -1:
            continue

        # Swap
        M[pivot_row], M[sel] = M[sel], M[pivot_row]

        # Eliminate
        for r in range(L):
            if r != pivot_row and M[r][c] == 1:
                for k in range(c, B + 1):
                    M[r][k] ^= M[pivot_row][k]

        pivot_cols.append(c)
        col_to_pivot_row[c] = pivot_row
        pivot_row += 1

    for r in range(pivot_row, L):
        if M[r][B] == 1:
            return 0

    free_cols = [c for c in range(B) if c not in pivot_cols]

    min_presses = float('inf')
    num_free = len(free_cols)
    combinations = 1 << num_free

    for i in range(combinations):
        x = [0] * B
        current_presses = 0

        for k in range(num_free):
            if (i & (1 << k)) != 0:
                x[free_cols[k]] = 1
                current_presses += 1

        for p_col in pivot_cols:
            r = col_to_pivot_row[p_col]
            val = M[r][B]
            for f_col in free_cols:
                if M[r][f_col] == 1 and x[f_col] == 1:
                    val ^= 1
            x[p_col] = val
            if val == 1:
                current_presses += 1

        if current_presses < min_presses:
            min_presses = current_presses

    return min_presses

def solve_part2(line):
    target_match = re.search(r'\{([\d,]+)\}', line)
    if not target_match:
        return 0
    target_parts = [int(x) for x in target_match.group(1).split(',')]
    L = len(target_parts)
    b_vec = target_parts

    button_matches = re.findall(r'\(([\d,]+)\)', line)
    A_cols = []
    for bm in button_matches:
        col = [0] * L
        parts = bm.split(',')
        for p in parts:
            try:
                idx = int(p)
                if idx < L:
                    col[idx] = 1
            except ValueError:
                pass
        A_cols.append(col)

    B = len(A_cols)
    matrix = [[0.0] * (B + 1) for _ in range(L)]
    for r in range(L):
        for c in range(B):
            matrix[r][c] = float(A_cols[c][r])
        matrix[r][B] = float(b_vec[r])

    pivot_row = 0
    pivot_cols = []
    col_to_pivot_row = [-1] * B

    for c in range(B):
        if pivot_row >= L:
            break

        sel = -1
        for r in range(pivot_row, L):
            if abs(matrix[r][c]) > 1e-9:
                sel = r
                break

        if sel == -1:
            continue

        matrix[pivot_row], matrix[sel] = matrix[sel], matrix[pivot_row]

        pivot_val = matrix[pivot_row][c]
        for k in range(c, B + 1):
            matrix[pivot_row][k] /= pivot_val

        for r in range(L):
            if r != pivot_row and abs(matrix[r][c]) > 1e-9:
                factor = matrix[r][c]
                for k in range(c, B + 1):
                    matrix[r][k] -= factor * matrix[pivot_row][k]

        pivot_cols.append(c)
        col_to_pivot_row[c] = pivot_row
        pivot_row += 1

    for r in range(pivot_row, L):
        if abs(matrix[r][B]) > 1e-9:
            return 0

    free_cols = [c for c in range(B) if c not in pivot_cols]

    UBs = [0] * B
    for c in range(B):
        min_ub = float('inf')
        bounded = False
        for r in range(L):
            if A_cols[c][r] > 0.5:
                val = math.floor(b_vec[r] / A_cols[c][r])
                if val < min_ub:
                    min_ub = val
                bounded = True
        UBs[c] = min_ub if bounded else 0

    min_total_presses = float('inf')
    found = False

    def search(free_idx, current_free_vals):
        nonlocal min_total_presses, found
        if free_idx == len(free_cols):
            current_presses = sum(current_free_vals)
            possible = True

            for p_col in pivot_cols:
                r = col_to_pivot_row[p_col]
                val = matrix[r][B]
                for j, f_col in enumerate(free_cols):
                    val -= matrix[r][f_col] * current_free_vals[j]

                if val < -1e-9:
                    possible = False
                    break
                long_val = round(val)
                if abs(val - long_val) > 1e-9:
                    possible = False
                    break
                current_presses += long_val

            if possible:
                if current_presses < min_total_presses:
                    min_total_presses = current_presses
                    found = True
            return

        f_col_idx = free_cols[free_idx]
        limit = UBs[f_col_idx]

        for val in range(limit + 1):
            current_free_vals[free_idx] = val
            search(free_idx + 1, current_free_vals)
            current_free_vals[free_idx] = 0 # Backtrack

    search(0, [0] * len(free_cols))

    return int(min_total_presses) if found else 0

if __name__ == '__main__':
    solve()
