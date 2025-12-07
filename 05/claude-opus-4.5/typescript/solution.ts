import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim().replace(/\r\n/g, '\n');
const sections = input.split('\n\n');

interface Range {
    start: bigint;
    end: bigint;
}

const ranges: Range[] = sections[0].split('\n').map(line => {
    const [start, end] = line.trim().split('-').map(s => BigInt(s));
    return { start, end };
});

const ingredients: bigint[] = sections[1].split('\n')
    .map(line => line.trim())
    .filter(line => line !== '')
    .map(line => BigInt(line));

// Part 1
let part1 = 0;
for (const id of ingredients) {
    for (const range of ranges) {
        if (id >= range.start && id <= range.end) {
            part1++;
            break;
        }
    }
}
console.log(`Day 05 Part 1: ${part1}`);

// Part 2: Merge overlapping ranges and count total unique IDs
const sorted = [...ranges].sort((a, b) => {
    if (a.start !== b.start) return a.start < b.start ? -1 : 1;
    return a.end < b.end ? -1 : 1;
});

const merged: Range[] = [];
for (const range of sorted) {
    if (merged.length === 0 || merged[merged.length - 1].end < range.start - 1n) {
        merged.push({ start: range.start, end: range.end });
    } else {
        const last = merged[merged.length - 1];
        if (range.end > last.end) {
            last.end = range.end;
        }
    }
}

let part2 = 0n;
for (const r of merged) {
    part2 += r.end - r.start + 1n;
}
console.log(`Day 05 Part 2: ${part2}`);
