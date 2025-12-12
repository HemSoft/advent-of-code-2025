import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').trim().split('\n');

const graph: Map<string, string[]> = new Map();

for (const line of lines) {
    if (line.trim() === '') continue;
    const [source, destStr] = line.split(':');
    const destinations = destStr.trim().split(/\s+/).filter(s => s !== '');
    graph.set(source.trim(), destinations);
}

const memo1: Map<string, number> = new Map();

function countPaths(current: string, target: string): number {
    if (current === target) {
        return 1;
    }

    if (memo1.has(current)) {
        return memo1.get(current)!;
    }

    const neighbors = graph.get(current);
    if (!neighbors) {
        return 0;
    }

    let count = 0;
    for (const neighbor of neighbors) {
        count += countPaths(neighbor, target);
    }
    memo1.set(current, count);
    return count;
}

const memo2: Map<string, number> = new Map();

function countPathsWithRequired(current: string, target: string, visitedDac: boolean, visitedFft: boolean): number {
    if (current === 'dac') visitedDac = true;
    if (current === 'fft') visitedFft = true;

    if (current === target) {
        return visitedDac && visitedFft ? 1 : 0;
    }

    const key = `${current}_${visitedDac}_${visitedFft}`;
    if (memo2.has(key)) {
        return memo2.get(key)!;
    }

    const neighbors = graph.get(current);
    if (!neighbors) {
        return 0;
    }

    let count = 0;
    for (const neighbor of neighbors) {
        count += countPathsWithRequired(neighbor, target, visitedDac, visitedFft);
    }
    memo2.set(key, count);
    return count;
}

// Part 1
const part1 = countPaths('you', 'out');
console.log(`Day 11 Part 1: ${part1}`);

// Part 2
const part2 = countPathsWithRequired('svr', 'out', false, false);
console.log(`Day 11 Part 2: ${part2}`);
