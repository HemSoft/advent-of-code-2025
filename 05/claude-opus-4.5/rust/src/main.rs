use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input");
    let input = input.trim().replace("\r\n", "\n");

    let sections: Vec<&str> = input.split("\n\n").collect();

    let ranges: Vec<(i64, i64)> = sections[0]
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            let parts: Vec<&str> = line.trim().split('-').collect();
            (parts[0].parse().unwrap(), parts[1].parse().unwrap())
        })
        .collect();

    let ingredients: Vec<i64> = sections[1]
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| line.trim().parse().unwrap())
        .collect();

    // Part 1
    let part1: i64 = ingredients
        .iter()
        .filter(|&&id| ranges.iter().any(|&(start, end)| id >= start && id <= end))
        .count() as i64;
    println!("Day 05 Part 1: {}", part1);

    // Part 2: Merge overlapping ranges and count total unique IDs
    let mut sorted = ranges.clone();
    sorted.sort_by(|a, b| a.0.cmp(&b.0).then(a.1.cmp(&b.1)));

    let mut merged: Vec<(i64, i64)> = Vec::new();
    for (start, end) in sorted {
        if merged.is_empty() || merged.last().unwrap().1 < start - 1 {
            merged.push((start, end));
        } else {
            let last = merged.last_mut().unwrap();
            if end > last.1 {
                last.1 = end;
            }
        }
    }

    let part2: i64 = merged.iter().map(|(start, end)| end - start + 1).sum();
    println!("Day 05 Part 2: {}", part2);
}
