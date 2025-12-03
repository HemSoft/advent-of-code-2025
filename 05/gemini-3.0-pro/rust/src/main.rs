use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    // Part 1
    let part1: i64 = 0;
    println!("Day 05 Part 1: {}", part1);

    // Part 2
    let part2: i64 = 0;
    println!("Day 05 Part 2: {}", part2);
}