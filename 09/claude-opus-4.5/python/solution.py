with open("input.txt") as f:
    lines = [line.strip() for line in f if line.strip()]

tiles = []
for line in lines:
    x, y = map(int, line.split(','))
    tiles.append((x, y))

# Part 1: Find largest rectangle with two red tiles as opposite corners
max_area = 0

for i in range(len(tiles)):
    for j in range(i + 1, len(tiles)):
        width = abs(tiles[j][0] - tiles[i][0]) + 1
        height = abs(tiles[j][1] - tiles[i][1]) + 1
        area = width * height
        if area > max_area:
            max_area = area

print(f"Day 09 Part 1: {max_area}")

# Part 2: Find largest rectangle using only red and green tiles
# Build polygon edges
edges = []
for i in range(len(tiles)):
    curr = tiles[i]
    next_tile = tiles[(i + 1) % len(tiles)]
    edges.append((curr, next_tile))

def is_on_segment(px, py, x1, y1, x2, y2):
    if x1 == x2:  # vertical
        return px == x1 and min(y1, y2) <= py <= max(y1, y2)
    if y1 == y2:  # horizontal
        return py == y1 and min(x1, x2) <= px <= max(x1, x2)
    return False

def is_inside_polygon(px, py, edges):
    crossings = 0
    for (p1, p2) in edges:
        x1, y1 = p1
        x2, y2 = p2
        if (y1 <= py < y2) or (y2 <= py < y1):
            x_intersect = x1 + (py - y1) * (x2 - x1) / (y2 - y1)
            if px < x_intersect:
                crossings += 1
    return crossings % 2 == 1

def is_valid_point(px, py, edges, tiles):
    if (px, py) in tiles:
        return True
    for (p1, p2) in edges:
        if is_on_segment(px, py, p1[0], p1[1], p2[0], p2[1]):
            return True
    return is_inside_polygon(px, py, edges)

def direction(x1, y1, x2, y2, x3, y3):
    return (x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1)

def segments_intersect(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2):
    d1 = direction(bx1, by1, bx2, by2, ax1, ay1)
    d2 = direction(bx1, by1, bx2, by2, ax2, ay2)
    d3 = direction(ax1, ay1, ax2, ay2, bx1, by1)
    d4 = direction(ax1, ay1, ax2, ay2, bx2, by2)
    if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and \
       ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
        return True
    return False

def get_intersection(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2):
    d = (ax2 - ax1) * (by2 - by1) - (ay2 - ay1) * (bx2 - bx1)
    if abs(d) < 1e-10:
        return None
    t = ((bx1 - ax1) * (by2 - by1) - (by1 - ay1) * (bx2 - bx1)) / d
    return (ax1 + t * (ax2 - ax1), ay1 + t * (ay2 - ay1))

def edge_crosses_rect_interior(x1, y1, x2, y2, min_x, max_x, min_y, max_y):
    p1_inside = min_x <= x1 <= max_x and min_y <= y1 <= max_y
    p2_inside = min_x <= x2 <= max_x and min_y <= y2 <= max_y
    if p1_inside and p2_inside:
        return False
    
    # Top edge
    if segments_intersect(x1, y1, x2, y2, min_x, min_y, max_x, min_y):
        intersect = get_intersection(x1, y1, x2, y2, min_x, min_y, max_x, min_y)
        if intersect and min_x < intersect[0] < max_x:
            return True
    # Bottom edge
    if segments_intersect(x1, y1, x2, y2, min_x, max_y, max_x, max_y):
        intersect = get_intersection(x1, y1, x2, y2, min_x, max_y, max_x, max_y)
        if intersect and min_x < intersect[0] < max_x:
            return True
    # Left edge
    if segments_intersect(x1, y1, x2, y2, min_x, min_y, min_x, max_y):
        intersect = get_intersection(x1, y1, x2, y2, min_x, min_y, min_x, max_y)
        if intersect and min_y < intersect[1] < max_y:
            return True
    # Right edge
    if segments_intersect(x1, y1, x2, y2, max_x, min_y, max_x, max_y):
        intersect = get_intersection(x1, y1, x2, y2, max_x, min_y, max_x, max_y)
        if intersect and min_y < intersect[1] < max_y:
            return True
    return False

def is_rectangle_valid(min_x, max_x, min_y, max_y, edges, tiles):
    for (p1, p2) in edges:
        if edge_crosses_rect_interior(p1[0], p1[1], p2[0], p2[1], min_x, max_x, min_y, max_y):
            return False
    return True

tiles_set = set(tiles)
max_area2 = 0

for i in range(len(tiles)):
    for j in range(i + 1, len(tiles)):
        t1, t2 = tiles[i], tiles[j]
        min_x, max_x = min(t1[0], t2[0]), max(t1[0], t2[0])
        min_y, max_y = min(t1[1], t2[1]), max(t1[1], t2[1])
        
        corners = [(min_x, min_y), (min_x, max_y), (max_x, min_y), (max_x, max_y)]
        if all(is_valid_point(c[0], c[1], edges, tiles_set) for c in corners):
            if is_rectangle_valid(min_x, max_x, min_y, max_y, edges, tiles_set):
                area = (max_x - min_x + 1) * (max_y - min_y + 1)
                if area > max_area2:
                    max_area2 = area

print(f"Day 09 Part 2: {max_area2}")