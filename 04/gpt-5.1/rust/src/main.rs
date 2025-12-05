use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    let lines: Vec<String> = input
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(|s| s.to_string())
        .collect();

    // Part 1
    let part1 = count_accessible_rolls(&lines);
    println!("Day 04 Part 1: {}", part1);

    // Part 2
    let part2 = count_total_removed(&lines);
    println!("Day 04 Part 2: {}", part2);
}

fn count_accessible_rolls(grid: &[String]) -> i64 {
    let height = grid.len();
    if height == 0 {
        return 0;
    }
    let width = grid[0].len();
    let mut accessible: i64 = 0;

    let d_rows = [-1, -1, -1, 0, 0, 1, 1, 1];
    let d_cols = [-1, 0, 1, -1, 1, -1, 0, 1];

    for r in 0..height {
        let row = grid[r].as_bytes();
        for c in 0..width {
            if row[c] != b'@' {
                continue;
            }

            let mut neighbors = 0;
            for i in 0..d_rows.len() {
                let nr = r as isize + d_rows[i];
                let nc = c as isize + d_cols[i];

                if nr < 0
                    || nr >= height as isize
                    || nc < 0
                    || nc >= width as isize
                {
                    continue;
                }

                let nr_usize = nr as usize;
                let nc_usize = nc as usize;
                if grid[nr_usize].as_bytes()[nc_usize] == b'@' {
                    neighbors += 1;
                }
            }

            if neighbors < 4 {
                accessible += 1;
            }
        }
    }

    accessible
}

fn count_total_removed(grid: &[String]) -> i64 {
    let height = grid.len();
    if height == 0 {
        return 0;
    }

    let width = grid[0].len();

    let mut board: Vec<Vec<u8>> = grid
        .iter()
        .map(|row| row.as_bytes().to_vec())
        .collect();

    let d_rows: [isize; 8] = [-1, -1, -1, 0, 0, 1, 1, 1];
    let d_cols: [isize; 8] = [-1, 0, 1, -1, 1, -1, 0, 1];

    let mut total_removed: i64 = 0;

    loop {
        let mut to_remove: Vec<(usize, usize)> = Vec::new();

        for r in 0..height {
            for c in 0..width {
                if board[r][c] != b'@' {
                    continue;
                }

                let mut neighbors = 0;
                for i in 0..d_rows.len() {
                    let nr = r as isize + d_rows[i];
                    let nc = c as isize + d_cols[i];

                    if nr < 0
                        || nr >= height as isize
                        || nc < 0
                        || nc >= width as isize
                    {
                        continue;
                    }

                    if board[nr as usize][nc as usize] == b'@' {
                        neighbors += 1;
                    }
                }

                if neighbors < 4 {
                    to_remove.push((r, c));
                }
            }
        }

        if to_remove.is_empty() {
            break;
        }

        for (r, c) in to_remove.iter() {
            board[*r][*c] = b'.';
        }

        total_removed += to_remove.len() as i64;
    }

    total_removed
}
