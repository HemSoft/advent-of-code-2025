def parse_input(path: str):
    with open(path, "r", encoding="utf-8") as f:
        lines = [line.rstrip("\r\n") for line in f]

    shape_sizes: dict[int, int] = {}
    region_lines: list[str] = []
    current_shape_id: int | None = None
    current_shape_count = 0

    for line in lines:
        if not line.strip():
            continue

        if line[0].isdigit() and ":" in line and "x" not in line:
            if current_shape_id is not None:
                shape_sizes[current_shape_id] = current_shape_count
            current_shape_id = int(line.split(":", 1)[0])
            current_shape_count = 0
        elif "x" in line and ":" in line:
            if current_shape_id is not None:
                shape_sizes[current_shape_id] = current_shape_count
                current_shape_id = None
                current_shape_count = 0
            region_lines.append(line.strip())
        elif current_shape_id is not None and ("#" in line or "." in line):
            current_shape_count += line.count("#")

    if current_shape_id is not None:
        shape_sizes[current_shape_id] = current_shape_count

    return shape_sizes, region_lines


def solve_part1(path: str) -> int:
    shape_sizes, region_lines = parse_input(path)

    count_fit = 0

    for region_line in region_lines:
        size_part, counts_part = region_line.split(":", 1)
        size_part = size_part.strip()
        counts_part = counts_part.strip()

        width_str, height_str = size_part.split("x")
        width = int(width_str)
        height = int(height_str)

        counts = [int(x) for x in counts_part.split() if x]

        total_cells_needed = 0
        for shape_id, c in enumerate(counts):
            if c == 0:
                continue
            total_cells_needed += c * shape_sizes[shape_id]

        grid_area = width * height
        if total_cells_needed <= grid_area:
            count_fit += 1

    return count_fit


if __name__ == "__main__":
    part1 = solve_part1("input.txt")
    print(f"Day 12 Part 1: {part1}")

    # Part 2 placeholder
    part2 = 0
    print(f"Day 12 Part 2: {part2}")
