import sys

def solve():
    try:
        with open("input.txt", "r") as f:
            lines = [line.rstrip('\n') for line in f]
    except FileNotFoundError:
        print("Error: input.txt not found")
        return

    if not lines:
        return

    width = len(lines[0])
    height = len(lines)

    # Find S
    start_col = -1
    start_row = -1
    for r in range(height):
        if 'S' in lines[r]:
            start_col = lines[r].index('S')
            start_row = r
            break

    if start_col == -1:
        print("Start not found")
        return

    active_beams = {start_col}
    total_splits = 0

    for r in range(start_row + 1, height):
        next_beams = set()
        line = lines[r]

        # Filter active beams that are out of bounds (just in case)
        current_beams = {c for c in active_beams if 0 <= c < width}

        if not current_beams:
            break

        for c in current_beams:
            char = line[c]
            if char == '^':
                total_splits += 1
                if c - 1 >= 0:
                    next_beams.add(c - 1)
                if c + 1 < width:
                    next_beams.add(c + 1)
            else:
                # Pass through '.' or any other char (like 'S' if it appeared lower, though unlikely)
                next_beams.add(c)

        active_beams = next_beams

    print(f"Day 07 Part 1: {total_splits}")

    # Part 2
    memo = {}

    def count_paths(r, c):
        # Check bounds - if out of bounds, it's a valid exit (1 timeline)
        if c < 0 or c >= width:
            return 1

        state = (r, c)
        if state in memo:
            return memo[state]

        # Scan downwards from r+1
        for curr_r in range(r + 1, height):
            char = lines[curr_r][c]
            if char == '^':
                # Split
                # The beam splits to (curr_r, c-1) and (curr_r, c+1)
                # And continues downwards from there (so next scan starts at curr_r + 1)
                res = count_paths(curr_r, c - 1) + count_paths(curr_r, c + 1)
                memo[state] = res
                return res

        # Reached bottom
        memo[state] = 1
        return 1

    part2_ans = count_paths(start_row, start_col)
    print(f"Day 07 Part 2: {part2_ans}")

if __name__ == "__main__":
    solve()
