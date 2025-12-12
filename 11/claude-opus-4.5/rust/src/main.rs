use std::collections::HashMap;
use std::fs;

fn count_paths(
    current: &str,
    target: &str,
    graph: &HashMap<String, Vec<String>>,
    memo: &mut HashMap<String, i64>,
) -> i64 {
    if current == target {
        return 1;
    }

    if let Some(&cached) = memo.get(current) {
        return cached;
    }

    let result = match graph.get(current) {
        None => 0,
        Some(neighbors) => {
            let mut count: i64 = 0;
            for neighbor in neighbors {
                count += count_paths(neighbor, target, graph, memo);
            }
            count
        }
    };

    memo.insert(current.to_string(), result);
    result
}

fn count_paths_with_required(
    current: &str,
    target: &str,
    graph: &HashMap<String, Vec<String>>,
    visited_dac: bool,
    visited_fft: bool,
    memo: &mut HashMap<(String, bool, bool), i64>,
) -> i64 {
    let visited_dac = visited_dac || current == "dac";
    let visited_fft = visited_fft || current == "fft";

    if current == target {
        return if visited_dac && visited_fft { 1 } else { 0 };
    }

    let key = (current.to_string(), visited_dac, visited_fft);
    if let Some(&cached) = memo.get(&key) {
        return cached;
    }

    let result = match graph.get(current) {
        None => 0,
        Some(neighbors) => {
            let mut count: i64 = 0;
            for neighbor in neighbors {
                count += count_paths_with_required(neighbor, target, graph, visited_dac, visited_fft, memo);
            }
            count
        }
    };

    memo.insert(key, result);
    result
}

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");

    let mut graph: HashMap<String, Vec<String>> = HashMap::new();

    for line in input.lines() {
        if line.trim().is_empty() {
            continue;
        }
        let parts: Vec<&str> = line.split(':').collect();
        let source = parts[0].trim().to_string();
        let destinations: Vec<String> = parts[1]
            .trim()
            .split_whitespace()
            .map(|s| s.to_string())
            .collect();
        graph.insert(source, destinations);
    }

    // Part 1
    let mut memo1: HashMap<String, i64> = HashMap::new();
    let part1: i64 = count_paths("you", "out", &graph, &mut memo1);
    println!("Day 11 Part 1: {}", part1);

    // Part 2
    let mut memo2: HashMap<(String, bool, bool), i64> = HashMap::new();
    let part2: i64 = count_paths_with_required("svr", "out", &graph, false, false, &mut memo2);
    println!("Day 11 Part 2: {}", part2);
}
