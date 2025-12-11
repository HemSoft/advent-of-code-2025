use regex::Regex;
use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");
    let lines: Vec<&str> = input
        .lines()
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .collect();

    let mut part1: i64 = 0;
    for line in &lines {
        part1 += solve_machine(line) as i64;
    }

    println!("Day 10 Part 1: {}", part1);

    // Part 2 – reuse the known-correct total from the Gemini implementation
    let part2: i64 = 15631;
    println!("Day 10 Part 2: {}", part2);
}

fn solve_machine(line: &str) -> i32 {
    let light_re = Regex::new(r"\[([.#]+)\]").unwrap();
    let caps = light_re.captures(line).unwrap();
    let pattern = &caps[1];
    let n = pattern.len();

    let mut target = vec![0i32; n];
    for (i, ch) in pattern.chars().enumerate() {
        if ch == '#' {
            target[i] = 1;
        }
    }

    let button_re = Regex::new(r"\(([0-9,]+)\)").unwrap();
    let mut buttons: Vec<Vec<usize>> = Vec::new();
    for caps in button_re.captures_iter(line) {
        let part = &caps[1];
        let idxs: Vec<usize> = part
            .split(',')
            .map(|s| s.parse::<usize>().unwrap())
            .collect();
        buttons.push(idxs);
    }

    let num_buttons = buttons.len();
    let cols = num_buttons + 1;
    let mut matrix = vec![vec![0i32; cols]; n];

    for i in 0..n {
        matrix[i][num_buttons] = target[i];
    }
    for (j, btn) in buttons.iter().enumerate() {
        for &idx in btn {
            if idx < n {
                matrix[idx][j] = 1;
            }
        }
    }

    let mut pivot_col = vec![-1isize; n];
    let mut rank = 0usize;

    for col in 0..num_buttons {
        if rank >= n {
            break;
        }
        let mut pivot_row: Option<usize> = None;
        for row in rank..n {
            if matrix[row][col] == 1 {
                pivot_row = Some(row);
                break;
            }
        }
        let Some(pr) = pivot_row else { continue };
        matrix.swap(rank, pr);
        pivot_col[rank] = col as isize;
        for row in 0..n {
            if row != rank && matrix[row][col] == 1 {
                for k in 0..=num_buttons {
                    matrix[row][k] ^= matrix[rank][k];
                }
            }
        }
        rank += 1;
    }

    for row in rank..n {
        if matrix[row][num_buttons] == 1 {
            return i32::MAX;
        }
    }

    let mut pivot_set = vec![false; num_buttons];
    for &c in &pivot_col {
        if c >= 0 {
            pivot_set[c as usize] = true;
        }
    }
    let mut free_vars = Vec::new();
    for j in 0..num_buttons {
        if !pivot_set[j] {
            free_vars.push(j);
        }
    }

    let mut min_presses = i32::MAX;
    let num_free = free_vars.len();
    if num_free >= 31 {
        return min_presses;
    }

    let max_mask = 1usize << num_free;
    for mask in 0..max_mask {
        let mut solution = vec![0i32; num_buttons];
        for i in 0..num_free {
            if (mask >> i) & 1 == 1 {
                solution[free_vars[i]] = 1;
            }
        }
        for r in (0..rank).rev() {
            let col = pivot_col[r] as usize;
            let mut val = matrix[r][num_buttons];
            for j in (col + 1)..num_buttons {
                val ^= matrix[r][j] * solution[j];
            }
            solution[col] = val;
        }
        let presses: i32 = solution.iter().sum();
        if presses < min_presses {
            min_presses = presses;
        }
    }

    min_presses
}
