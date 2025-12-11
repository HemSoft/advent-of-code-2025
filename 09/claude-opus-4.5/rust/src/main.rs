use std::fs;
use std::collections::HashSet;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");

    let tiles: Vec<(i64, i64)> = input
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            let parts: Vec<&str> = line.split(',').collect();
            (
                parts[0].trim().parse().unwrap(),
                parts[1].trim().parse().unwrap(),
            )
        })
        .collect();

    // Part 1
    let mut max_area: i64 = 0;
    for i in 0..tiles.len() {
        for j in (i + 1)..tiles.len() {
            let width = (tiles[j].0 - tiles[i].0).abs() + 1;
            let height = (tiles[j].1 - tiles[i].1).abs() + 1;
            let area = width * height;
            if area > max_area {
                max_area = area;
            }
        }
    }
    println!("Day 09 Part 1: {}", max_area);

    // Part 2
    let edges: Vec<((i64, i64), (i64, i64))> = (0..tiles.len())
        .map(|i| (tiles[i], tiles[(i + 1) % tiles.len()]))
        .collect();

    let tiles_set: HashSet<(i64, i64)> = tiles.iter().cloned().collect();

    let mut max_area2: i64 = 0;
    for i in 0..tiles.len() {
        for j in (i + 1)..tiles.len() {
            let (t1, t2) = (tiles[i], tiles[j]);
            let min_x = t1.0.min(t2.0);
            let max_x = t1.0.max(t2.0);
            let min_y = t1.1.min(t2.1);
            let max_y = t1.1.max(t2.1);

            let corners = [(min_x, min_y), (min_x, max_y), (max_x, min_y), (max_x, max_y)];
            let all_valid = corners.iter().all(|&(cx, cy)| is_valid_point(cx, cy, &edges, &tiles_set));

            if all_valid && is_rectangle_valid(min_x, max_x, min_y, max_y, &edges) {
                let area = (max_x - min_x + 1) * (max_y - min_y + 1);
                if area > max_area2 {
                    max_area2 = area;
                }
            }
        }
    }
    println!("Day 09 Part 2: {}", max_area2);
}

fn is_on_segment(px: i64, py: i64, x1: i64, y1: i64, x2: i64, y2: i64) -> bool {
    if x1 == x2 {
        px == x1 && py >= y1.min(y2) && py <= y1.max(y2)
    } else if y1 == y2 {
        py == y1 && px >= x1.min(x2) && px <= x1.max(x2)
    } else {
        false
    }
}

fn is_inside_polygon(px: i64, py: i64, edges: &[((i64, i64), (i64, i64))]) -> bool {
    let mut crossings = 0;
    for &((x1, y1), (x2, y2)) in edges {
        if (y1 <= py && y2 > py) || (y2 <= py && y1 > py) {
            let x_intersect = x1 as f64 + (py - y1) as f64 / (y2 - y1) as f64 * (x2 - x1) as f64;
            if (px as f64) < x_intersect {
                crossings += 1;
            }
        }
    }
    crossings % 2 == 1
}

fn is_valid_point(px: i64, py: i64, edges: &[((i64, i64), (i64, i64))], tiles_set: &HashSet<(i64, i64)>) -> bool {
    if tiles_set.contains(&(px, py)) {
        return true;
    }
    for &((x1, y1), (x2, y2)) in edges {
        if is_on_segment(px, py, x1, y1, x2, y2) {
            return true;
        }
    }
    is_inside_polygon(px, py, edges)
}

fn direction(x1: i64, y1: i64, x2: i64, y2: i64, x3: i64, y3: i64) -> f64 {
    (x3 - x1) as f64 * (y2 - y1) as f64 - (x2 - x1) as f64 * (y3 - y1) as f64
}

fn segments_intersect(ax1: i64, ay1: i64, ax2: i64, ay2: i64, bx1: i64, by1: i64, bx2: i64, by2: i64) -> bool {
    let d1 = direction(bx1, by1, bx2, by2, ax1, ay1);
    let d2 = direction(bx1, by1, bx2, by2, ax2, ay2);
    let d3 = direction(ax1, ay1, ax2, ay2, bx1, by1);
    let d4 = direction(ax1, ay1, ax2, ay2, bx2, by2);
    ((d1 > 0.0 && d2 < 0.0) || (d1 < 0.0 && d2 > 0.0)) &&
    ((d3 > 0.0 && d4 < 0.0) || (d3 < 0.0 && d4 > 0.0))
}

fn get_intersection(ax1: i64, ay1: i64, ax2: i64, ay2: i64, bx1: i64, by1: i64, bx2: i64, by2: i64) -> Option<(f64, f64)> {
    let d = (ax2 - ax1) as f64 * (by2 - by1) as f64 - (ay2 - ay1) as f64 * (bx2 - bx1) as f64;
    if d.abs() < 1e-10 {
        return None;
    }
    let t = ((bx1 - ax1) as f64 * (by2 - by1) as f64 - (by1 - ay1) as f64 * (bx2 - bx1) as f64) / d;
    Some((ax1 as f64 + t * (ax2 - ax1) as f64, ay1 as f64 + t * (ay2 - ay1) as f64))
}

fn edge_crosses_rect_interior(x1: i64, y1: i64, x2: i64, y2: i64, min_x: i64, max_x: i64, min_y: i64, max_y: i64) -> bool {
    let p1_inside = x1 >= min_x && x1 <= max_x && y1 >= min_y && y1 <= max_y;
    let p2_inside = x2 >= min_x && x2 <= max_x && y2 >= min_y && y2 <= max_y;
    if p1_inside && p2_inside {
        return false;
    }

    let rect_edges = [
        (min_x, min_y, max_x, min_y),
        (min_x, max_y, max_x, max_y),
        (min_x, min_y, min_x, max_y),
        (max_x, min_y, max_x, max_y),
    ];

    for (i, &(rx1, ry1, rx2, ry2)) in rect_edges.iter().enumerate() {
        if segments_intersect(x1, y1, x2, y2, rx1, ry1, rx2, ry2) {
            if let Some((ix, iy)) = get_intersection(x1, y1, x2, y2, rx1, ry1, rx2, ry2) {
                if i < 2 {
                    if ix > min_x as f64 && ix < max_x as f64 {
                        return true;
                    }
                } else if iy > min_y as f64 && iy < max_y as f64 {
                    return true;
                }
            }
        }
    }
    false
}

fn is_rectangle_valid(min_x: i64, max_x: i64, min_y: i64, max_y: i64, edges: &[((i64, i64), (i64, i64))]) -> bool {
    for &((x1, y1), (x2, y2)) in edges {
        if edge_crosses_rect_interior(x1, y1, x2, y2, min_x, max_x, min_y, max_y) {
            return false;
        }
    }
    true
}