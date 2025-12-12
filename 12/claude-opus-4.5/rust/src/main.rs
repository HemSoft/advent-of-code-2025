use std::collections::HashMap;
use std::fs;

fn main() {
    let content = fs::read_to_string("input.txt").expect("Failed to read input");
    let lines: Vec<&str> = content.lines().collect();

    let mut shapes: HashMap<i32, i32> = HashMap::new();
    let mut region_lines: Vec<&str> = Vec::new();
    let mut current_shape_id: i32 = -1;
    let mut current_cell_count: i32 = 0;

    for line in &lines {
        let line = line.trim_end_matches('\r');
        if line.trim().is_empty() {
            continue;
        }

        if !line.is_empty() && line.chars().next().unwrap().is_ascii_digit()
            && line.contains(':') && !line.contains('x') {
            if current_shape_id >= 0 {
                shapes.insert(current_shape_id, current_cell_count);
            }
            current_shape_id = line.split(':').next().unwrap().parse().unwrap();
            current_cell_count = 0;
        } else if line.contains('x') && line.contains(':') {
            if current_shape_id >= 0 {
                shapes.insert(current_shape_id, current_cell_count);
                current_shape_id = -1;
                current_cell_count = 0;
            }
            region_lines.push(line);
        } else if current_shape_id >= 0 && (line.contains('#') || line.contains('.')) {
            current_cell_count += line.matches('#').count() as i32;
        }
    }

    if current_shape_id >= 0 {
        shapes.insert(current_shape_id, current_cell_count);
    }

    let mut part1 = 0;

    for region_line in &region_lines {
        let colon_idx = region_line.find(':').unwrap();
        let size_part = &region_line[..colon_idx];
        let counts_part = region_line[colon_idx + 1..].trim();

        let size_parts: Vec<i32> = size_part.split('x').map(|s| s.parse().unwrap()).collect();
        let width = size_parts[0];
        let height = size_parts[1];

        let counts: Vec<i32> = counts_part.split_whitespace().map(|s| s.parse().unwrap()).collect();

        let mut total_cells_needed = 0;
        for (i, &count) in counts.iter().enumerate() {
            total_cells_needed += count * shapes.get(&(i as i32)).unwrap_or(&0);
        }

        let grid_area = width * height;
        if total_cells_needed <= grid_area {
            part1 += 1;
        }
    }

    println!("Day 12 Part 1: {}", part1);
    println!("Day 12 Part 2: 0");
}
