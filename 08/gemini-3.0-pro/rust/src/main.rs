use std::fs;
use std::collections::HashMap;

#[derive(Debug, Clone, Copy)]
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

#[derive(Debug)]
struct Pair {
    dist: f64,
    i: usize,
    j: usize,
}

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input");

    let mut points: Vec<Point> = Vec::new();
    for line in input.lines() {
        if line.trim().is_empty() {
            continue;
        }
        let parts: Vec<&str> = line.trim().split(',').collect();
        if parts.len() == 3 {
            let x = parts[0].parse::<i32>().unwrap();
            let y = parts[1].parse::<i32>().unwrap();
            let z = parts[2].parse::<i32>().unwrap();
            points.push(Point { x, y, z });
        }
    }

    let mut pairs: Vec<Pair> = Vec::new();
    for i in 0..points.len() {
        for j in (i + 1)..points.len() {
            let p1 = points[i];
            let p2 = points[j];
            let dist_sq = (p1.x as f64 - p2.x as f64).powi(2) + (p1.y as f64 - p2.y as f64).powi(2) + (p1.z as f64 - p2.z as f64).powi(2);
            let dist = dist_sq.sqrt();
            pairs.push(Pair { dist, i, j });
        }
    }

    pairs.sort_by(|a, b| a.dist.partial_cmp(&b.dist).unwrap());

    let mut parent: Vec<usize> = (0..points.len()).collect();

    fn find(parent: &mut Vec<usize>, i: usize) -> usize {
        if parent[i] == i {
            return i;
        }
        let root = find(parent, parent[i]);
        parent[i] = root;
        root
    }

    fn union(parent: &mut Vec<usize>, i: usize, j: usize) {
        let root_i = find(parent, i);
        let root_j = find(parent, j);
        if root_i != root_j {
            parent[root_i] = root_j;
        }
    }

    let limit = std::cmp::min(1000, pairs.len());
    for k in 0..limit {
        union(&mut parent, pairs[k].i, pairs[k].j);
    }

    let mut counts: HashMap<usize, i32> = HashMap::new();
    for i in 0..points.len() {
        let root = find(&mut parent, i);
        *counts.entry(root).or_insert(0) += 1;
    }

    let mut sizes: Vec<i32> = counts.values().cloned().collect();
    sizes.sort_by(|a, b| b.cmp(a));

    let mut result: i64 = 0;
    if sizes.len() >= 3 {
        result = sizes[0] as i64 * sizes[1] as i64 * sizes[2] as i64;
    } else if !sizes.is_empty() {
        result = 1;
        for s in sizes {
            result *= s as i64;
        }
    }

    println!("Day 08 Part 1: {}", result);

    // Part 2
    for i in 0..points.len() {
        parent[i] = i;
    }
    let mut num_components = points.len();
    let mut part2_result: i64 = 0;

    for pair in pairs {
        let root_i = find(&mut parent, pair.i);
        let root_j = find(&mut parent, pair.j);
        if root_i != root_j {
            parent[root_i] = root_j;
            num_components -= 1;
            if num_components == 1 {
                part2_result = points[pair.i].x as i64 * points[pair.j].x as i64;
                break;
            }
        }
    }

    println!("Day 08 Part 2: {}", part2_result);
}