use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    let ranges: Vec<&str> = input.split(',').collect();
    let mut total_sum: i64 = 0;

    for range in &ranges {
        let parts: Vec<&str> = range.trim().split('-').collect();
        if parts.len() != 2 {
            continue;
        }

        let start: i64 = parts[0].parse().unwrap();
        let end: i64 = parts[1].parse().unwrap();

        for i in start..=end {
            if is_invalid_id(i) {
                total_sum += i;
            }
        }
    }

    println!("Day 02 Part 1: {}", total_sum);

    let mut total_sum_part2: i64 = 0;

    for range in &ranges {
        let parts: Vec<&str> = range.trim().split('-').collect();
        if parts.len() != 2 {
            continue;
        }

        let start: i64 = parts[0].parse().unwrap();
        let end: i64 = parts[1].parse().unwrap();

        for i in start..=end {
            if is_invalid_id_part2(i) {
                total_sum_part2 += i;
            }
        }
    }

    println!("Day 02 Part 2: {}", total_sum_part2);
}

fn is_invalid_id(id: i64) -> bool {
    let s = id.to_string();
    if s.len() % 2 != 0 {
        return false;
    }

    let half_len = s.len() / 2;
    let first_half = &s[0..half_len];
    let second_half = &s[half_len..];

    first_half == second_half
}

fn is_invalid_id_part2(id: i64) -> bool {
    let s = id.to_string();
    let len = s.len();

    for pattern_len in 1..=len / 2 {
        if len % pattern_len != 0 {
            continue;
        }

        let pattern = &s[0..pattern_len];
        let repetitions = len / pattern_len;

        if pattern.repeat(repetitions) == s {
            return true;
        }
    }

    false
}
