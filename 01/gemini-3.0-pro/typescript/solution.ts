import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8');
const lines = input.split('\n');

let pos = 50;
let count = 0;

for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;

    const dir = trimmed[0];
    const amount = parseInt(trimmed.substring(1));

    if (dir === 'R') {
        pos = (pos + amount) % 100;
    } else if (dir === 'L') {
        pos = (pos - amount) % 100;
        if (pos < 0) pos += 100;
    }

    if (pos === 0) {
        count++;
    }
}

console.log(`Day 01 Part 1: ${count}`);
