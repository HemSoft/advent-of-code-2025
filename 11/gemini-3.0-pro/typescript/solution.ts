import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8');
const lines = input.split('\n');

const graph = new Map<string, string[]>();

for (const line of lines) {
    if (!line.trim()) continue;
    const [source, targetsStr] = line.trim().split(': ');
    const targets = targetsStr.split(' ');
    graph.set(source, targets);
}

// Part 1
const memo1 = new Map<string, number>();
function countPathsP1(current: string): number {
    if (current === 'out') return 1;
    if (memo1.has(current)) return memo1.get(current)!;

    if (!graph.has(current)) return 0;

    let total = 0;
    for (const neighbor of graph.get(current)!) {
        total += countPathsP1(neighbor);
    }

    memo1.set(current, total);
    return total;
}

const paths1 = countPathsP1('you');
console.log(`Day 11 Part 1: ${paths1}`);

// Part 2
const memo2 = new Map<string, number>();
function countPathsP2(current: string, mask: number): number {
    if (current === 'dac') mask |= 1;
    if (current === 'fft') mask |= 2;

    if (current === 'out') return mask === 3 ? 1 : 0;

    const key = `${current}-${mask}`;
    if (memo2.has(key)) return memo2.get(key)!;

    if (!graph.has(current)) return 0;

    let total = 0;
    for (const neighbor of graph.get(current)!) {
        total += countPathsP2(neighbor, mask);
    }

    memo2.set(key, total);
    return total;
}

const paths2 = countPathsP2('svr', 0);
console.log(`Day 11 Part 2: ${paths2}`);
