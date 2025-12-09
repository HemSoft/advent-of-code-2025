use std::fs;
use std::collections::HashSet;

fn main() {
    let content = fs::read_to_string("input.txt").expect("Error reading input.txt");
    let lines: Vec<&str> = content.lines().collect();

    if lines.is_empty() {
        return;
    }

    let width = lines[0].len();
    let height = lines.len();

    let mut start_col = None;
    let mut start_row = 0;

    for (r, line) in lines.iter().enumerate() {
        if let Some(idx) = line.find('S') {
            start_col = Some(idx);
            start_row = r;
            break;
        }
    }

    let start_col = match start_col {
        Some(c) => c,
        None => {
            println!("Start not found");
            return;
        }
    };

    let mut active_beams: HashSet<usize> = HashSet::new();
    active_beams.insert(start_col);
    let mut total_splits = 0;

    for r in (start_row + 1)..height {
        let mut next_beams: HashSet<usize> = HashSet::new();
        let line_chars: Vec<char> = lines[r].chars().collect();

        for &c in &active_beams {
            if c >= width { continue; }

            let char = line_chars[c];
            if char == '^' {
                total_splits += 1;
                if c > 0 {
                    next_beams.insert(c - 1);
                }
                if c + 1 < width {
                    next_beams.insert(c + 1);
                }
            } else {
                next_beams.insert(c);
            }
        }
        active_beams = next_beams;
        if active_beams.is_empty() {
            break;
        }
    }

    println!("Day 07 Part 1: {}", total_splits);

    // Part 2
    use std::collections::HashMap;

    struct Solver<'a> {
        lines: &'a Vec<&'a str>,
        width: usize,
        height: usize,
        memo: HashMap<(usize, usize), u64>,
    }

    impl<'a> Solver<'a> {
        fn count_paths(&mut self, r: usize, c: usize) -> u64 {
            if c >= self.width {
                return 1;
            }

            if let Some(&res) = self.memo.get(&(r, c)) {
                return res;
            }

            for curr_r in (r + 1)..self.height {
                let char = self.lines[curr_r].as_bytes()[c] as char;
                if char == '^' {
                    let left_res = if c > 0 { self.count_paths(curr_r, c - 1) } else { 1 };
                    let right_res = self.count_paths(curr_r, c + 1);
                    let res = left_res + right_res;
                    self.memo.insert((r, c), res);
                    return res;
                }
            }

            self.memo.insert((r, c), 1);
            1
        }
    }

    let mut solver = Solver {
        lines: &lines,
        width,
        height,
        memo: HashMap::new(),
    };

    let part2_ans = solver.count_paths(start_row, start_col);
    println!("Day 07 Part 2: {}", part2_ans);
}
