import sys

def main():
    try:
        with open("input.txt", "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print("Error: input.txt not found.")
        return

    points = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        x, y = map(int, line.split(','))
        points.append((x, y))

    max_area_part1 = 0
    max_area_part2 = 0
    n = len(points)

    # Build edges for Part 2
    edges = []
    for i in range(n):
        p1 = points[i]
        p2 = points[(i + 1) % n]
        edges.append((p1, p2))

    def is_point_in_polygon(x, y):
        inside = False
        for p1, p2 in edges:
            if (p1[1] > y) != (p2[1] > y):
                intersect_x = (p2[0] - p1[0]) * (y - p1[1]) / (p2[1] - p1[1]) + p1[0]
                if x < intersect_x:
                    inside = not inside
        return inside

    def is_valid(p1, p2):
        x1, x2 = min(p1[0], p2[0]), max(p1[0], p2[0])
        y1, y2 = min(p1[1], p2[1]), max(p1[1], p2[1])

        cx = (x1 + x2) / 2
        cy = (y1 + y2) / 2
        if not is_point_in_polygon(cx, cy):
            return False

        for ep1, ep2 in edges:
            if ep1[0] == ep2[0]: # Vertical
                ex = ep1[0]
                ey_min, ey_max = min(ep1[1], ep2[1]), max(ep1[1], ep2[1])
                if x1 < ex < x2:
                    overlap_min = max(y1, ey_min)
                    overlap_max = min(y2, ey_max)
                    if overlap_min < overlap_max:
                        return False
            elif ep1[1] == ep2[1]: # Horizontal
                ey = ep1[1]
                ex_min, ex_max = min(ep1[0], ep2[0]), max(ep1[0], ep2[0])
                if y1 < ey < y2:
                    overlap_min = max(x1, ex_min)
                    overlap_max = min(x2, ex_max)
                    if overlap_min < overlap_max:
                        return False
        return True

    for i in range(n):
        for j in range(i + 1, n):
            p1 = points[i]
            p2 = points[j]

            width = abs(p1[0] - p2[0]) + 1
            height = abs(p1[1] - p2[1]) + 1
            area = width * height

            if area > max_area_part1:
                max_area_part1 = area

            if is_valid(p1, p2):
                if area > max_area_part2:
                    max_area_part2 = area

    print(f"Day 09 Part 1: {max_area_part1}")
    print(f"Day 09 Part 2: {max_area_part2}")

if __name__ == "__main__":
    main()
