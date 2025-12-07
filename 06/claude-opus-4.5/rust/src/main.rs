use std::fs;

struct Problem {
    numbers: Vec<i64>,
    op: char,
}

fn is_separator_column(grid: &[String], col: usize, data_row_count: usize) -> bool {
    for r in 0..data_row_count {
        let chars: Vec<char> = grid[r].chars().collect();
        if col < chars.len() && chars[col] != ' ' {
            return false;
        }
    }
    true
}

fn main() {
    let content = fs::read_to_string("input.txt").expect("Failed to read input");
    let mut lines: Vec<&str> = content.lines().collect();

    // Remove trailing empty lines
    while !lines.is_empty() && lines.last().unwrap().trim().is_empty() {
        lines.pop();
    }

    // Find max width and pad lines
    let max_width = lines.iter().map(|l| l.len()).max().unwrap_or(0);
    let grid: Vec<String> = lines.iter()
        .map(|l| format!("{:width$}", l, width = max_width))
        .collect();

    let rows = grid.len();
    let cols = max_width;
    let operator_row: Vec<char> = grid[rows - 1].chars().collect();

    let mut problems: Vec<Problem> = Vec::new();
    let mut col_start = 0;

    while col_start < cols {
        // Skip separator columns
        while col_start < cols && is_separator_column(&grid, col_start, rows - 1) {
            col_start += 1;
        }
        if col_start >= cols {
            break;
        }

        // Find end of this problem
        let mut col_end = col_start;
        while col_end < cols && !is_separator_column(&grid, col_end, rows - 1) {
            col_end += 1;
        }

        // Extract numbers and operator
        let mut numbers: Vec<i64> = Vec::new();
        let mut op = ' ';

        for r in 0..rows - 1 {
            let chars: Vec<char> = grid[r].chars().collect();
            let segment: String = chars[col_start..col_end].iter().collect();
            let trimmed = segment.trim();
            if !trimmed.is_empty() {
                if let Ok(num) = trimmed.parse::<i64>() {
                    numbers.push(num);
                }
            }
        }

        // Get operator
        let op_segment: String = operator_row[col_start..col_end].iter().collect();
        let op_trimmed = op_segment.trim();
        if !op_trimmed.is_empty() {
            op = op_trimmed.chars().next().unwrap();
        }

        if !numbers.is_empty() && (op == '+' || op == '*') {
            problems.push(Problem { numbers, op });
        }

        col_start = col_end;
    }

    // Calculate grand total
    let mut part1: i64 = 0;
    for p in &problems {
        let mut result = p.numbers[0];
        for i in 1..p.numbers.len() {
            if p.op == '+' {
                result += p.numbers[i];
            } else {
                result *= p.numbers[i];
            }
        }
        part1 += result;
    }

    println!("Day 06 Part 1: {}", part1);

    // Part 2: Read columns right-to-left, digits top-to-bottom form numbers
    let mut part2: i64 = 0;
    let mut col_start = 0;

    while col_start < cols {
        while col_start < cols && is_separator_column(&grid, col_start, rows - 1) {
            col_start += 1;
        }
        if col_start >= cols {
            break;
        }

        let mut col_end = col_start;
        while col_end < cols && !is_separator_column(&grid, col_end, rows - 1) {
            col_end += 1;
        }

        // Get operator
        let op_segment: String = operator_row[col_start..col_end].iter().collect();
        let op_trimmed = op_segment.trim();
        let op = if !op_trimmed.is_empty() {
            op_trimmed.chars().next().unwrap()
        } else {
            ' '
        };

        // Read columns right-to-left within this problem block
        let mut numbers2: Vec<i64> = Vec::new();
        for c in (col_start..col_end).rev() {
            let mut digits: Vec<char> = Vec::new();
            for r in 0..rows - 1 {
                let chars: Vec<char> = grid[r].chars().collect();
                let ch = chars[c];
                if ch.is_ascii_digit() {
                    digits.push(ch);
                }
            }
            if !digits.is_empty() {
                let num_str: String = digits.iter().collect();
                if let Ok(num) = num_str.parse::<i64>() {
                    numbers2.push(num);
                }
            }
        }

        if !numbers2.is_empty() && (op == '+' || op == '*') {
            let mut result = numbers2[0];
            for i in 1..numbers2.len() {
                if op == '+' {
                    result += numbers2[i];
                } else {
                    result *= numbers2[i];
                }
            }
            part2 += result;
        }

        col_start = col_end;
    }

    println!("Day 06 Part 2: {}", part2);
}
