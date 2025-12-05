import * as fs from 'fs';

const rawInput = fs.readFileSync('input.txt', 'utf-8');

function parseLines(input: string): string[] {
	return input
		.replace(/\r\n/g, '\n')
		.split('\n')
		.map(line => line.trim())
		.filter(line => line.length > 0);
}

function countAccessibleRolls(grid: string[]): number {
	const height = grid.length;
	if (height === 0) {
		return 0;
	}

	const width = grid[0].length;
	let accessible = 0;

	const dRows = [-1, -1, -1, 0, 0, 1, 1, 1];
	const dCols = [-1, 0, 1, -1, 1, -1, 0, 1];

	for (let r = 0; r < height; r++) {
		const row = grid[r];

		for (let c = 0; c < width; c++) {
			if (row[c] !== '@') {
				continue;
			}

			let neighbors = 0;

			for (let i = 0; i < dRows.length; i++) {
				const nr = r + dRows[i];
				const nc = c + dCols[i];

				if (nr < 0 || nr >= height || nc < 0 || nc >= width) {
					continue;
				}

				if (grid[nr][nc] === '@') {
					neighbors++;
				}
			}

			if (neighbors < 4) {
				accessible++;
			}
		}
	}

	return accessible;
}

function countTotalRemoved(grid: string[]): number {
	const height = grid.length;
	if (height === 0) {
		return 0;
	}

	const width = grid[0].length;
	const board: string[][] = grid.map(row => row.split(""));

	const dRows = [-1, -1, -1, 0, 0, 1, 1, 1];
	const dCols = [-1, 0, 1, -1, 1, -1, 0, 1];

	let totalRemoved = 0;

	while (true) {
		const toRemove: Array<[number, number]> = [];

		for (let r = 0; r < height; r++) {
			for (let c = 0; c < width; c++) {
				if (board[r][c] !== "@") {
					continue;
				}

				let neighbors = 0;

				for (let i = 0; i < dRows.length; i++) {
					const nr = r + dRows[i];
					const nc = c + dCols[i];

					if (nr < 0 || nr >= height || nc < 0 || nc >= width) {
						continue;
					}

					if (board[nr][nc] === "@") {
						neighbors++;
					}
				}

				if (neighbors < 4) {
					toRemove.push([r, c]);
				}
			}
		}

		if (toRemove.length === 0) {
			break;
		}

		for (const [r, c] of toRemove) {
			board[r][c] = ".";
		}

		totalRemoved += toRemove.length;
	}

	return totalRemoved;
}

const lines = parseLines(rawInput);

// Part 1
const part1 = countAccessibleRolls(lines);
console.log(`Day 04 Part 1: ${part1}`);

// Part 2
const part2 = countTotalRemoved(lines);
console.log(`Day 04 Part 2: ${part2}`);
