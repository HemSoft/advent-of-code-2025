use std::collections::HashMap;
use std::fs;

struct UnionFind {
    parent: Vec<usize>,
    rank: Vec<usize>,
}

impl UnionFind {
    fn new(n: usize) -> Self {
        UnionFind {
            parent: (0..n).collect(),
            rank: vec![0; n],
        }
    }

    fn find(&mut self, x: usize) -> usize {
        if self.parent[x] != x {
            self.parent[x] = self.find(self.parent[x]);
        }
        self.parent[x]
    }

    fn unite(&mut self, x: usize, y: usize) -> bool {
        let mut px = self.find(x);
        let mut py = self.find(y);
        if px == py {
            return false;
        }
        if self.rank[px] < self.rank[py] {
            std::mem::swap(&mut px, &mut py);
        }
        self.parent[py] = px;
        if self.rank[px] == self.rank[py] {
            self.rank[px] += 1;
        }
        true
    }

    fn reset(&mut self) {
        let n = self.parent.len();
        for i in 0..n {
            self.parent[i] = i;
            self.rank[i] = 0;
        }
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").expect("Failed to read input");

    let points: Vec<(i64, i64, i64)> = input
        .lines()
        .filter(|l| !l.trim().is_empty())
        .map(|line| {
            let parts: Vec<i64> = line.split(',').map(|s| s.trim().parse().unwrap()).collect();
            (parts[0], parts[1], parts[2])
        })
        .collect();

    let n = points.len();

    // Calculate all pairwise distances
    let mut pairs: Vec<(i64, usize, usize)> = Vec::new();
    for i in 0..n {
        for j in (i + 1)..n {
            let dx = points[i].0 - points[j].0;
            let dy = points[i].1 - points[j].1;
            let dz = points[i].2 - points[j].2;
            let dist_sq = dx * dx + dy * dy + dz * dz;
            pairs.push((dist_sq, i, j));
        }
    }

    // Sort by distance
    pairs.sort_by_key(|p| p.0);

    // Union-Find
    let mut uf = UnionFind::new(n);

    // Connect the 1000 shortest pairs for Part 1
    let connections = std::cmp::min(1000, pairs.len());
    for i in 0..connections {
        uf.unite(pairs[i].1, pairs[i].2);
    }

    // Count circuit sizes
    let mut circuit_sizes: HashMap<usize, i64> = HashMap::new();
    for i in 0..n {
        let root = uf.find(i);
        *circuit_sizes.entry(root).or_insert(0) += 1;
    }

    // Get top 3 largest
    let mut sizes: Vec<i64> = circuit_sizes.values().cloned().collect();
    sizes.sort_by(|a, b| b.cmp(a));

    let part1: i64 = sizes.iter().take(3).product();
    println!("Day 08 Part 1: {}", part1);

    // Part 2: Reset and find the last connection that unifies all into one circuit
    uf.reset();

    let mut num_circuits = n;
    let mut last_i = 0;
    let mut last_j = 0;

    for &(_, i, j) in pairs.iter() {
        if num_circuits <= 1 {
            break;
        }
        if uf.unite(i, j) {
            num_circuits -= 1;
            last_i = i;
            last_j = j;
        }
    }

    let part2: i64 = points[last_i].0 * points[last_j].0;
    println!("Day 08 Part 2: {}", part2);
}
