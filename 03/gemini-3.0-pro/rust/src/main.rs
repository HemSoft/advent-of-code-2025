use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input");

    let mut total_joltage: i64 = 0;

    for line in input.lines() {
        if line.trim().is_empty() {
            continue;
        }

        let mut max_joltage = 0;
        let mut found = false;

        for d1 in (1..=9).rev() {
            let c1 = char::from_digit(d1, 10).unwrap();
            let idx1 = line.find(c1);

            if idx1.is_none() {
                continue;
            }
            let idx1 = idx1.unwrap();

            for d2 in (1..=9).rev() {
                let c2 = char::from_digit(d2, 10).unwrap();
                let idx2 = line.rfind(c2);

                if idx2.is_none() {
                    continue;
                }
                let idx2 = idx2.unwrap();

                if idx1 < idx2 {
                    max_joltage = d1 * 10 + d2;
                    found = true;
                    break;
                }
            }
            if found {
                break;
            }
        }
        total_joltage += max_joltage as i64;
    }

    println!("Day 03 Part 1: {}", total_joltage);

    let mut total_joltage_part2: i64 = 0;

    for line in input.lines() {
        if line.trim().is_empty() {
            continue;
        }

        let mut result = String::new();
        let mut current_index = 0;
        let digits_needed = 12;
        let len = line.len();

        for i in 0..digits_needed {
            let remaining_needed = digits_needed - 1 - i;
            let search_end_index = len - 1 - remaining_needed;

            let mut best_digit = -1;
            let mut best_digit_index = -1;

            for d in (1..=9).rev() {
                let c = char::from_digit(d, 10).unwrap();
                // Find first occurrence starting from current_index
                if let Some(idx) = line[current_index..].find(c) {
                    let real_idx = current_index + idx;
                    if real_idx <= search_end_index {
                        best_digit = d as i32;
                        best_digit_index = real_idx as i32;
                        break;
                    }
                }
            }

            if best_digit != -1 {
                result.push_str(&best_digit.to_string());
                current_index = (best_digit_index + 1) as usize;
            }
        }

        if result.len() == 12 {
            total_joltage_part2 += result.parse::<i64>().unwrap();
        }
    }

    println!("Day 03 Part 2: {}", total_joltage_part2);
}
