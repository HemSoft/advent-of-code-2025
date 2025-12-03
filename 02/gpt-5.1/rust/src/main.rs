use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    let part1 = sum_invalid_ids(&input);
    println!("Day 02 Part 1: {}", part1);

    let part2 = sum_invalid_ids_part2(&input);
    println!("Day 02 Part 2: {}", part2);
}

fn sum_invalid_ids(input: &str) -> i64 {
    let mut sum: i64 = 0;
    for range in input.split(',') {
        let r = range.trim();
        if r.is_empty() {
            continue;
        }
        let parts: Vec<&str> = r.split('-').map(|s| s.trim()).collect();
        if parts.len() != 2 {
            continue;
        }
        let mut start: i64 = match parts[0].parse() {
            Ok(v) => v,
            Err(_) => continue,
        };
        let mut end: i64 = match parts[1].parse() {
            Ok(v) => v,
            Err(_) => continue,
        };
        if end < start {
            std::mem::swap(&mut start, &mut end);
        }

        let min_len = digits_count(start);
        let max_len = digits_count(end);
        for len in min_len..=max_len {
            if len % 2 != 0 {
                continue;
            }

            let half = len / 2;
            let pow10 = pow10_i64(half);
            let first = pow10_i64(len - 1);
            let last = pow10_i64(len) - 1;

            let low = std::cmp::max(start, first);
            let high = std::cmp::min(end, last);
            if low > high {
                continue;
            }

            let den = (pow10 + 1) as f64;
            let a_start = (low as f64 / den).ceil() as i64;
            let a_end = (high as f64 / den).floor() as i64;
            if a_start > a_end {
                continue;
            }

            let count = a_end - a_start + 1;
            let terms_sum = (a_start + a_end) * count / 2;
            let contrib = terms_sum * (pow10 + 1);
            sum += contrib;
        }
    }

    sum
}

fn sum_invalid_ids_part2(input: &str) -> i64 {
    let mut sum: i64 = 0;
    for range in input.split(',') {
        let r = range.trim();
        if r.is_empty() {
            continue;
        }
        let parts: Vec<&str> = r.split('-').map(|s| s.trim()).collect();
        if parts.len() != 2 {
            continue;
        }
        let mut start: i64 = match parts[0].parse() {
            Ok(v) => v,
            Err(_) => continue,
        };
        let mut end: i64 = match parts[1].parse() {
            Ok(v) => v,
            Err(_) => continue,
        };
        if end < start {
            std::mem::swap(&mut start, &mut end);
        }

        let min_len = digits_count(start);
        let max_len = digits_count(end);
        for len in min_len..=max_len {
            for k in 2.. {
                if k * k > len { break; }
                if len % k != 0 { continue; }

                let base_len = len / k;
                let pow10_base = pow10_i64(base_len);
                let first = pow10_i64(len - 1);
                let last = pow10_i64(len) - 1;

                let low = std::cmp::max(start, first);
                let high = std::cmp::min(end, last);
                if low > high { continue; }

                let mut geom: i64 = 0;
                let mut factor: i64 = 1;
                for _i in 0..k {
                    geom += factor;
                    factor *= pow10_base;
                }

                let a_start = ((low as f64) / (geom as f64)).ceil() as i64;
                let a_end = ((high as f64) / (geom as f64)).floor() as i64;
                if a_start > a_end { continue; }

                let count = a_end - a_start + 1;
                let terms_sum = (a_start + a_end) * count / 2;
                let contrib = terms_sum * geom;
                sum += contrib;
            }
        }
    }

    sum
}

fn digits_count(mut n: i64) -> i32 {
    if n < 0 {
        n = -n;
    }
    let mut count = 1;
    while n >= 10 {
        n /= 10;
        count += 1;
    }
    count
}

fn pow10_i64(exp: i32) -> i64 {
    let mut res: i64 = 1;
    for _ in 0..exp {
        res *= 10;
    }
    res
}
