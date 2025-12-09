use std::collections::HashSet;
use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input");
    let lines: Vec<&str> = input.trim().lines().collect();

    let rows = lines.len();
    let cols = if rows > 0 { lines[0].len() } else { 0 };

    // Find starting position S
    let mut start_row = 0;
    let mut start_col = 0;
    for (r, line) in lines.iter().enumerate() {
        if let Some(c) = line.find('S') {
            start_row = r;
            start_col = c;
            break;
        }
    }

    // Part 1: Count total splits
    let mut split_count: i64 = 0;
    let mut current_beams: HashSet<usize> = HashSet::new();
    current_beams.insert(start_col);

    for row in (start_row + 1)..rows {
        if current_beams.is_empty() {
            break;
        }
        let mut next_beams: HashSet<usize> = HashSet::new();
        for &col in &current_beams {
            if col >= cols {
                continue;
            }
            let cell = lines[row].as_bytes()[col];
            if cell == b'^' {
                split_count += 1;
                if col > 0 {
                    next_beams.insert(col - 1);
                }
                if col + 1 < cols {
                    next_beams.insert(col + 1);
                }
            } else {
                next_beams.insert(col);
            }
        }
        current_beams = next_beams;
    }

    println!("Day 07 Part 1: {}", split_count);

    // Part 2: Count timelines (each particle takes both paths at each splitter)
    let mut particle_counts: std::collections::HashMap<usize, i64> = std::collections::HashMap::new();
    particle_counts.insert(start_col, 1);

    for row in (start_row + 1)..rows {
        if particle_counts.is_empty() {
            break;
        }
        let mut next_counts: std::collections::HashMap<usize, i64> = std::collections::HashMap::new();
        for (&col, &count) in &particle_counts {
            if col >= cols {
                continue;
            }
            let cell = lines[row].as_bytes()[col];
            if cell == b'^' {
                if col > 0 {
                    *next_counts.entry(col - 1).or_insert(0) += count;
                }
                if col + 1 < cols {
                    *next_counts.entry(col + 1).or_insert(0) += count;
                }
            } else {
                *next_counts.entry(col).or_insert(0) += count;
            }
        }
        particle_counts = next_counts;
    }

    let part2: i64 = particle_counts.values().sum();
    println!("Day 07 Part 2: {}", part2);
}
