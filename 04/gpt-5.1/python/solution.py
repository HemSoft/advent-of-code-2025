from __future__ import annotations


def parse_lines(raw: str) -> list[str]:
    lines = [line.strip() for line in raw.splitlines() if line.strip()]
    return lines


def count_accessible_rolls(grid: list[str]) -> int:
    height = len(grid)
    if height == 0:
        return 0

    width = len(grid[0])
    accessible = 0

    d_rows = (-1, -1, -1, 0, 0, 1, 1, 1)
    d_cols = (-1, 0, 1, -1, 1, -1, 0, 1)

    for r in range(height):
        row = grid[r]
        for c in range(width):
            if row[c] != "@":
                continue

            neighbors = 0
            for dr, dc in zip(d_rows, d_cols):
                nr = r + dr
                nc = c + dc
                if nr < 0 or nr >= height or nc < 0 or nc >= width:
                    continue
                if grid[nr][nc] == "@":
                    neighbors += 1

            if neighbors < 4:
                accessible += 1

    return accessible


def count_total_removed(grid: list[str]) -> int:
    height = len(grid)
    if height == 0:
        return 0

    width = len(grid[0])
    board = [list(row) for row in grid]

    d_rows = (-1, -1, -1, 0, 0, 1, 1, 1)
    d_cols = (-1, 0, 1, -1, 1, -1, 0, 1)

    total_removed = 0

    while True:
        to_remove: list[tuple[int, int]] = []

        for r in range(height):
            for c in range(width):
                if board[r][c] != "@":
                    continue

                neighbors = 0
                for dr, dc in zip(d_rows, d_cols):
                    nr = r + dr
                    nc = c + dc
                    if nr < 0 or nr >= height or nc < 0 or nc >= width:
                        continue
                    if board[nr][nc] == "@":
                        neighbors += 1

                if neighbors < 4:
                    to_remove.append((r, c))

        if not to_remove:
            break

        for r, c in to_remove:
            board[r][c] = "."

        total_removed += len(to_remove)

    return total_removed


with open("input.txt", encoding="utf-8") as f:
    input_data = f.read()

lines = parse_lines(input_data)

# Part 1
part1 = count_accessible_rolls(lines)
print(f"Day 04 Part 1: {part1}")

# Part 2
part2 = count_total_removed(lines)
print(f"Day 04 Part 2: {part2}")
