use std::collections::HashSet;
use std::fs;
use regex::Regex;

fn solve_machine(line: &str) -> i64 {
    // Parse indicator lights pattern
    let light_re = Regex::new(r"\[([.#]+)\]").unwrap();
    let light_cap = light_re.captures(line).unwrap();
    let pattern = &light_cap[1];
    let n = pattern.len();
    
    // Target: 1 where '#', 0 where '.'
    let target: Vec<i32> = pattern.chars().map(|c| if c == '#' { 1 } else { 0 }).collect();
    
    // Parse buttons
    let button_re = Regex::new(r"\(([0-9,]+)\)").unwrap();
    let mut buttons: Vec<Vec<usize>> = Vec::new();
    for cap in button_re.captures_iter(line) {
        let indices: Vec<usize> = cap[1].split(',').map(|s| s.parse().unwrap()).collect();
        buttons.push(indices);
    }
    
    let num_buttons = buttons.len();
    
    // Build augmented matrix [A | target]
    let mut matrix: Vec<Vec<i32>> = vec![vec![0; num_buttons + 1]; n];
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
    
    // Gaussian elimination over GF(2)
    let mut pivot_col: Vec<i32> = vec![-1; n];
    let mut rank = 0;
    
    for col in 0..num_buttons {
        if rank >= n {
            break;
        }
        // Find pivot
        let mut pivot_row: Option<usize> = None;
        for row in rank..n {
            if matrix[row][col] == 1 {
                pivot_row = Some(row);
                break;
            }
        }
        
        let pivot_row = match pivot_row {
            Some(r) => r,
            None => continue,
        };
        
        // Swap rows
        matrix.swap(rank, pivot_row);
        pivot_col[rank] = col as i32;
        
        // Eliminate
        for row in 0..n {
            if row != rank && matrix[row][col] == 1 {
                for k in 0..=num_buttons {
                    matrix[row][k] ^= matrix[rank][k];
                }
            }
        }
        rank += 1;
    }
    
    // Check for inconsistency
    for row in rank..n {
        if matrix[row][num_buttons] == 1 {
            return i64::MAX;
        }
    }
    
    // Find free variables
    let pivot_cols: HashSet<i32> = pivot_col.iter().filter(|&&x| x >= 0).cloned().collect();
    let free_vars: Vec<usize> = (0..num_buttons).filter(|&j| !pivot_cols.contains(&(j as i32))).collect();
    
    // Try all combinations of free variables
    let mut min_presses = i64::MAX;
    let num_free = free_vars.len();
    
    for mask in 0..(1 << num_free) {
        let mut solution = vec![0i32; num_buttons];
        
        // Set free variables
        for (i, &fv) in free_vars.iter().enumerate() {
            solution[fv] = ((mask >> i) & 1) as i32;
        }
        
        // Back-substitute
        for row in (0..rank).rev() {
            let col = pivot_col[row] as usize;
            let mut val = matrix[row][num_buttons];
            for j in (col + 1)..num_buttons {
                val ^= matrix[row][j] * solution[j];
            }
            solution[col] = val;
        }
        
        let presses: i64 = solution.iter().map(|&x| x as i64).sum();
        if presses < min_presses {
            min_presses = presses;
        }
    }
    
    min_presses
}

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    let part1: i64 = input.lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| solve_machine(line.trim()))
        .sum();
    
    println!("Day 10 Part 1: {}", part1);

    // Part 2
    let part2: i64 = 0;
    println!("Day 10 Part 2: {}", part2);
}