import * as fs from 'fs';

const raw = fs.readFileSync('input.txt', 'utf-8');
const lines = raw.split(/\r?\n/).filter(l => l.length > 0);

type Range = { start: number; end: number };

const ranges: Range[] = [];
const available: number[] = [];

let index = 0;
while (index < lines.length && lines[index].includes('-')) {
	const line = lines[index].trim();
	if (line.length > 0) {
		const [s, e] = line.split('-', 2).map(part => part.trim());
		const start = Number(s);
		const end = Number(e);
		if (!Number.isNaN(start) && !Number.isNaN(end)) {
			const rStart = Math.min(start, end);
			const rEnd = Math.max(start, end);
			ranges.push({ start: rStart, end: rEnd });
		}
	}
	index++;
}

for (; index < lines.length; index++) {
	const line = lines[index].trim();
	if (line.length === 0) continue;
	const id = Number(line);
	if (!Number.isNaN(id)) {
		available.push(id);
	}
}

ranges.sort((a, b) => (a.start === b.start ? a.end - b.end : a.start - b.start));

const merged: Range[] = [];
for (const r of ranges) {
	if (merged.length === 0) {
		merged.push({ ...r });
		continue;
	}
	const last = merged[merged.length - 1];
	if (r.start <= last.end + 1) {
		if (r.end > last.end) {
			last.end = r.end;
		}
	} else {
		merged.push({ ...r });
	}
}

let part1 = 0;
for (const id of available) {
	for (const r of merged) {
		if (id < r.start) break;
		if (id <= r.end) {
			part1++;
			break;
		}
	}
}
console.log(`Day 05 Part 1: ${part1}`);

let part2 = 0;
for (const r of merged) {
	part2 += r.end - r.start + 1;
}
console.log(`Day 05 Part 2: ${part2}`);