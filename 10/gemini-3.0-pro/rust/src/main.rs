use std::fs;
use regex::Regex;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Unable to read file");
    let mut total_presses: i64 = 0;
    let mut total_presses_part2: i64 = 0;

    for line in input.lines() {
        if line.trim().is_empty() {
            continue;
        }
        total_presses += solve_machine(line);
        total_presses_part2 += solve_part2(line);
    }

    println!("Day 10 Part 1: {}", total_presses);
    println!("Day 10 Part 2: {}", total_presses_part2);
}

fn solve_machine(line: &str) -> i64 {
    let re_target = Regex::new(r"\[([.#]+)\]").unwrap();
    let cap = re_target.captures(line);
    if cap.is_none() {
        return 0;
    }
    let target_str = &cap.unwrap()[1];
    let l = target_str.len();
    let mut target = vec![0; l];
    for (i, c) in target_str.chars().enumerate() {
        if c == '#' {
            target[i] = 1;
        }
    }

    let re_buttons = Regex::new(r"\(([\d,]+)\)").unwrap();
    let mut buttons = Vec::new();
    for cap in re_buttons.captures_iter(line) {
        let mut b = vec![0; l];
        let parts: Vec<&str> = cap[1].split(',').collect();
        for p in parts {
            if let Ok(idx) = p.parse::<usize>() {
                if idx < l {
                    b[idx] = 1;
                }
            }
        }
        buttons.push(b);
    }

    let b_count = buttons.len();
    let mut m = vec![vec![0; b_count + 1]; l];
    for r in 0..l {
        for c in 0..b_count {
            m[r][c] = buttons[c][r];
        }
        m[r][b_count] = target[r];
    }

    let mut pivot_row = 0;
    let mut pivot_cols = Vec::new();
    let mut col_to_pivot_row = vec![-1; b_count];

    for c in 0..b_count {
        if pivot_row >= l {
            break;
        }

        let mut sel = -1;
        for r in pivot_row..l {
            if m[r][c] == 1 {
                sel = r as i32;
                break;
            }
        }

        if sel == -1 {
            continue;
        }

        let sel = sel as usize;
        m.swap(pivot_row, sel);

        for r in 0..l {
            if r != pivot_row && m[r][c] == 1 {
                for k in c..=b_count {
                    m[r][k] ^= m[pivot_row][k];
                }
            }
        }

        pivot_cols.push(c);
        col_to_pivot_row[c] = pivot_row as i32;
        pivot_row += 1;
    }

    for r in pivot_row..l {
        if m[r][b_count] == 1 {
            return 0;
        }
    }

    let mut free_cols = Vec::new();
    for c in 0..b_count {
        if !pivot_cols.contains(&c) {
            free_cols.push(c);
        }
    }

    let mut min_presses = i64::MAX;
    let num_free = free_cols.len();
    let combinations = 1 << num_free;

    for i in 0..combinations {
        let mut x = vec![0; b_count];
        let mut current_presses = 0;

        for k in 0..num_free {
            if (i & (1 << k)) != 0 {
                x[free_cols[k]] = 1;
                current_presses += 1;
            }
        }

        for &p_col in &pivot_cols {
            let r = col_to_pivot_row[p_col] as usize;
            let mut val = m[r][b_count];
            for &f_col in &free_cols {
                if m[r][f_col] == 1 && x[f_col] == 1 {
                    val ^= 1;
                }
            }
            x[p_col] = val;
            if val == 1 {
                current_presses += 1;
            }
        }

        if current_presses < min_presses {
            min_presses = current_presses;
        }
    }

    min_presses
}

fn solve_part2(line: &str) -> i64 {
    let re_target = Regex::new(r"\{([\d,]+)\}").unwrap();
    let cap = re_target.captures(line);
    if cap.is_none() {
        return 0;
    }
    let target_str = &cap.unwrap()[1];
    let target: Vec<f64> = target_str.split(',').map(|s| s.parse().unwrap()).collect();
    let l = target.len();

    let re_buttons = Regex::new(r"\(([\d,]+)\)").unwrap();
    let mut a_cols = Vec::new();
    for cap in re_buttons.captures_iter(line) {
        let mut col = vec![0.0; l];
        let parts: Vec<&str> = cap[1].split(',').collect();
        for p in parts {
            if let Ok(idx) = p.parse::<usize>() {
                if idx < l {
                    col[idx] = 1.0;
                }
            }
        }
        a_cols.push(col);
    }

    let b_count = a_cols.len();
    let mut matrix = vec![vec![0.0; b_count + 1]; l];
    for r in 0..l {
        for c in 0..b_count {
            matrix[r][c] = a_cols[c][r];
        }
        matrix[r][b_count] = target[r];
    }

    let mut pivot_row = 0;
    let mut pivot_cols = Vec::new();
    let mut col_to_pivot_row = vec![-1; b_count];

    for c in 0..b_count {
        if pivot_row >= l { break; }

        let mut sel = -1;
        for r in pivot_row..l {
            if matrix[r][c].abs() > 1e-9 {
                sel = r as i32;
                break;
            }
        }

        if sel == -1 { continue; }

        let sel = sel as usize;
        matrix.swap(pivot_row, sel);

        let pivot_val = matrix[pivot_row][c];
        for k in c..=b_count {
            matrix[pivot_row][k] /= pivot_val;
        }

        for r in 0..l {
            if r != pivot_row && matrix[r][c].abs() > 1e-9 {
                let factor = matrix[r][c];
                for k in c..=b_count {
                    matrix[r][k] -= factor * matrix[pivot_row][k];
                }
            }
        }

        pivot_cols.push(c);
        col_to_pivot_row[c] = pivot_row as i32;
        pivot_row += 1;
    }

    for r in pivot_row..l {
        if matrix[r][b_count].abs() > 1e-9 {
            return 0;
        }
    }

    let mut free_cols = Vec::new();
    for c in 0..b_count {
        if !pivot_cols.contains(&c) {
            free_cols.push(c);
        }
    }

    let mut ubs = vec![0; b_count];
    for c in 0..b_count {
        let mut min_ub = i64::MAX;
        let mut bounded = false;
        for r in 0..l {
            if a_cols[c][r] > 0.5 {
                let val = (target[r] / a_cols[c][r]).floor() as i64;
                if val < min_ub {
                    min_ub = val;
                }
                bounded = true;
            }
        }
        ubs[c] = if bounded { min_ub } else { 0 };
    }

    let mut min_total_presses = i64::MAX;
    let mut found = false;
    let mut current_free_vals = vec![0; free_cols.len()];

    search(0, &free_cols, &mut current_free_vals, &ubs, &pivot_cols, &col_to_pivot_row, &matrix, &mut min_total_presses, &mut found);

    if found { min_total_presses } else { 0 }
}

fn search(
    free_idx: usize,
    free_cols: &Vec<usize>,
    current_free_vals: &mut Vec<i64>,
    ubs: &Vec<i64>,
    pivot_cols: &Vec<usize>,
    col_to_pivot_row: &Vec<i32>,
    matrix: &Vec<Vec<f64>>,
    min_total_presses: &mut i64,
    found: &mut bool
) {
    if free_idx == free_cols.len() {
        let mut current_presses: i64 = current_free_vals.iter().sum();
        let mut possible = true;

        for &p_col in pivot_cols {
            let r = col_to_pivot_row[p_col] as usize;
            let mut val = matrix[r][matrix[0].len() - 1];
            for (j, &f_col) in free_cols.iter().enumerate() {
                val -= matrix[r][f_col] * (current_free_vals[j] as f64);
            }

            if val < -1e-9 { possible = false; break; }
            let long_val = val.round() as i64;
            if (val - (long_val as f64)).abs() > 1e-9 { possible = false; break; }
            current_presses += long_val;
        }

        if possible {
            if current_presses < *min_total_presses {
                *min_total_presses = current_presses;
                *found = true;
            }
        }
        return;
    }

    let f_col_idx = free_cols[free_idx];
    let limit = ubs[f_col_idx];

    for val in 0..=limit {
        current_free_vals[free_idx] = val;
        search(free_idx + 1, free_cols, current_free_vals, ubs, pivot_cols, col_to_pivot_row, matrix, min_total_presses, found);
    }
}
