use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");

    let mut position: i32 = 50;
    let mut zero_count_part1 = 0;
    let mut zero_count_part2 = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let direction = line.chars().next().unwrap();
        let distance: i32 = line[1..].parse().unwrap();

        let (new_position, first_hit) = if direction == 'L' {
            let new_pos = ((position - distance) % 100 + 100) % 100;
            let fh = if position == 0 { 100 } else { position };
            (new_pos, fh)
        } else {
            let new_pos = (position + distance) % 100;
            let fh = if position == 0 { 100 } else { 100 - position };
            (new_pos, fh)
        };

        if new_position == 0 {
            zero_count_part1 += 1;
        }

        if first_hit <= distance {
            zero_count_part2 += 1 + (distance - first_hit) / 100;
        }

        position = new_position;
    }

    println!("Day 01 Part 1: {}", zero_count_part1);
    println!("Day 01 Part 2: {}", zero_count_part2);
}
