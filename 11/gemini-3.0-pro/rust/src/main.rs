use std::collections::HashMap;
use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").expect("Unable to read file");
    let mut graph: HashMap<String, Vec<String>> = HashMap::new();

    for line in input.lines() {
        if line.trim().is_empty() {
            continue;
        }
        let parts: Vec<&str> = line.split(": ").collect();
        let source = parts[0].to_string();
        let targets: Vec<String> = parts[1].split_whitespace().map(|s| s.to_string()).collect();
        graph.insert(source, targets);
    }

    // Part 1
    let mut memo1: HashMap<String, u64> = HashMap::new();
    let paths1 = count_paths_p1("you", &graph, &mut memo1);
    println!("Day 11 Part 1: {}", paths1);

    // Part 2
    let mut memo2: HashMap<(String, u8), u64> = HashMap::new();
    let paths2 = count_paths_p2("svr", 0, &graph, &mut memo2);
    println!("Day 11 Part 2: {}", paths2);
}

fn count_paths_p1(current: &str, graph: &HashMap<String, Vec<String>>, memo: &mut HashMap<String, u64>) -> u64 {
    if current == "out" {
        return 1;
    }
    if let Some(&count) = memo.get(current) {
        return count;
    }

    let mut total = 0;
    if let Some(neighbors) = graph.get(current) {
        for neighbor in neighbors {
            total += count_paths_p1(neighbor, graph, memo);
        }
    }

    memo.insert(current.to_string(), total);
    total
}

fn count_paths_p2(current: &str, mut mask: u8, graph: &HashMap<String, Vec<String>>, memo: &mut HashMap<(String, u8), u64>) -> u64 {
    if current == "dac" {
        mask |= 1;
    } else if current == "fft" {
        mask |= 2;
    }

    if current == "out" {
        return if mask == 3 { 1 } else { 0 };
    }

    let key = (current.to_string(), mask);
    if let Some(&count) = memo.get(&key) {
        return count;
    }

    let mut total = 0;
    if let Some(neighbors) = graph.get(current) {
        for neighbor in neighbors {
            total += count_paths_p2(neighbor, mask, graph, memo);
        }
    }

    memo.insert(key, total);
    total
}
