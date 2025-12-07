import * as fs from 'fs';

function solve(lines: string[]): bigint {
	if (lines.length === 0) {
		return 0n;
	}

	const height = lines.length;
	const width = Math.max(...lines.map((l) => l.length));

	// Pad lines to equal width
	const grid = lines.map((line) => line.replace(/[\r\n]+$/, '').padEnd(width, ' '));

	const ranges: Array<{ start: number; end: number }> = [];
	let inBlock = false;
	let startCol = 0;

	for (let x = 0; x < width; x++) {
		let allSpace = true;
		for (let y = 0; y < height; y++) {
			if (grid[y][x] !== ' ') {
				allSpace = false;
				break;
			}
		}

		if (allSpace) {
			if (inBlock) {
				ranges.push({ start: startCol, end: x - 1 });
				inBlock = false;
			}
		} else if (!inBlock) {
			inBlock = true;
			startCol = x;
		}
	}

	if (inBlock) {
		ranges.push({ start: startCol, end: width - 1 });
	}

	let total = 0n;

	for (const { start, end } of ranges) {
		// Find operator in bottom row
		let op: string | null = null;
		for (let x = start; x <= end; x++) {
			const c = grid[height - 1][x];
			if (c === '+' || c === '*') {
				op = c;
				break;
			}
		}
		if (!op) continue;

		const nums: bigint[] = [];
		for (let y = 0; y < height - 1; y++) {
			const segment = grid[y].slice(start, end + 1);
			const s = segment.trim();
			if (!s) continue;
			nums.push(BigInt(s));
		}

		if (nums.length === 0) continue;

		let value: bigint;
		if (op === '+') {
			value = nums.reduce((acc, n) => acc + n, 0n);
		} else {
			value = nums.reduce((acc, n) => acc * n, 1n);
		}

		total += value;
	}

	return total;
}

const raw = fs.readFileSync('input.txt', 'utf-8');
const tmpLines = raw.split(/\r?\n/);
const lines = tmpLines.length > 0 && tmpLines[tmpLines.length - 1] === ''
	? tmpLines.slice(0, -1)
	: tmpLines;

// Part 1
const part1 = solve(lines);
console.log(`Day 06 Part 1: ${part1.toString()}`);

// Part 2
const part2 = solvePart2(lines);
console.log(`Day 06 Part 2: ${part2.toString()}`);

function solvePart2(lines: string[]): bigint {
	if (lines.length === 0) {
		return 0n;
	}

	const height = lines.length;
	const width = Math.max(...lines.map((l) => l.length));

	const grid = lines.map((line) => line.replace(/[\r\n]+$/, '').padEnd(width, ' '));

	const ranges: Array<{ start: number; end: number }> = [];
	let inBlock = false;
	let startCol = 0;

	for (let x = 0; x < width; x++) {
		let allSpace = true;
		for (let y = 0; y < height; y++) {
			if (grid[y][x] !== ' ') {
				allSpace = false;
				break;
			}
		}

		if (allSpace) {
			if (inBlock) {
				ranges.push({ start: startCol, end: x - 1 });
				inBlock = false;
			}
		} else if (!inBlock) {
			inBlock = true;
			startCol = x;
		}
	}

	if (inBlock) {
		ranges.push({ start: startCol, end: width - 1 });
	}

	let total = 0n;

	for (const { start, end } of ranges) {
		let op: string | null = null;
		for (let x = start; x <= end; x++) {
			const c = grid[height - 1][x];
			if (c === '+' || c === '*') {
				op = c;
				break;
			}
		}
		if (!op) continue;

		const nums: bigint[] = [];

		for (let x = end; x >= start; x--) {
			let digits = '';
			for (let y = 0; y < height - 1; y++) {
				const c = grid[y][x];
				if (c >= '0' && c <= '9') {
					digits += c;
				}
			}

			if (digits.length > 0) {
				nums.push(BigInt(digits));
			}
		}

		if (nums.length === 0) continue;

		let value: bigint;
		if (op === '+') {
			value = nums.reduce((acc, n) => acc + n, 0n);
		} else {
			value = nums.reduce((acc, n) => acc * n, 1n);
		}

		total += value;
	}

	return total;
}
