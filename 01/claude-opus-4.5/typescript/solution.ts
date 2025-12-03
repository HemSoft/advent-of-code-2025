import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').trim().split('\n').filter(l => l.trim());

let position = 50;
let zeroCountPart1 = 0;
let zeroCountPart2 = 0;

for (const line of lines) {
    const direction = line[0];
    const distance = parseInt(line.slice(1), 10);

    let newPosition: number;
    let firstHit: number;

    if (direction === 'L') {
        newPosition = ((position - distance) % 100 + 100) % 100;
        firstHit = position === 0 ? 100 : position;
    } else {
        newPosition = (position + distance) % 100;
        firstHit = position === 0 ? 100 : (100 - position);
    }

    if (newPosition === 0) {
        zeroCountPart1++;
    }

    if (firstHit <= distance) {
        zeroCountPart2 += 1 + Math.floor((distance - firstHit) / 100);
    }

    position = newPosition;
}

console.log(`Day 01 Part 1: ${zeroCountPart1}`);
console.log(`Day 01 Part 2: ${zeroCountPart2}`);
