use std::fs;

#[derive(Debug, Clone, Copy)]
struct Interval {
    start: i64,
    end: i64,
}

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");
    let mut lines: Vec<&str> = input
        .lines()
        .map(|l| l.trim())
        .filter(|l| !l.is_empty())
        .collect();

    let mut ranges: Vec<Interval> = Vec::new();
    let mut available: Vec<i64> = Vec::new();

    let mut index = 0usize;
    while index < lines.len() && lines[index].contains('-') {
        let line = lines[index];
        let parts: Vec<&str> = line.splitn(2, '-').collect();
        if parts.len() == 2 {
            if let (Ok(mut start), Ok(mut end)) = (parts[0].trim().parse::<i64>(), parts[1].trim().parse::<i64>()) {
                if end < start {
                    std::mem::swap(&mut start, &mut end);
                }
                ranges.push(Interval { start, end });
            }
        }
        index += 1;
    }

    while index < lines.len() {
        let line = lines[index];
        if !line.is_empty() {
            if let Ok(id) = line.parse::<i64>() {
                available.push(id);
            }
        }
        index += 1;
    }

    ranges.sort_by(|a, b| {
        let cmp = a.start.cmp(&b.start);
        if cmp == std::cmp::Ordering::Equal {
            a.end.cmp(&b.end)
        } else {
            cmp
        }
    });

    let mut merged: Vec<Interval> = Vec::new();
    for r in ranges {
        if let Some(last) = merged.last_mut() {
            if r.start <= last.end + 1 {
                if r.end > last.end {
                    last.end = r.end;
                }
                continue;
            }
        }
        merged.push(r);
    }

    let mut part1: i64 = 0;
    for id in &available {
        for r in &merged {
            if *id < r.start {
                break;
            }
            if *id <= r.end {
                part1 += 1;
                break;
            }
        }
    }
    println!("Day 05 Part 1: {}", part1);

    let mut part2: i64 = 0;
    for r in &merged {
        part2 += r.end - r.start + 1;
    }
    println!("Day 05 Part 2: {}", part2);
}