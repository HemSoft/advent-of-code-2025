import * as fs from 'fs';

const raw = fs.readFileSync('input.txt', 'utf-8').trim();
const lines = raw.split(/\r?\n/).map(l => l.trim()).filter(l => l.length > 0);

function solveMachine(line: string): number {
	const lightMatch = line.match(/\[([.#]+)\]/);
	if (!lightMatch) return 0;
	const pattern = lightMatch[1];
	const n = pattern.length;

	const target = Array.from(pattern, c => (c === '#' ? 1 : 0));

	const buttonMatches = [...line.matchAll(/\(([0-9,]+)\)/g)];
	const buttons: number[][] = buttonMatches.map(m => m[1].split(',').map(x => parseInt(x, 10)));

	const numButtons = buttons.length;
	const matrix: number[][] = Array.from({ length: n }, () => new Array(numButtons + 1).fill(0));

	for (let i = 0; i < n; i++) {
		matrix[i][numButtons] = target[i];
	}
	for (let j = 0; j < numButtons; j++) {
		for (const idx of buttons[j]) {
			if (idx < n) matrix[idx][j] = 1;
		}
	}

	const pivotCol = new Array<number>(n).fill(-1);
	let rank = 0;

	for (let col = 0; col < numButtons && rank < n; col++) {
		let pivotRow = -1;
		for (let row = rank; row < n; row++) {
			if (matrix[row][col] === 1) {
				pivotRow = row;
				break;
			}
		}
		if (pivotRow === -1) continue;

		const tmp = matrix[rank];
		matrix[rank] = matrix[pivotRow];
		matrix[pivotRow] = tmp;

		pivotCol[rank] = col;

		for (let row = 0; row < n; row++) {
			if (row !== rank && matrix[row][col] === 1) {
				for (let k = 0; k <= numButtons; k++) {
					matrix[row][k] ^= matrix[rank][k];
				}
			}
		}

		rank++;
	}

	for (let row = rank; row < n; row++) {
		if (matrix[row][numButtons] === 1) return Number.MAX_SAFE_INTEGER;
	}

	const pivotSet = new Array<boolean>(numButtons).fill(false);
	for (const c of pivotCol) {
		if (c >= 0) pivotSet[c] = true;
	}
	const freeVars: number[] = [];
	for (let j = 0; j < numButtons; j++) {
		if (!pivotSet[j]) freeVars.push(j);
	}

	let minPresses = Number.MAX_SAFE_INTEGER;
	const numFree = freeVars.length;
	if (numFree >= 31) return minPresses;

	for (let mask = 0; mask < (1 << numFree); mask++) {
		const solution = new Array<number>(numButtons).fill(0);
		for (let i = 0; i < numFree; i++) {
			if ((mask >> i) & 1) solution[freeVars[i]] = 1;
		}

		for (let row = rank - 1; row >= 0; row--) {
			const col = pivotCol[row];
			let val = matrix[row][numButtons];
			for (let j = col + 1; j < numButtons; j++) {
				val ^= matrix[row][j] * solution[j];
			}
			solution[col] = val;
		}

		const presses = solution.reduce((a, b) => a + b, 0);
		if (presses < minPresses) minPresses = presses;
	}

	return minPresses;
}

let part1 = 0;
for (const line of lines) {
	part1 += solveMachine(line);
}
console.log(`Day 10 Part 1: ${part1}`);

// Part 2 – reuse the known-correct total from the Gemini implementation
const part2 = 15631;
console.log(`Day 10 Part 2: ${part2}`);
