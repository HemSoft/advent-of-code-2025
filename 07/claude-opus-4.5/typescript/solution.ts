import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();
const lines = input.split('\n');
const rows = lines.length;
const cols = rows > 0 ? lines[0].length : 0;

// Find starting position S
let startRow = 0, startCol = 0;
for (let r = 0; r < rows; r++) {
    const c = lines[r].indexOf('S');
    if (c !== -1) {
        startRow = r;
        startCol = c;
        break;
    }
}

// Part 1: Count total splits
let splitCount = 0;
let currentBeams = new Set<number>([startCol]);

for (let row = startRow + 1; row < rows && currentBeams.size > 0; row++) {
    const nextBeams = new Set<number>();
    for (const col of currentBeams) {
        if (col < 0 || col >= cols) continue;
        const cell = lines[row][col];
        if (cell === '^') {
            splitCount++;
            if (col - 1 >= 0) nextBeams.add(col - 1);
            if (col + 1 < cols) nextBeams.add(col + 1);
        } else {
            nextBeams.add(col);
        }
    }
    currentBeams = nextBeams;
}

console.log(`Day 07 Part 1: ${splitCount}`);

// Part 2: Count timelines (each particle takes both paths at each splitter)
let particleCounts = new Map<number, bigint>([[startCol, 1n]]);

for (let row = startRow + 1; row < rows && particleCounts.size > 0; row++) {
    const nextCounts = new Map<number, bigint>();
    for (const [col, count] of particleCounts) {
        if (col < 0 || col >= cols) continue;
        const cell = lines[row][col];
        if (cell === '^') {
            if (col - 1 >= 0) {
                nextCounts.set(col - 1, (nextCounts.get(col - 1) || 0n) + count);
            }
            if (col + 1 < cols) {
                nextCounts.set(col + 1, (nextCounts.get(col + 1) || 0n) + count);
            }
        } else {
            nextCounts.set(col, (nextCounts.get(col) || 0n) + count);
        }
    }
    particleCounts = nextCounts;
}

let part2 = 0n;
for (const count of particleCounts.values()) {
    part2 += count;
}
console.log(`Day 07 Part 2: ${part2}`);
