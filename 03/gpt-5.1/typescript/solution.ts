import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').split(/\r?\n/);

let totalJoltagePart1 = 0;
let totalJoltagePart2 = 0;

for (const line of lines) {
	if (!line.trim()) continue;

	let maxJoltagePart1 = 0;
	let found = false;

	for (let d1 = 9; d1 >= 1 && !found; d1--) {
		const c1 = String(d1);
		const idx1 = line.indexOf(c1);
		if (idx1 === -1) continue;

		for (let d2 = 9; d2 >= 1; d2--) {
			const c2 = String(d2);
			const idx2 = line.lastIndexOf(c2);
			if (idx2 === -1) continue;

			if (idx1 < idx2) {
				maxJoltagePart1 = d1 * 10 + d2;
				found = true;
				break;
			}
		}
	}

	totalJoltagePart1 += maxJoltagePart1;

	// Part 2: choose exactly 12 digits to form the largest possible number
	const digits = line;
	const targetLength = 12;
	const chosen: string[] = [];
	let start = 0;

	for (let pos = 0; pos < targetLength; pos++) {
		const remainingNeeded = targetLength - pos - 1;
		let bestDigit: string | null = null;
		let bestIndex = -1;

		for (let d = 9; d >= 0; d--) {
			const ch = String(d);
			let lastIndex = -1;
			for (let i = start; i < digits.length; i++) {
				if (digits[i] === ch) {
					lastIndex = i;
				}
			}
			if (lastIndex < start) continue;

			if (lastIndex <= digits.length - 1 - remainingNeeded) {
				bestDigit = ch;
				bestIndex = lastIndex;
				break;
			}
		}

		if (bestIndex === -1) {
			bestDigit = digits[start];
			bestIndex = start;
		}

		chosen.push(bestDigit!);
		start = bestIndex + 1;
	}

	let lineJoltagePart2 = 0;
	for (const ch of chosen) {
		lineJoltagePart2 = lineJoltagePart2 * 10 + Number(ch);
	}

	totalJoltagePart2 += lineJoltagePart2;
}

console.log(`Day 03 Part 1: ${totalJoltagePart1}`);
console.log(`Day 03 Part 2: ${totalJoltagePart2}`);
