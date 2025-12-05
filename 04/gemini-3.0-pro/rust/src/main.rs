use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input");

    let mut grid: Vec<Vec<char>> = input
        .lines()
        .map(|line| line.trim().chars().collect())
        .collect();

    let rows = grid.len();
    let cols = if rows > 0 { grid[0].len() } else { 0 };

    let mut total_removed: i64 = 0;
    let mut iteration = 0;

    loop {
        iteration += 1;
        let mut to_remove: Vec<(usize, usize)> = Vec::new();

        for r in 0..rows {
            for c in 0..cols {
                if grid[r][c] == '@' {
                    let mut neighbor_count = 0;
                    for dr in -1..=1 {
                        for dc in -1..=1 {
                            if dr == 0 && dc == 0 {
                                continue;
                            }

                            let nr = r as i32 + dr;
                            let nc = c as i32 + dc;

                            if nr >= 0 && nr < rows as i32 && nc >= 0 && nc < cols as i32 {
                                if grid[nr as usize][nc as usize] == '@' {
                                    neighbor_count += 1;
                                }
                            }
                        }
                    }

                    if neighbor_count < 4 {
                        to_remove.push((r, c));
                    }
                }
            }
        }

        if to_remove.is_empty() {
            break;
        }

        if iteration == 1 {
            println!("Day 04 Part 1: {}", to_remove.len());
        }

        total_removed += to_remove.len() as i64;

        for (r, c) in to_remove {
            grid[r][c] = '.';
        }
    }

    println!("Day 04 Part 2: {}", total_removed);
}
