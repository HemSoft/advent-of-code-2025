use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");
    let lines: Vec<String> = input.lines().map(|s| s.to_string()).collect();

    if lines.is_empty() {
        return;
    }

    let max_width = lines.iter().map(|l| l.len()).max().unwrap_or(0);
    let padded_lines: Vec<String> = lines
        .iter()
        .map(|l| format!("{:width$}", l, width = max_width))
        .collect();

    let mut blocks: Vec<(usize, usize)> = Vec::new();
    let mut start_col: i32 = -1;

    for col in 0..max_width {
        let mut is_empty = true;
        for line in &padded_lines {
            if line.chars().nth(col).unwrap() != ' ' {
                is_empty = false;
                break;
            }
        }

        if is_empty {
            if start_col != -1 {
                blocks.push((start_col as usize, col - 1));
                start_col = -1;
            }
        } else {
            if start_col == -1 {
                start_col = col as i32;
            }
        }
    }

    if start_col != -1 {
        blocks.push((start_col as usize, max_width - 1));
    }

    let mut total_sum_p1: i64 = 0;
    for (start, end) in &blocks {
        total_sum_p1 += process_block(&padded_lines, *start, *end);
    }
    println!("Day 06 Part 1: {}", total_sum_p1);

    let mut total_sum_p2: i64 = 0;
    for (start, end) in &blocks {
        total_sum_p2 += process_block_part2(&padded_lines, *start, *end);
    }
    println!("Day 06 Part 2: {}", total_sum_p2);
}

fn process_block(lines: &[String], start: usize, end: usize) -> i64 {
    let mut numbers: Vec<i64> = Vec::new();
    let mut op = ' ';

    for line in lines {
        let segment = &line[start..=end];
        let trimmed = segment.trim();
        if trimmed.is_empty() {
            continue;
        }

        if trimmed == "+" || trimmed == "*" {
            op = trimmed.chars().next().unwrap();
        } else if let Ok(num) = trimmed.parse::<i64>() {
            numbers.push(num);
        }
    }

    if op == '+' {
        return numbers.iter().sum();
    } else if op == '*' {
        return numbers.iter().product();
    }
    0
}

fn process_block_part2(lines: &[String], start: usize, end: usize) -> i64 {
    let mut numbers: Vec<i64> = Vec::new();
    let mut op: Option<char> = None;

    for col in start..=end {
        let mut chars: Vec<char> = Vec::new();
        for line in lines {
            let c = line.chars().nth(col).unwrap();
            if c != ' ' {
                chars.push(c);
            }
        }

        if chars.is_empty() {
            continue;
        }

        let last_char = *chars.last().unwrap();
        if last_char == '+' || last_char == '*' {
            op = Some(last_char);
            chars.pop();
        }

        if !chars.is_empty() {
            let num_str: String = chars.into_iter().collect();
            if let Ok(num) = num_str.parse::<i64>() {
                numbers.push(num);
            }
        }
    }

    if let Some(o) = op {
        if o == '+' {
            return numbers.iter().sum();
        } else if o == '*' {
            return numbers.iter().product();
        }
    }
    0
}
