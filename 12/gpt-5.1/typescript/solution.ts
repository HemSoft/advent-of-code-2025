import * as fs from 'fs';

function parseInput(path: string): { shapeSizes: Map<number, number>; regionLines: string[] } {
	const raw = fs.readFileSync(path, 'utf-8');
	const lines = raw.split(/\r?\n/).map(l => l.replace(/\r$/, ''));

	const shapeSizes = new Map<number, number>();
	const regionLines: string[] = [];

	let currentShapeId = -1;
	let currentShapeCount = 0;

	for (const rawLine of lines) {
		const line = rawLine.trimEnd();
		if (line.trim() === '') continue;

		if (/^\d+:/.test(line) && !line.includes('x')) {
			if (currentShapeId >= 0) {
				shapeSizes.set(currentShapeId, currentShapeCount);
			}
			const idPart = line.split(':', 1)[0];
			currentShapeId = parseInt(idPart, 10);
			currentShapeCount = 0;
		} else if (line.includes('x') && line.includes(':')) {
			if (currentShapeId >= 0) {
				shapeSizes.set(currentShapeId, currentShapeCount);
				currentShapeId = -1;
				currentShapeCount = 0;
			}
			regionLines.push(line.trim());
		} else if (currentShapeId >= 0 && (line.includes('#') || line.includes('.'))) {
			currentShapeCount += (line.match(/#/g) || []).length;
		}
	}

	if (currentShapeId >= 0) {
		shapeSizes.set(currentShapeId, currentShapeCount);
	}

	return { shapeSizes, regionLines };
}

function solvePart1(path: string): number {
	const { shapeSizes, regionLines } = parseInput(path);
	let countFit = 0;

	for (const regionLine of regionLines) {
		const [sizePartRaw, countsPartRaw] = regionLine.split(':', 2);
		const sizePart = sizePartRaw.trim();
		const countsPart = (countsPartRaw ?? '').trim();

		const [wStr, hStr] = sizePart.split('x');
		const width = parseInt(wStr, 10);
		const height = parseInt(hStr, 10);

		const countStrings = countsPart.split(/\s+/).filter(s => s.length > 0);
		let totalCellsNeeded = 0;

		countStrings.forEach((s, idx) => {
			const c = parseInt(s, 10);
			if (!Number.isFinite(c) || c === 0) return;
			const size = shapeSizes.get(idx) ?? 0;
			totalCellsNeeded += c * size;
		});

		const gridArea = width * height;
		if (totalCellsNeeded <= gridArea) {
			countFit++;
		}
	}

	return countFit;
}

const part1 = solvePart1('input.txt');
console.log(`Day 12 Part 1: ${part1}`);

// Part 2 placeholder
const part2 = 0;
console.log(`Day 12 Part 2: ${part2}`);
