import * as fs from 'fs';

function solvePart1(lines: string[]): number {
	if (lines.length === 0) {
		return 0;
	}

	const height = lines.length;
	let width = 0;
	for (const line of lines) {
		if (line.length > width) {
			width = line.length;
		}
	}

	const grid = lines.map((line) => line.padEnd(width, '.'));

	let startRow = -1;
	let startCol = -1;

	for (let r = 0; r < height && startRow === -1; r++) {
		const c = grid[r].indexOf('S');
		if (c !== -1) {
			startRow = r;
			startCol = c;
		}
	}

	if (startRow === -1) {
		return 0;
	}

	const encode = (r: number, c: number): number => r * width + c;
	const decode = (v: number): { r: number; c: number } => ({
		r: Math.floor(v / width),
		c: v % width,
	});

	let current = new Set<number>([encode(startRow, startCol)]);
	let splits = 0;

	while (current.size > 0) {
		const next = new Set<number>();

		for (const value of current) {
			const { r, c } = decode(value);
			const nr = r + 1;

			if (nr >= height) {
				continue;
			}

			const cell = grid[nr][c];
			if (cell === '^') {
				splits++;

				if (c - 1 >= 0) {
					next.add(encode(nr, c - 1));
				}
				if (c + 1 < width) {
					next.add(encode(nr, c + 1));
				}
			} else {
				next.add(encode(nr, c));
			}
		}

		current = next;
	}

	return splits;
}

function solvePart2(_lines: string[]): number {
	const lines = _lines.map((l) => l.replace(/\r?$/, ""));
	if (lines.length === 0) {
		return 0;
	}

	const height = lines.length;
	let width = 0;
	for (const line of lines) {
		if (line.length > width) {
			width = line.length;
		}
	}

	const grid = lines.map((line) => line.padEnd(width, '.'));

	let startRow = -1;
	let startCol = -1;

	for (let r = 0; r < height && startRow === -1; r++) {
		const c = grid[r].indexOf('S');
		if (c !== -1) {
			startRow = r;
			startCol = c;
		}
	}

	if (startRow === -1) {
		return 0;
	}

	const encode = (r: number, c: number): number => r * width + c;
	const decode = (v: number): { r: number; c: number } => ({
		r: Math.floor(v / width),
		c: v % width,
	});

	let current = new Map<number, number>();
	current.set(encode(startRow, startCol), 1);

	let finished = 0;

	while (current.size > 0) {
		const next = new Map<number, number>();

		for (const [value, count] of current.entries()) {
			const { r, c } = decode(value);
			const nr = r + 1;

			if (nr >= height) {
				finished += count;
				continue;
			}

			const cell = grid[nr][c];
			if (cell === '^') {
				if (c - 1 >= 0) {
					const key = encode(nr, c - 1);
					next.set(key, (next.get(key) ?? 0) + count);
				}
				if (c + 1 < width) {
					const key = encode(nr, c + 1);
					next.set(key, (next.get(key) ?? 0) + count);
				}
			} else {
				const key = encode(nr, c);
				next.set(key, (next.get(key) ?? 0) + count);
			}
		}

		current = next;
	}

	return finished;
}

const raw = fs.readFileSync('input.txt', 'utf-8');
const lines = raw.split(/\r?\n/).filter((line) => line.length > 0 || raw.includes('\n'));

const part1 = solvePart1(lines);
console.log(`Day 07 Part 1: ${part1}`);

const part2 = solvePart2(lines);
console.log(`Day 07 Part 2: ${part2}`);