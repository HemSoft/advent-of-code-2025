use std::collections::HashMap;
use std::fs;

fn parse_graph(input: &str) -> HashMap<String, Vec<String>> {
    let mut graph: HashMap<String, Vec<String>> = HashMap::new();

    for raw_line in input.lines() {
        let line = raw_line.trim();
        if line.is_empty() {
            continue;
        }

        let parts: Vec<&str> = line.splitn(2, ':').collect();
        if parts.len() != 2 {
            continue;
        }

        let from = parts[0].trim().to_string();
        let targets_part = parts[1].trim();

        let mut targets: Vec<String> = Vec::new();
        if !targets_part.is_empty() {
            for t in targets_part.split_whitespace() {
                let tt = t.trim();
                if !tt.is_empty() {
                    targets.push(tt.to_string());
                }
            }
        }

        graph.insert(from, targets);
    }

    graph
}

fn count_paths(
    node: &str,
    destination: &str,
    graph: &HashMap<String, Vec<String>>,
    memo: &mut HashMap<String, i64>,
) -> i64 {
    if node == destination {
        return 1;
    }

    if let Some(&cached) = memo.get(node) {
        return cached;
    }

    let mut total: i64 = 0;
    if let Some(children) = graph.get(node) {
        for child in children {
            total += count_paths(child, destination, graph, memo);
        }
    }

    memo.insert(node.to_string(), total);
    total
}

fn count_paths_with_required_nodes(
    node: &str,
    destination: &str,
    graph: &HashMap<String, Vec<String>>,
    memo: &mut HashMap<(String, i32), i64>,
    mask: i32,
) -> i64 {
    let mut updated_mask = mask;
    if node == "fft" {
        updated_mask |= 1;
    } else if node == "dac" {
        updated_mask |= 2;
    }

    if node == destination {
        return if (updated_mask & 0b11) == 0b11 { 1 } else { 0 };
    }

    let key = (node.to_string(), updated_mask);
    if let Some(&cached) = memo.get(&key) {
        return cached;
    }

    let mut total: i64 = 0;
    if let Some(children) = graph.get(node) {
        for child in children {
            total += count_paths_with_required_nodes(child, destination, graph, memo, updated_mask);
        }
    }

    memo.insert(key, total);
    total
}

fn run_example_test() {
    let example = r#"
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
"#
    .trim();

    let graph = parse_graph(example);
    let mut memo: HashMap<String, i64> = HashMap::new();
    let paths = count_paths("you", "out", &graph, &mut memo);

    if paths != 5 {
        eprintln!("Example test failed: expected 5, got {}", paths);
    }
}

fn run_part2_example_test() {
    let example = r#"
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
"#
    .trim();

    let graph = parse_graph(example);
    let mut memo: HashMap<(String, i32), i64> = HashMap::new();
    let paths = count_paths_with_required_nodes("svr", "out", &graph, &mut memo, 0);

    if paths != 2 {
        eprintln!("Part 2 example test failed: expected 2, got {}", paths);
    }
}

fn main() {
    run_example_test();

    run_part2_example_test();

    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    let graph_real = parse_graph(&input);
    let mut memo_real: HashMap<String, i64> = HashMap::new();
    let part1 = count_paths("you", "out", &graph_real, &mut memo_real);
    println!("Day 11 Part 1: {}", part1);

    let mut memo_part2: HashMap<(String, i32), i64> = HashMap::new();
    let part2 = count_paths_with_required_nodes("svr", "out", &graph_real, &mut memo_part2, 0);
    println!("Day 11 Part 2: {}", part2);
}
