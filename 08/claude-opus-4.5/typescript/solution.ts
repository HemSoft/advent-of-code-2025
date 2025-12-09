import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').trim().split('\n').filter(l => l.trim());

interface Point {
    x: number;
    y: number;
    z: number;
}

const points: Point[] = lines.map(line => {
    const [x, y, z] = line.split(',').map(Number);
    return { x, y, z };
});

const n = points.length;

// Calculate all pairwise distances
const pairs: { distSq: number; i: number; j: number }[] = [];
for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
        const dx = points[i].x - points[j].x;
        const dy = points[i].y - points[j].y;
        const dz = points[i].z - points[j].z;
        const distSq = dx * dx + dy * dy + dz * dz;
        pairs.push({ distSq, i, j });
    }
}

// Sort by distance
pairs.sort((a, b) => a.distSq - b.distSq);

// Union-Find
let parent: number[] = Array.from({ length: n }, (_, i) => i);
let rank: number[] = new Array(n).fill(0);

function find(x: number): number {
    if (parent[x] !== x) {
        parent[x] = find(parent[x]);
    }
    return parent[x];
}

function unite(x: number, y: number): boolean {
    let px = find(x), py = find(y);
    if (px === py) return false;
    if (rank[px] < rank[py]) [px, py] = [py, px];
    parent[py] = px;
    if (rank[px] === rank[py]) rank[px]++;
    return true;
}

// Connect the 1000 shortest pairs for Part 1
const connections = Math.min(1000, pairs.length);
for (let i = 0; i < connections; i++) {
    unite(pairs[i].i, pairs[i].j);
}

// Count circuit sizes
const circuitSizes = new Map<number, number>();
for (let i = 0; i < n; i++) {
    const root = find(i);
    circuitSizes.set(root, (circuitSizes.get(root) || 0) + 1);
}

// Get top 3 largest
const sizes = Array.from(circuitSizes.values()).sort((a, b) => b - a);
const top3 = sizes.slice(0, 3);
const part1 = top3.reduce((a, b) => a * b, 1);

console.log(`Day 08 Part 1: ${part1}`);

// Part 2: Reset and find the last connection that unifies all into one circuit
parent = Array.from({ length: n }, (_, i) => i);
rank = new Array(n).fill(0);

let numCircuits = n;
let lastI = -1, lastJ = -1;

for (let i = 0; i < pairs.length && numCircuits > 1; i++) {
    if (unite(pairs[i].i, pairs[i].j)) {
        numCircuits--;
        lastI = pairs[i].i;
        lastJ = pairs[i].j;
    }
}

const part2 = points[lastI].x * points[lastJ].x;
console.log(`Day 08 Part 2: ${part2}`);
