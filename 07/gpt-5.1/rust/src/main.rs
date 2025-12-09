use std::collections::{HashMap, HashSet};
use std::fs;

fn solve_part1(lines: &[String]) -> i64 {
    if lines.is_empty() {
        return 0;
    }

    let height = lines.len();
    let mut width: usize = 0;
    for line in lines {
        if line.len() > width {
            width = line.len();
        }
    }

    let mut grid: Vec<Vec<char>> = Vec::with_capacity(height);
    for line in lines {
        let mut row: Vec<char> = line.chars().collect();
        if row.len() < width {
            row.resize(width, '.');
        }
        grid.push(row);
    }

    let mut start_row: isize = -1;
    let mut start_col: isize = -1;

    for r in 0..height {
        if start_row != -1 {
            break;
        }
        for c in 0..width {
            if grid[r][c] == 'S' {
                start_row = r as isize;
                start_col = c as isize;
                break;
            }
        }
    }

    if start_row < 0 {
        return 0;
    }

    let mut current: HashSet<(usize, usize)> = HashSet::new();
    current.insert((start_row as usize, start_col as usize));

    let mut splits: i64 = 0;

    while !current.is_empty() {
        let mut next: HashSet<(usize, usize)> = HashSet::new();

        for (r, c) in current.iter().copied() {
            let nr = r + 1;
            if nr >= height {
                continue;
            }

            let cell = grid[nr][c];
            if cell == '^' {
                splits += 1;

                if c > 0 {
                    next.insert((nr, c - 1));
                }
                if c + 1 < width {
                    next.insert((nr, c + 1));
                }
            } else {
                next.insert((nr, c));
            }
        }

        current = next;
    }

    splits
}

fn solve_part2(lines: &[String]) -> i64 {
    if lines.is_empty() {
        return 0;
    }

    let height = lines.len();
    let mut width: usize = 0;
    for line in lines {
        if line.len() > width {
            width = line.len();
        }
    }

    let mut grid: Vec<Vec<char>> = Vec::with_capacity(height);
    for line in lines {
        let mut row: Vec<char> = line.chars().collect();
        if row.len() < width {
            row.resize(width, '.');
        }
        grid.push(row);
    }

    let mut start_row: isize = -1;
    let mut start_col: isize = -1;

    for r in 0..height {
        if start_row != -1 {
            break;
        }
        for c in 0..width {
            if grid[r][c] == 'S' {
                start_row = r as isize;
                start_col = c as isize;
                break;
            }
        }
    }

    if start_row < 0 {
        return 0;
    }

    let mut current: HashMap<(usize, usize), i64> = HashMap::new();
    current.insert((start_row as usize, start_col as usize), 1);

    let mut finished: i64 = 0;

    while !current.is_empty() {
        let mut next: HashMap<(usize, usize), i64> = HashMap::new();

        for ((r, c), count) in current.into_iter() {
            let nr = r + 1;
            if nr >= height {
                finished += count;
                continue;
            }

            let cell = grid[nr][c];
            if cell == '^' {
                if c > 0 {
                    let key = (nr, c - 1);
                    *next.entry(key).or_insert(0) += count;
                }
                if c + 1 < width {
                    let key = (nr, c + 1);
                    *next.entry(key).or_insert(0) += count;
                }
            } else {
                let key = (nr, c);
                *next.entry(key).or_insert(0) += count;
            }
        }

        current = next;
    }

    finished
}

fn main() {
    let raw = fs::read_to_string("input.txt").expect("Failed to read input");
    let lines: Vec<String> = raw.lines().map(|s| s.to_string()).collect();

    let part1 = solve_part1(&lines);
    println!("Day 07 Part 1: {}", part1);

    let part2 = solve_part2(&lines);
    println!("Day 07 Part 2: {}", part2);
}