from __future__ import annotations

from typing import Iterable


def solve_part1(lines: Iterable[str]) -> int:
    """Compute how many times the tachyon beam is split (Part 1).

    A beam starts at the cell marked 'S' and always moves downward. When it
    reaches a splitter '^', the current beam stops and two new beams are
    created from the immediate left and right of the splitter, both continuing
    downward. Beams that move outside the grid simply disappear.

    Multiple beams can occupy the same cell, but they are merged so that a
    given cell only ever produces a single continuation in the next row. The
    answer is the total number of times any beam encounters a splitter.
    """

    # Materialize lines and handle empty input.
    grid_lines = [line.rstrip("\n") for line in lines]
    if not grid_lines:
        return 0

    height = len(grid_lines)
    width = max(len(line) for line in grid_lines)

    # Pad rows to equal width so we can index safely by column.
    grid = [line.ljust(width, ".") for line in grid_lines]

    # Locate the start position 'S'.
    start_row = -1
    start_col = -1
    for r, row in enumerate(grid):
        c = row.find("S")
        if c != -1:
            start_row, start_col = r, c
            break

    if start_row == -1:
        # No start found; nothing happens.
        return 0

    # Each beam is represented by its current (row, col) position.
    current = {(start_row, start_col)}
    splits = 0

    while current:
        next_beams: set[tuple[int, int]] = set()

        for r, c in current:
            nr = r + 1
            if nr >= height:
                # Beam has exited the bottom of the grid.
                continue

            cell = grid[nr][c]
            if cell == "^":
                # Beam is split: the current beam stops, two new beams
                # continue from the immediate left and right of the splitter.
                splits += 1

                if c - 1 >= 0:
                    next_beams.add((nr, c - 1))
                if c + 1 < width:
                    next_beams.add((nr, c + 1))
            else:
                # Continue straight downward.
                next_beams.add((nr, c))

        current = next_beams

    return splits


def solve_part2(lines: Iterable[str]) -> int:
    """Compute how many timelines a single particle ends up on (Part 2).

    Here, a single tachyon particle travels through the manifold. Each time it
    reaches a splitter (^), time itself splits so that in one timeline the
    particle goes left and in the other it goes right. Timelines are tracked
    separately even if they later occupy the same cell.

    The answer is the total number of distinct timelines after all possible
    journeys through the manifold have completed.
    """

    grid_lines = [line.rstrip("\n") for line in lines]
    if not grid_lines:
        return 0

    height = len(grid_lines)
    width = max(len(line) for line in grid_lines)

    grid = [line.ljust(width, ".") for line in grid_lines]

    start_row = -1
    start_col = -1
    for r, row in enumerate(grid):
        c = row.find("S")
        if c != -1:
            start_row, start_col = r, c
            break

    if start_row == -1:
        return 0

    # Map of (row, col) -> number of timelines currently at that cell.
    current: dict[tuple[int, int], int] = {(start_row, start_col): 1}
    finished_timelines = 0

    while current:
        next_beams: dict[tuple[int, int], int] = {}

        for (r, c), count in current.items():
            nr = r + 1
            if nr >= height:
                # These timelines exit the manifold here.
                finished_timelines += count
                continue

            cell = grid[nr][c]
            if cell == "^":
                # Each timeline splits into two, one going left and one right
                # (if within bounds).
                if c - 1 >= 0:
                    next_beams[(nr, c - 1)] = next_beams.get((nr, c - 1), 0) + count
                if c + 1 < width:
                    next_beams[(nr, c + 1)] = next_beams.get((nr, c + 1), 0) + count
            else:
                # Timelines continue straight downward, preserving count.
                key = (nr, c)
                next_beams[key] = next_beams.get(key, 0) + count

        current = next_beams

    return finished_timelines


if __name__ == "__main__":
    with open("input.txt", encoding="utf-8") as f:
        raw_lines = f.read().splitlines()

    part1 = solve_part1(raw_lines)
    print(f"Day 07 Part 1: {part1}")

    part2 = solve_part2(raw_lines)
    print(f"Day 07 Part 2: {part2}")