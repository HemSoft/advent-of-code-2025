use std::fs;

fn max_joltage(line: &str) -> i64 {
    let chars: Vec<char> = line.chars().collect();
    let n = chars.len();
    if n < 2 {
        return 0;
    }

    // Precompute suffix maximum
    let mut suffix_max = vec![0i64; n];
    for i in (0..n - 1).rev() {
        let digit = chars[i + 1].to_digit(10).unwrap() as i64;
        suffix_max[i] = digit.max(suffix_max[i + 1]);
    }

    // Find max joltage
    let mut max_j: i64 = 0;
    for i in 0..n - 1 {
        let tens_digit = chars[i].to_digit(10).unwrap() as i64;
        let units_digit = suffix_max[i];
        let joltage = tens_digit * 10 + units_digit;
        max_j = max_j.max(joltage);
    }

    max_j
}

fn max_joltage_part2(line: &str, k: usize) -> i64 {
    let chars: Vec<char> = line.chars().collect();
    let n = chars.len();
    if n < k {
        return 0;
    }
    if n == k {
        return line.parse().unwrap();
    }

    // Greedy: pick k digits to form largest number
    let mut result = String::new();
    let mut start_idx = 0;

    for i in 0..k {
        let remaining = k - i;
        let end_idx = n - remaining;

        let mut max_digit = '0';
        let mut max_pos = start_idx;

        for j in start_idx..=end_idx {
            if chars[j] > max_digit {
                max_digit = chars[j];
                max_pos = j;
            }
        }

        result.push(max_digit);
        start_idx = max_pos + 1;
    }

    result.parse().unwrap()
}

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input");

    let lines: Vec<&str> = input.lines().filter(|l| !l.trim().is_empty()).collect();

    // Part 1
    let part1: i64 = lines.iter().map(|line| max_joltage(line.trim())).sum();
    println!("Day 03 Part 1: {}", part1);

    // Part 2
    let part2: i64 = lines.iter().map(|line| max_joltage_part2(line.trim(), 12)).sum();
    println!("Day 03 Part 2: {}", part2);
}
