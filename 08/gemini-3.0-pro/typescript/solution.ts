import * as fs from 'fs';

interface Point {
    x: number;
    y: number;
    z: number;
}

interface Pair {
    dist: number;
    i: number;
    j: number;
}

function solve() {
    const input = fs.readFileSync('input.txt', 'utf-8');
    const lines = input.split('\n');
    const points: Point[] = [];

    for (const line of lines) {
        if (line.trim()) {
            const parts = line.trim().split(',').map(Number);
            if (parts.length === 3) {
                points.push({ x: parts[0], y: parts[1], z: parts[2] });
            }
        }
    }

    const pairs: Pair[] = [];
    for (let i = 0; i < points.length; i++) {
        for (let j = i + 1; j < points.length; j++) {
            const p1 = points[i];
            const p2 = points[j];
            const distSq = Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2) + Math.pow(p1.z - p2.z, 2);
            const dist = Math.sqrt(distSq);
            pairs.push({ dist, i, j });
        }
    }

    pairs.sort((a, b) => a.dist - b.dist);

    const parent: number[] = Array.from({ length: points.length }, (_, i) => i);

    function find(i: number): number {
        if (parent[i] === i) {
            return i;
        }
        parent[i] = find(parent[i]);
        return parent[i];
    }

    function union(i: number, j: number): void {
        const rootI = find(i);
        const rootJ = find(j);
        if (rootI !== rootJ) {
            parent[rootI] = rootJ;
        }
    }

    const limit = Math.min(1000, pairs.length);
    for (let k = 0; k < limit; k++) {
        union(pairs[k].i, pairs[k].j);
    }

    const counts = new Map<number, number>();
    for (let i = 0; i < points.length; i++) {
        const root = find(i);
        counts.set(root, (counts.get(root) || 0) + 1);
    }

    const sizes = Array.from(counts.values()).sort((a, b) => b - a);

    let result = 0;
    if (sizes.length >= 3) {
        result = sizes[0] * sizes[1] * sizes[2];
    } else if (sizes.length > 0) {
        result = 1;
        for (const s of sizes) {
            result *= s;
        }
    }

    console.log(`Day 08 Part 1: ${result}`);

    // Part 2
    for (let i = 0; i < points.length; i++) {
        parent[i] = i;
    }
    let numComponents = points.length;
    let part2Result = 0;

    for (const pair of pairs) {
        const rootI = find(pair.i);
        const rootJ = find(pair.j);
        if (rootI !== rootJ) {
            parent[rootI] = rootJ;
            numComponents--;
            if (numComponents === 1) {
                part2Result = points[pair.i].x * points[pair.j].x;
                break;
            }
        }
    }

    console.log(`Day 08 Part 2: ${part2Result}`);
}

solve();