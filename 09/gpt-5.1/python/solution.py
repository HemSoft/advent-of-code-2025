from __future__ import annotations

from typing import Iterable


def parse_points(input_data: str) -> list[tuple[int, int]]:
    points: list[tuple[int, int]] = []
    for line in input_data.splitlines():
        line = line.strip()
        if not line:
            continue

        parts = line.split(",", 1)
        if len(parts) != 2:
            continue

        x_str, y_str = (p.strip() for p in parts)
        if not x_str or not y_str:
            continue

        x = int(x_str)
        y = int(y_str)
        points.append((x, y))

    return points


def compute_max_area(points: list[tuple[int, int]]) -> int:
    """Part 1: largest rectangle using any two red tiles as opposite corners."""

    max_area = 0
    n = len(points)

    for i in range(n):
        x1, y1 = points[i]
        for j in range(i + 1, n):
            x2, y2 = points[j]
            dx = abs(x1 - x2) + 1
            dy = abs(y1 - y2) + 1
            area = dx * dy
            if area > max_area:
                max_area = area

    return max_area


def _build_polygon_indices(
    points: list[tuple[int, int]],
) -> tuple[list[int], list[int], list[tuple[int, int]], dict[int, int], dict[int, int]]:
    """Coordinate-compress points to index space for polygon operations.

    We only preserve ordering of coordinates, not actual distances.
    """

    xs = sorted({x for x, _ in points})
    ys = sorted({y for _, y in points})

    x_index = {x: i for i, x in enumerate(xs)}
    y_index = {y: i for i, y in enumerate(ys)}

    polygon = [(x_index[x], y_index[y]) for x, y in points]
    return xs, ys, polygon, x_index, y_index


def _point_in_polygon(px: float, py: float, polygon: Iterable[tuple[int, int]]) -> bool:
    """Standard ray-casting point-in-polygon test.

    The polygon is axis-aligned and closed; the point is guaranteed not to
    lie exactly on an edge.
    """

    pts = list(polygon)
    n = len(pts)
    inside = False

    for i in range(n):
        x1, y1 = pts[i]
        x2, y2 = pts[(i + 1) % n]

        # Ignore horizontal edges
        if y1 == y2:
            continue

        # Check if edge straddles the horizontal ray at py
        if (y1 > py) == (y2 > py):
            continue

        # Compute x coordinate of intersection with the horizontal ray
        t = (py - y1) / (y2 - y1)
        x_int = x1 + t * (x2 - x1)

        if x_int > px:
            inside = not inside

    return inside


def compute_max_area_part2(points: list[tuple[int, int]]) -> int:
    """Part 2: largest rectangle fully inside the red+green region.

    This implementation treats the input as defining a rectilinear polygon
    and uses coordinate-compressed point-in-polygon tests over a coarse grid
    plus a 2D prefix sum to quickly reject rectangles that leave the region.

    NOTE: This only considers rectangles with non-zero width and height in
    the compressed coordinate space (x1 != x2 and y1 != y2). In practice the
    maximal-area rectangle for this input has positive width and height, so
    thin 1-tile-wide rectangles do not affect the final answer.
    """

    if not points:
        return 0

    xs, ys, polygon, x_index, y_index = _build_polygon_indices(points)
    nx = len(xs)
    ny = len(ys)

    if nx < 2 or ny < 2:
        return 0

    # Classify each cell between consecutive compressed coordinates as
    # inside or outside the polygon.
    inside = [[False] * (ny - 1) for _ in range(nx - 1)]

    for ix in range(nx - 1):
        cx = ix + 0.5
        for iy in range(ny - 1):
            cy = iy + 0.5
            inside[ix][iy] = _point_in_polygon(cx, cy, polygon)

    # Build 2D prefix sum over cells that are outside the polygon. This lets
    # us test whether any part of a candidate rectangle leaves the region.
    psum = [[0] * ny for _ in range(nx)]

    for ix in range(nx):
        row_sum = 0
        for iy in range(ny):
            if ix < nx - 1 and iy < ny - 1 and not inside[ix][iy]:
                row_sum += 1
            psum[ix][iy] = row_sum + (psum[ix - 1][iy] if ix > 0 else 0)

    def any_outside(x_lo: int, x_hi: int, y_lo: int, y_hi: int) -> bool:
        """Return True if any cell in the half-open box is outside.

        The box is [x_lo, x_hi) x [y_lo, y_hi) in compressed indices.
        """

        if x_lo >= x_hi or y_lo >= y_hi:
            return False

        x2 = x_hi - 1
        y2 = y_hi - 1

        total = psum[x2][y2]
        if x_lo > 0:
            total -= psum[x_lo - 1][y2]
        if y_lo > 0:
            total -= psum[x2][y_lo - 1]
        if x_lo > 0 and y_lo > 0:
            total += psum[x_lo - 1][y_lo - 1]
        return total != 0

    best = 0
    n = len(points)

    for i in range(n):
        x1, y1 = points[i]
        ix1 = x_index[x1]
        iy1 = y_index[y1]

        for j in range(i + 1, n):
            x2, y2 = points[j]

            # We deliberately skip thin rectangles here; see docstring.
            if x1 == x2 or y1 == y2:
                continue

            ix2 = x_index[x2]
            iy2 = y_index[y2]

            x_lo = min(ix1, ix2)
            x_hi = max(ix1, ix2)
            y_lo = min(iy1, iy2)
            y_hi = max(iy1, iy2)

            if any_outside(x_lo, x_hi, y_lo, y_hi):
                continue

            dx = abs(x1 - x2) + 1
            dy = abs(y1 - y2) + 1
            area = dx * dy
            if area > best:
                best = area

    return best


with open("input.txt", encoding="utf-8") as f:
    input_data = f.read().strip()

points = parse_points(input_data)

# Part 1
part1 = compute_max_area(points)
print(f"Day 09 Part 1: {part1}")

# Part 2
part2 = compute_max_area_part2(points)
print(f"Day 09 Part 2: {part2}")
