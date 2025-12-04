use std::fs;

fn main() {
    let contents = fs::read_to_string("input.txt").expect("Failed to read input");

    let mut total_joltage_part1: i64 = 0;
    let mut total_joltage_part2: i64 = 0;

    for line in contents.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let mut max_joltage_part1 = 0;
        let mut found = false;

        for d1 in (1..=9).rev() {
            if found {
                break;
            }

            let c1 = (b'0' + d1 as u8) as char;
            let idx1 = line.find(c1);
            if idx1.is_none() {
                continue;
            }
            let idx1 = idx1.unwrap();

            for d2 in (1..=9).rev() {
                let c2 = (b'0' + d2 as u8) as char;
                let idx2 = line.rfind(c2);
                if idx2.is_none() {
                    continue;
                }
                let idx2 = idx2.unwrap();

                if idx1 < idx2 {
                    max_joltage_part1 = d1 * 10 + d2;
                    found = true;
                    break;
                }
            }
        }

        total_joltage_part1 += max_joltage_part1;

        // Part 2: choose exactly 12 digits to form the largest possible number in order
        let digits = line.as_bytes();
        let target_length = 12usize;
        let mut chosen: Vec<u8> = Vec::with_capacity(target_length);
        let mut start = 0usize;

        for pos in 0..target_length {
            let remaining_needed = target_length - pos - 1;
            let mut best_digit: Option<u8> = None;
            let mut best_index: Option<usize> = None;

            for d in (0u8..=9u8).rev() {
                let ch = b'0' + d;
                let mut last_index: Option<usize> = None;
                for i in start..digits.len() {
                    if digits[i] == ch {
                        last_index = Some(i);
                    }
                }

                if let Some(idx) = last_index {
                    if idx <= digits.len() - 1 - remaining_needed {
                        best_digit = Some(ch);
                        best_index = Some(idx);
                        break;
                    }
                }
            }

            let (chosen_digit, idx) = if let (Some(d), Some(i)) = (best_digit, best_index) {
                (d, i)
            } else {
                (digits[start], start)
            };

            chosen.push(chosen_digit);
            start = idx + 1;
        }

        let mut line_joltage_part2: i64 = 0;
        for ch in chosen {
            line_joltage_part2 = line_joltage_part2 * 10 + (ch - b'0') as i64;
        }

        total_joltage_part2 += line_joltage_part2;
    }

    println!("Day 03 Part 1: {}", total_joltage_part1);
    println!("Day 03 Part 2: {}", total_joltage_part2);
}
