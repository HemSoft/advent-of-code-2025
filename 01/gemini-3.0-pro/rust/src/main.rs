use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Unable to read file");

    // Part 1
    let mut pos1 = 50;
    let mut count1 = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let dir = line.chars().next().unwrap();
        let amount: i32 = line[1..].parse().unwrap();

        if dir == 'R' {
            pos1 = (pos1 + amount) % 100;
        } else if dir == 'L' {
            pos1 = (pos1 - amount) % 100;
            if pos1 < 0 {
                pos1 += 100;
            }
        }

        if pos1 == 0 {
            count1 += 1;
        }
    }

    println!("Day 01 Part 1: {}", count1);

    // Part 2
    let mut pos2 = 50;
    let mut count2 = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let dir = line.chars().next().unwrap();
        let amount: i32 = line[1..].parse().unwrap();

        for _ in 0..amount {
            if dir == 'R' {
                pos2 = (pos2 + 1) % 100;
            } else if dir == 'L' {
                pos2 -= 1;
                if pos2 < 0 {
                    pos2 = 99;
                }
            }

            if pos2 == 0 {
                count2 += 1;
            }
        }
    }

    println!("Day 01 Part 2: {}", count2);
}
