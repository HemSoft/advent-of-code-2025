use std::fs;

struct Range {
    start: i64,
    end: i64,
}

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .replace("\r\n", "\n");

    let parts: Vec<&str> = input.split("\n\n").collect();
    let ranges_lines = parts[0].lines();
    let ids_lines = parts[1].lines();

    let mut ranges = Vec::new();
    for line in ranges_lines {
        let split: Vec<&str> = line.split('-').collect();
        let start: i64 = split[0].parse().unwrap();
        let end: i64 = split[1].parse().unwrap();
        ranges.push(Range { start, end });
    }

    let mut part1: i64 = 0;
    for line in ids_lines {
        let id: i64 = line.parse().unwrap();
        let mut is_fresh = false;
        for range in &ranges {
            if id >= range.start && id <= range.end {
                is_fresh = true;
                break;
            }
        }
        if is_fresh {
            part1 += 1;
        }
    }

    println!("Day 05 Part 1: {}", part1);

    // Part 2
    ranges.sort_by(|a, b| a.start.cmp(&b.start));

    let mut merged_ranges: Vec<Range> = Vec::new();

    if !ranges.is_empty() {
        let mut curr_start = ranges[0].start;
        let mut curr_end = ranges[0].end;

        for i in 1..ranges.len() {
            let next_start = ranges[i].start;
            let next_end = ranges[i].end;

            if next_start <= curr_end + 1 {
                if next_end > curr_end {
                    curr_end = next_end;
                }
            } else {
                merged_ranges.push(Range { start: curr_start, end: curr_end });
                curr_start = next_start;
                curr_end = next_end;
            }
        }
        merged_ranges.push(Range { start: curr_start, end: curr_end });
    }

    let mut part2: i64 = 0;
    for range in merged_ranges {
        part2 += range.end - range.start + 1;
    }

    println!("Day 05 Part 2: {}", part2);
}
