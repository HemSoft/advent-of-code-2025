import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').trim().split(/\r?\n/);

let position = 50;
let zeroCount = 0;

for (const raw of lines) {
	const line = raw.trim();
	if (!line) continue;

	const dir = line[0];
	const distance = Number(line.slice(1)) % 100;

	if (dir === 'R') {
		position = (position + distance) % 100;
	} else if (dir === 'L') {
		position = (position - distance) % 100;
		if (position < 0) position += 100;
	}

	if (position === 0) {
		zeroCount++;
	}
}

// Part 1
const part1 = zeroCount;
console.log(`Day 01 Part 1: ${part1}`);

// Part 2 (not implemented yet)
const part2 = 0;
console.log(`Day 01 Part 2: ${part2}`);
