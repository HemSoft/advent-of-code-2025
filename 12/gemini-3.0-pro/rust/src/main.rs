use std::collections::{HashMap, HashSet};
use std::env;
use std::fs;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
struct Point {
    r: i32,
    c: i32,
}

#[derive(Debug, Clone)]
struct RegionTask {
    w: i32,
    h: i32,
    counts: Vec<usize>,
}

#[derive(Debug, Clone)]
struct AnchoredShape {
    points: Vec<Point>,
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let input_file = if args.len() > 1 { &args[1] } else { "input.txt" };

    let content = fs::read_to_string(input_file).expect("Failed to read input file");
    let content = content.replace("\r\n", "\n");
    let parts: Vec<&str> = content.split("\n\n").collect();

    let mut shapes: HashMap<usize, Vec<Vec<Point>>> = HashMap::new();
    let mut regions: Vec<RegionTask> = Vec::new();

    for part in parts {
        let lines: Vec<&str> = part.trim().split('\n').collect();
        if lines.is_empty() {
            continue;
        }

        if lines[0].contains(':') {
            if lines[0].contains('x') { // Region
                for line in lines {
                    if !line.trim().is_empty() {
                        parse_region(line, &mut regions);
                    }
                }
            } else { // Shape
                parse_shape(&lines, &mut shapes);
            }
        }
    }

    let mut solved_count = 0;
    for region in regions {
        if solve_region(&region, &shapes) {
            solved_count += 1;
        }
    }

    println!("Day 12 Part 1: {}", solved_count);
    // println!("Day 12 Part 2: 0");
}

fn parse_shape(lines: &[&str], shapes: &mut HashMap<usize, Vec<Vec<Point>>>) {
    let header = lines[0].trim().trim_end_matches(':');
    let id: usize = header.parse().unwrap();

    let mut points: HashSet<Point> = HashSet::new();
    for (r, line) in lines.iter().enumerate().skip(1) {
        for (c, ch) in line.chars().enumerate() {
            if ch == '#' {
                points.insert(Point {
                    r: (r - 1) as i32,
                    c: c as i32,
                });
            }
        }
    }
    shapes.insert(id, generate_variations(&points));
}

fn parse_region(line: &str, regions: &mut Vec<RegionTask>) {
    let p: Vec<&str> = line.split(':').collect();
    let dims: Vec<&str> = p[0].split('x').collect();
    let w: i32 = dims[0].parse().unwrap();
    let h: i32 = dims[1].parse().unwrap();

    let count_strs: Vec<&str> = p[1].trim().split_whitespace().collect();
    let mut counts: Vec<usize> = Vec::new();
    for s in count_strs {
        counts.push(s.parse().unwrap());
    }
    regions.push(RegionTask { w, h, counts });
}

fn generate_variations(original: &HashSet<Point>) -> Vec<Vec<Point>> {
    let mut variations: Vec<Vec<Point>> = Vec::new();
    let mut seen: HashSet<String> = HashSet::new();

    let mut current = original.clone();
    for _ in 0..2 { // Flip
        for _ in 0..4 { // Rotate
            let normalized = normalize(&current);
            let key = points_to_string(&normalized);
            if !seen.contains(&key) {
                variations.push(normalized);
                seen.insert(key);
            }
            current = rotate(&current);
        }
        current = flip(original);
    }
    variations
}

fn rotate(points: &HashSet<Point>) -> HashSet<Point> {
    let mut new_points: HashSet<Point> = HashSet::new();
    for p in points {
        new_points.insert(Point { r: p.c, c: -p.r });
    }
    new_points
}

fn flip(points: &HashSet<Point>) -> HashSet<Point> {
    let mut new_points: HashSet<Point> = HashSet::new();
    for p in points {
        new_points.insert(Point { r: p.r, c: -p.c });
    }
    new_points
}

fn normalize(points: &HashSet<Point>) -> Vec<Point> {
    if points.is_empty() {
        return Vec::new();
    }
    let mut min_r = 1000000;
    let mut min_c = 1000000;
    for p in points {
        if p.r < min_r {
            min_r = p.r;
        }
        if p.c < min_c {
            min_c = p.c;
        }
    }
    let mut res: Vec<Point> = Vec::new();
    for p in points {
        res.push(Point {
            r: p.r - min_r,
            c: p.c - min_c,
        });
    }
    res.sort();
    res
}

fn points_to_string(points: &[Point]) -> String {
    let mut s = String::new();
    for p in points {
        s.push_str(&format!("{},{};", p.r, p.c));
    }
    s
}

struct StaticContext {
    w: i32,
    h: i32,
    types: Vec<usize>,
    anchored_shapes: HashMap<usize, Vec<AnchoredShape>>,
}

fn solve_region(region: &RegionTask, shapes: &HashMap<usize, Vec<Vec<Point>>>) -> bool {
    let mut presents: Vec<usize> = Vec::new();
    let mut total_area = 0;
    for (i, &count) in region.counts.iter().enumerate() {
        for _ in 0..count {
            presents.push(i);
            total_area += shapes[&i][0].len();
        }
    }

    if total_area > (region.w * region.h) as usize {
        return false;
    }

    let max_skips = (region.w * region.h) as usize - total_area;
    let mut grid = vec![false; (region.w * region.h) as usize];

    let mut present_types_set: HashSet<usize> = HashSet::new();
    for &p in &presents {
        present_types_set.insert(p);
    }
    let mut present_types: Vec<usize> = present_types_set.into_iter().collect();
    present_types.sort_by(|a, b| shapes[b][0].len().cmp(&shapes[a][0].len()));

    let mut counts_map: HashMap<usize, usize> = HashMap::new();
    for &p in &presents {
        *counts_map.entry(p).or_insert(0) += 1;
    }
    
    let max_id = *present_types.iter().max().unwrap_or(&0);
    let mut counts = vec![0; max_id + 1];
    for (k, v) in counts_map {
        counts[k] = v;
    }

    let mut anchored_shapes: HashMap<usize, Vec<AnchoredShape>> = HashMap::new();
    for &type_id in &present_types {
        let mut list: Vec<AnchoredShape> = Vec::new();
        for v in &shapes[&type_id] {
            let anchor = v[0];
            let mut points: Vec<Point> = Vec::new();
            for p in v {
                points.push(Point {
                    r: p.r - anchor.r,
                    c: p.c - anchor.c,
                });
            }
            list.push(AnchoredShape { points });
        }
        anchored_shapes.insert(type_id, list);
    }

    let static_ctx = StaticContext {
        w: region.w,
        h: region.h,
        types: present_types,
        anchored_shapes,
    };

    backtrack(0, &mut grid, &static_ctx, &mut counts, max_skips)
}

fn backtrack(idx: usize, grid: &mut [bool], static_ctx: &StaticContext, counts: &mut [usize], skips_left: usize) -> bool {
    let mut curr_idx = idx;
    while curr_idx < grid.len() && grid[curr_idx] {
        curr_idx += 1;
    }

    if curr_idx == grid.len() {
        for &c in counts.iter() {
            if c > 0 {
                return false;
            }
        }
        return true;
    }

    let r = (curr_idx as i32) / static_ctx.w;
    let c = (curr_idx as i32) % static_ctx.w;

    for &type_id in &static_ctx.types {
        if counts[type_id] > 0 {
            let variations = &static_ctx.anchored_shapes[&type_id];
            for shape in variations {
                let mut fits = true;
                for pt in &shape.points {
                    let pr = r + pt.r;
                    let pc = c + pt.c;
                    if pr < 0 || pr >= static_ctx.h || pc < 0 || pc >= static_ctx.w {
                        fits = false;
                        break;
                    }
                    if grid[(pr * static_ctx.w + pc) as usize] {
                        fits = false;
                        break;
                    }
                }

                if fits {
                    for pt in &shape.points {
                        grid[((r + pt.r) * static_ctx.w + (c + pt.c)) as usize] = true;
                    }
                    counts[type_id] -= 1;

                    if backtrack(curr_idx + 1, grid, static_ctx, counts, skips_left) {
                        return true;
                    }

                    counts[type_id] += 1;
                    for pt in &shape.points {
                        grid[((r + pt.r) * static_ctx.w + (c + pt.c)) as usize] = false;
                    }
                }
            }
        }
    }

    if skips_left > 0 {
        grid[curr_idx] = true;
        if backtrack(curr_idx + 1, grid, static_ctx, counts, skips_left - 1) {
            return true;
        }
        grid[curr_idx] = false;
    }

    false
}

