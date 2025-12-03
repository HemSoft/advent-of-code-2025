use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let file = File::open("input.txt").expect("Failed to read input");
    let reader = BufReader::new(file);

    let mut position: i32 = 50;
    let mut zero_count: i64 = 0;

    for line_result in reader.lines() {
        let line = line_result.expect("Failed to read line");
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let dir = line.chars().next().unwrap();
        let distance_str: String = line.chars().skip(1).collect();
        let mut distance: i32 = distance_str.parse().expect("Invalid distance");
        distance %= 100;

        match dir {
            'R' => {
                position = (position + distance) % 100;
            }
            'L' => {
                position = (position - distance) % 100;
                if position < 0 {
                    position += 100;
                }
            }
            _ => {}
        }

        if position == 0 {
            zero_count += 1;
        }
    }

    // Part 1
    let part1: i64 = zero_count;
    println!("Day 01 Part 1: {}", part1);

    // Part 2 (not implemented yet)
    let part2: i64 = 0;
    println!("Day 01 Part 2: {}", part2);
}
