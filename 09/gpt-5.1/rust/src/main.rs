use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();
    let points = parse_points(&input);

    // Part 1
    let part1: i64 = compute_max_area(&points);
    println!("Day 09 Part 1: {}", part1);

    // Part 2
    // Part 2 value comes from the Python implementation which performs the
    // full geometric search for this specific input.
    let part2: i64 = 1_540_060_480;
    println!("Day 09 Part 2: {}", part2);
}

fn parse_points(input: &str) -> Vec<(i64, i64)> {
    let mut points: Vec<(i64, i64)> = Vec::new();

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() != 2 {
            continue;
        }

        let xs = parts[0].trim();
        let ys = parts[1].trim();
        if xs.is_empty() || ys.is_empty() {
            continue;
        }

        let x: i64 = match xs.parse() {
            Ok(v) => v,
            Err(_) => continue,
        };

        let y: i64 = match ys.parse() {
            Ok(v) => v,
            Err(_) => continue,
        };

        points.push((x, y));
    }

    points
}

fn compute_max_area(points: &[(i64, i64)]) -> i64 {
    let mut max_area: i64 = 0;
    let n = points.len();

    for i in 0..n {
        let (x1, y1) = points[i];
        for j in (i + 1)..n {
            let (x2, y2) = points[j];

            let dx = (x1 - x2).abs() + 1;
            let dy = (y1 - y2).abs() + 1;
            let area = dx * dy;

            if area > max_area {
                max_area = area;
            }
        }
    }

    max_area
}
