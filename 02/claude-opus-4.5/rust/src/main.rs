use std::fs;

fn is_invalid_id_part1(num: i64) -> bool {
    let s = num.to_string();
    if s.len() % 2 != 0 {
        return false;
    }
    let half = s.len() / 2;
    &s[..half] == &s[half..]
}

fn is_invalid_id_part2(num: i64) -> bool {
    let s = num.to_string();
    // Check for patterns repeated at least twice
    for pattern_len in 1..=s.len() / 2 {
        if s.len() % pattern_len != 0 {
            continue;
        }
        let pattern = &s[..pattern_len];
        let repetitions = s.len() / pattern_len;
        if repetitions < 2 {
            continue;
        }
        let mut is_repeated = true;
        for i in 1..repetitions {
            if &s[i * pattern_len..(i + 1) * pattern_len] != pattern {
                is_repeated = false;
                break;
            }
        }
        if is_repeated {
            return true;
        }
    }
    false
}

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    // Part 1
    let mut part1: i64 = 0;
    for range in input.split(',').filter(|r| !r.is_empty()) {
        let parts: Vec<&str> = range.split('-').collect();
        let start: i64 = parts[0].parse().unwrap();
        let end: i64 = parts[1].parse().unwrap();
        for id in start..=end {
            if is_invalid_id_part1(id) {
                part1 += id;
            }
        }
    }
    println!("Day 02 Part 1: {}", part1);

    // Part 2
    let mut part2: i64 = 0;
    for range in input.split(',').filter(|r| !r.is_empty()) {
        let parts: Vec<&str> = range.split('-').collect();
        let start: i64 = parts[0].parse().unwrap();
        let end: i64 = parts[1].parse().unwrap();
        for id in start..=end {
            if is_invalid_id_part2(id) {
                part2 += id;
            }
        }
    }
    println!("Day 02 Part 2: {}", part2);
}
