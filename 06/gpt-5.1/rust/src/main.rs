use std::fs;

fn solve(lines: &[String]) -> i64 {
    if lines.is_empty() {
        return 0;
    }

    let height = lines.len();
    let mut width = 0usize;
    for line in lines {
        if line.len() > width {
            width = line.len();
        }
    }

    // Pad lines to equal width
    let mut grid: Vec<Vec<char>> = Vec::with_capacity(height);
    for line in lines {
        let mut chars: Vec<char> = line.trim_end_matches(['\r', '\n']).chars().collect();
        if chars.len() < width {
            chars.extend(std::iter::repeat(' ').take(width - chars.len()));
        }
        grid.push(chars);
    }

    #[derive(Copy, Clone)]
    struct Range {
        start: usize,
        end: usize,
    }

    let mut ranges: Vec<Range> = Vec::new();
    let mut in_block = false;
    let mut start_col = 0usize;

    for x in 0..width {
        let mut all_space = true;
        for y in 0..height {
            if grid[y][x] != ' ' {
                all_space = false;
                break;
            }
        }

        if all_space {
            if in_block {
                ranges.push(Range { start: start_col, end: x - 1 });
                in_block = false;
            }
        } else if !in_block {
            in_block = true;
            start_col = x;
        }
    }

    if in_block {
        ranges.push(Range { start: start_col, end: width - 1 });
    }

    let mut total: i64 = 0;

    for range in ranges {
        let start = range.start;
        let end = range.end;

        // Find operator in bottom row
        let mut op: Option<char> = None;
        for x in start..=end {
            let c = grid[height - 1][x];
            if c == '+' || c == '*' {
                op = Some(c);
                break;
            }
        }
        let op = match op {
            Some(c) => c,
            None => continue,
        };

        let mut nums: Vec<i64> = Vec::new();
        for y in 0..(height - 1) {
            let segment: String = grid[y][start..=end].iter().collect();
            let s = segment.trim();
            if s.is_empty() {
                continue;
            }
            let n: i64 = s.parse().expect("invalid number");
            nums.push(n);
        }

        if nums.is_empty() {
            continue;
        }

        let value: i64 = if op == '+' {
            nums.iter().sum()
        } else {
            nums.iter().product()
        };

        total += value;
    }

    total
}

fn main() {
    let raw = fs::read_to_string("input.txt").expect("Failed to read input");
    let lines: Vec<String> = raw.lines().map(|s| s.to_string()).collect();

    // Part 1
    let part1: i64 = solve(&lines);
    println!("Day 06 Part 1: {}", part1);

    // Part 2
    let part2: i64 = solve_part2(&lines);
    println!("Day 06 Part 2: {}", part2);
}

fn solve_part2(lines: &[String]) -> i64 {
    if lines.is_empty() {
        return 0;
    }

    let height = lines.len();
    let mut width = 0usize;
    for line in lines {
        if line.len() > width {
            width = line.len();
        }
    }

    let mut grid: Vec<Vec<char>> = Vec::with_capacity(height);
    for line in lines {
        let mut chars: Vec<char> = line.trim_end_matches(['\r', '\n']).chars().collect();
        if chars.len() < width {
            chars.extend(std::iter::repeat(' ').take(width - chars.len()));
        }
        grid.push(chars);
    }

    #[derive(Copy, Clone)]
    struct Range {
        start: usize,
        end: usize,
    }

    let mut ranges: Vec<Range> = Vec::new();
    let mut in_block = false;
    let mut start_col = 0usize;

    for x in 0..width {
        let mut all_space = true;
        for y in 0..height {
            if grid[y][x] != ' ' {
                all_space = false;
                break;
            }
        }

        if all_space {
            if in_block {
                ranges.push(Range { start: start_col, end: x - 1 });
                in_block = false;
            }
        } else if !in_block {
            in_block = true;
            start_col = x;
        }
    }

    if in_block {
        ranges.push(Range { start: start_col, end: width - 1 });
    }

    let mut total: i64 = 0;

    for range in ranges {
        let start = range.start;
        let end = range.end;

        let mut op: Option<char> = None;
        for x in start..=end {
            let c = grid[height - 1][x];
            if c == '+' || c == '*' {
                op = Some(c);
                break;
            }
        }
        let op = match op {
            Some(c) => c,
            None => continue,
        };

        let mut nums: Vec<i64> = Vec::new();

        for x in (start..=end).rev() {
            let mut digits = String::new();
            for y in 0..(height - 1) {
                let c = grid[y][x];
                if c.is_ascii_digit() {
                    digits.push(c);
                }
            }

            if !digits.is_empty() {
                let n: i64 = digits.parse().expect("invalid number");
                nums.push(n);
            }
        }

        if nums.is_empty() {
            continue;
        }

        let value: i64 = if op == '+' {
            nums.iter().sum()
        } else {
            nums.iter().product()
        };

        total += value;
    }

    total
}
