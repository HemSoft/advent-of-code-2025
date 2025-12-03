use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Unable to read file");
    let mut pos = 50;
    let mut count = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let dir = line.chars().next().unwrap();
        let amount: i32 = line[1..].parse().unwrap();

        if dir == 'R' {
            pos = (pos + amount) % 100;
        } else if dir == 'L' {
            pos = (pos - amount) % 100;
            if pos < 0 {
                pos += 100;
            }
        }

        if pos == 0 {
            count += 1;
        }
    }

    println!("Day 01 Part 1: {}", count);
}
