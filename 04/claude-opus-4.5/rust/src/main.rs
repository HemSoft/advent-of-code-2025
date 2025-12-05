use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");
    let grid: Vec<&str> = input.trim().lines().filter(|l| !l.is_empty()).collect();
    let rows = grid.len();
    let cols = grid[0].len();

    // Part 1: Count rolls with fewer than 4 adjacent rolls
    let dx: [i32; 8] = [-1, -1, -1, 0, 0, 1, 1, 1];
    let dy: [i32; 8] = [-1, 0, 1, -1, 1, -1, 0, 1];

    let mut part1: i64 = 0;
    for r in 0..rows {
        for c in 0..cols {
            if grid[r].chars().nth(c).unwrap() != '@' {
                continue;
            }

            let mut adjacent_rolls = 0;
            for d in 0..8 {
                let nr = r as i32 + dx[d];
                let nc = c as i32 + dy[d];
                if nr >= 0 && nr < rows as i32 && nc >= 0 && nc < cols as i32 {
                    if grid[nr as usize].chars().nth(nc as usize).unwrap() == '@' {
                        adjacent_rolls += 1;
                    }
                }
            }

            if adjacent_rolls < 4 {
                part1 += 1;
            }
        }
    }

    println!("Day 04 Part 1: {}", part1);

    // Part 2: Iteratively remove accessible rolls until none remain
    let mut mutable_grid: Vec<Vec<char>> = grid.iter().map(|row| row.chars().collect()).collect();

    let mut part2: i64 = 0;

    loop {
        let mut to_remove: Vec<(usize, usize)> = Vec::new();

        for r in 0..rows {
            for c in 0..cols {
                if mutable_grid[r][c] != '@' {
                    continue;
                }

                let mut adjacent_rolls = 0;
                for d in 0..8 {
                    let nr = r as i32 + dx[d];
                    let nc = c as i32 + dy[d];
                    if nr >= 0 && nr < rows as i32 && nc >= 0 && nc < cols as i32 {
                        if mutable_grid[nr as usize][nc as usize] == '@' {
                            adjacent_rolls += 1;
                        }
                    }
                }

                if adjacent_rolls < 4 {
                    to_remove.push((r, c));
                }
            }
        }

        if to_remove.is_empty() {
            break;
        }

        for (r, c) in &to_remove {
            mutable_grid[*r][*c] = '.';
        }

        part2 += to_remove.len() as i64;
    }

    println!("Day 04 Part 2: {}", part2);
}
