use std::fs;

#[derive(Debug, Clone, Copy)]
struct Point {
    x: i64,
    y: i64,
}

struct Edge {
    p1: Point,
    p2: Point,
}

fn is_point_in_polygon(x: f64, y: f64, edges: &[Edge]) -> bool {
    let mut inside = false;
    for edge in edges {
        let p1 = edge.p1;
        let p2 = edge.p2;
        if (p1.y as f64 > y) != (p2.y as f64 > y) {
            let intersect_x = (p2.x - p1.x) as f64 * (y - p1.y as f64) / (p2.y - p1.y) as f64 + p1.x as f64;
            if x < intersect_x {
                inside = !inside;
            }
        }
    }
    inside
}

fn is_valid(p1: Point, p2: Point, edges: &[Edge]) -> bool {
    let x1 = p1.x.min(p2.x);
    let x2 = p1.x.max(p2.x);
    let y1 = p1.y.min(p2.y);
    let y2 = p1.y.max(p2.y);

    let cx = (x1 + x2) as f64 / 2.0;
    let cy = (y1 + y2) as f64 / 2.0;

    if !is_point_in_polygon(cx, cy, edges) {
        return false;
    }

    for edge in edges {
        let ep1 = edge.p1;
        let ep2 = edge.p2;

        if ep1.x == ep2.x { // Vertical
            let ex = ep1.x;
            let ey_min = ep1.y.min(ep2.y);
            let ey_max = ep1.y.max(ep2.y);
            if x1 < ex && ex < x2 {
                let overlap_min = y1.max(ey_min);
                let overlap_max = y2.min(ey_max);
                if overlap_min < overlap_max {
                    return false;
                }
            }
        } else if ep1.y == ep2.y { // Horizontal
            let ey = ep1.y;
            let ex_min = ep1.x.min(ep2.x);
            let ex_max = ep1.x.max(ep2.x);
            if y1 < ey && ey < y2 {
                let overlap_min = x1.max(ex_min);
                let overlap_max = x2.min(ex_max);
                if overlap_min < overlap_max {
                    return false;
                }
            }
        }
    }
    true
}

fn main() {
    let content = fs::read_to_string("input.txt").expect("Failed to read input file");
    let points: Vec<Point> = content
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            let parts: Vec<&str> = line.split(',').collect();
            Point {
                x: parts[0].parse().unwrap(),
                y: parts[1].parse().unwrap(),
            }
        })
        .collect();

    let mut edges = Vec::new();
    let n = points.len();
    for i in 0..n {
        edges.push(Edge {
            p1: points[i],
            p2: points[(i + 1) % n],
        });
    }

    let mut max_area_part1: i64 = 0;
    let mut max_area_part2: i64 = 0;

    for i in 0..points.len() {
        for j in (i + 1)..points.len() {
            let p1 = points[i];
            let p2 = points[j];

            let width = (p1.x - p2.x).abs() + 1;
            let height = (p1.y - p2.y).abs() + 1;
            let area = width * height;

            if area > max_area_part1 {
                max_area_part1 = area;
            }

            if is_valid(p1, p2, &edges) {
                if area > max_area_part2 {
                    max_area_part2 = area;
                }
            }
        }
    }

    println!("Day 09 Part 1: {}", max_area_part1);
    println!("Day 09 Part 2: {}", max_area_part2);
}
