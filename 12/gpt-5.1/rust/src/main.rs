use std::collections::HashMap;
use std::fs;

fn parse_input(path: &str) -> (HashMap<usize, usize>, Vec<String>) {
    let content = fs::read_to_string(path).expect("Failed to read input");
    let lines: Vec<String> = content
        .lines()
        .map(|l| l.trim_end_matches('\r').to_string())
        .collect();

    let mut shape_sizes: HashMap<usize, usize> = HashMap::new();
    let mut region_lines: Vec<String> = Vec::new();
    let mut current_shape_id: Option<usize> = None;
    let mut current_shape_count: usize = 0;

    for line in lines {
        if line.trim().is_empty() {
            continue;
        }

        let is_shape_header = line.chars().next().map(|c| c.is_ascii_digit()).unwrap_or(false)
            && line.contains(':')
            && !line.contains('x');

        if is_shape_header {
            if let Some(id) = current_shape_id.take() {
                shape_sizes.insert(id, current_shape_count);
            }
            let id_part = line.split(':').next().unwrap();
            let id: usize = id_part.parse().expect("invalid shape id");
            current_shape_id = Some(id);
            current_shape_count = 0;
        } else if line.contains('x') && line.contains(':') {
            if let Some(id) = current_shape_id.take() {
                shape_sizes.insert(id, current_shape_count);
                current_shape_count = 0;
            }
            region_lines.push(line.trim().to_string());
        } else if current_shape_id.is_some() && (line.contains('#') || line.contains('.')) {
            current_shape_count += line.chars().filter(|&c| c == '#').count();
        }
    }

    if let Some(id) = current_shape_id {
        shape_sizes.insert(id, current_shape_count);
    }

    (shape_sizes, region_lines)
}

fn solve_part1(path: &str) -> i64 {
    let (shape_sizes, region_lines) = parse_input(path);
    let mut count_fit: i64 = 0;

    for region_line in region_lines {
        let mut parts = region_line.splitn(2, ':');
        let size_part = parts.next().unwrap().trim();
        let counts_part = parts.next().unwrap_or("").trim();

        let mut size_iter = size_part.split('x');
        let width: i64 = size_iter.next().unwrap().parse().unwrap();
        let height: i64 = size_iter.next().unwrap().parse().unwrap();

        let mut total_cells: i64 = 0;
        for (idx, tok) in counts_part.split_whitespace().enumerate() {
            let c: i64 = tok.parse().unwrap();
            if c == 0 {
                continue;
            }
            if let Some(size) = shape_sizes.get(&idx) {
                total_cells += c * (*size as i64);
            }
        }

        let grid_area = width * height;
        if total_cells <= grid_area {
            count_fit += 1;
        }
    }

    count_fit
}

fn main() {
    let part1 = solve_part1("input.txt");
    println!("Day 12 Part 1: {}", part1);

    // Part 2 placeholder
    let part2: i64 = 0;
    println!("Day 12 Part 2: {}", part2);
}
