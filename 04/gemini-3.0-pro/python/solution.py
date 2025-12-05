import sys

def solve():
    try:
        with open("input.txt") as f:
            lines = [list(line.strip()) for line in f.readlines()]
    except FileNotFoundError:
        print("Error: input.txt not found")
        return

    rows = len(lines)
    cols = len(lines[0]) if rows > 0 else 0

    total_removed = 0
    iteration = 0

    while True:
        iteration += 1
        to_remove = []

        for r in range(rows):
            for c in range(cols):
                if lines[r][c] == '@':
                    neighbor_count = 0
                    for dr in [-1, 0, 1]:
                        for dc in [-1, 0, 1]:
                            if dr == 0 and dc == 0:
                                continue

                            nr, nc = r + dr, c + dc

                            if 0 <= nr < rows and 0 <= nc < cols:
                                if lines[nr][nc] == '@':
                                    neighbor_count += 1

                    if neighbor_count < 4:
                        to_remove.append((r, c))

        if not to_remove:
            break

        if iteration == 1:
            print(f"Day 04 Part 1: {len(to_remove)}")

        total_removed += len(to_remove)

        for r, c in to_remove:
            lines[r][c] = '.'

    print(f"Day 04 Part 2: {total_removed}")

if __name__ == "__main__":
    solve()
