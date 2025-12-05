import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8');
const lines = input.split('\n');

// Part 1
let pos1 = 50;
let count1 = 0;

for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;

    const dir = trimmed[0];
    const amount = parseInt(trimmed.substring(1));

    if (dir === 'R') {
        pos1 = (pos1 + amount) % 100;
    } else if (dir === 'L') {
        pos1 = (pos1 - amount) % 100;
        if (pos1 < 0) pos1 += 100;
    }

    if (pos1 === 0) {
        count1++;
    }
}

console.log(`Day 01 Part 1: ${count1}`);

// Part 2
let pos2 = 50;
let count2 = 0;

for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;

    const dir = trimmed[0];
    const amount = parseInt(trimmed.substring(1));

    for (let i = 0; i < amount; i++) {
        if (dir === 'R') {
            pos2 = (pos2 + 1) % 100;
        } else if (dir === 'L') {
            pos2--;
            if (pos2 < 0) pos2 = 99;
        }

        if (pos2 === 0) {
            count2++;
        }
    }
}

console.log(`Day 01 Part 2: ${count2}`);
