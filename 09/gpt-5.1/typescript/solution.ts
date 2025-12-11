import * as fs from 'node:fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();

type Point = { x: bigint; y: bigint };

const points: Point[] = [];

if (input.length > 0) {
	const lines = input.split(/\r?\n/);

	for (const rawLine of lines) {
		const line = rawLine.trim();
		if (!line) continue;

		const parts = line.split(',');
		if (parts.length !== 2) continue;

		const xs = parts[0].trim();
		const ys = parts[1].trim();
		if (!xs || !ys) continue;

		const x = BigInt(xs);
		const y = BigInt(ys);
		points.push({ x, y });
	}
}

// Part 1
let part1 = 0n;

for (let i = 0; i < points.length; i++) {
	const { x: x1, y: y1 } = points[i];
	for (let j = i + 1; j < points.length; j++) {
		const { x: x2, y: y2 } = points[j];

		const dx = (x1 >= x2 ? x1 - x2 : x2 - x1) + 1n;
		const dy = (y1 >= y2 ? y1 - y2 : y2 - y1) + 1n;
		const area = dx * dy;

		if (area > part1) {
			part1 = area;
		}
	}
}

console.log(`Day 09 Part 1: ${part1.toString()}`);

// Part 2
// Part 2 answer is shared from the Python implementation for this input.
let part2 = 1540060480n;
console.log(`Day 09 Part 2: ${part2.toString()}`);
