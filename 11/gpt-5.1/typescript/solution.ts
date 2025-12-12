import * as fs from 'fs';

function parseGraph(text: string): Map<string, string[]> {
	const graph = new Map<string, string[]>();

	for (const rawLine of text.split(/\r?\n/)) {
		const line = rawLine.trim();
		if (!line) continue;

		const parts = line.split(':', 2);
		if (parts.length !== 2) continue;

		const from = parts[0].trim();
		const targetsPart = parts[1].trim();

		const targets: string[] = [];
		if (targetsPart) {
			for (const t of targetsPart.split(/\s+/)) {
				const tt = t.trim();
				if (tt) targets.push(tt);
			}
		}

		graph.set(from, targets);
	}

	return graph;
}

function countPaths(
	node: string,
	destination: string,
	graph: Map<string, string[]>,
	memo: Map<string, number>
): number {
	if (node === destination) return 1;

	const cached = memo.get(node);
	if (cached !== undefined) return cached;

	let total = 0;
	const children = graph.get(node) ?? [];
	for (const child of children) {
		total += countPaths(child, destination, graph, memo);
	}

	memo.set(node, total);
	return total;
}

function countPathsWithRequiredNodes(
	node: string,
	destination: string,
	graph: Map<string, string[]>,
	memo: Map<string, number>,
	mask: number,
): number {
	let updatedMask = mask;
	if (node === 'fft') {
		updatedMask |= 1;
	} else if (node === 'dac') {
		updatedMask |= 2;
	}

	if (node === destination) {
		return (updatedMask & 0b11) === 0b11 ? 1 : 0;
	}

	const key = `${node}|${updatedMask}`;
	const cached = memo.get(key);
	if (cached !== undefined) {
		return cached;
	}

	let total = 0;
	const children = graph.get(node) ?? [];
	for (const child of children) {
		total += countPathsWithRequiredNodes(child, destination, graph, memo, updatedMask);
	}

	memo.set(key, total);
	return total;
}

function runExampleTest(): void {
	const example = `
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
`.trim();

	const graph = parseGraph(example);
	const memo = new Map<string, number>();
	const paths = countPaths('you', 'out', graph, memo);

	if (paths !== 5) {
		console.error(`Example test failed: expected 5, got ${paths}`);
	}
}

function runPart2ExampleTest(): void {
	const example = `
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
`.trim();

	const graph = parseGraph(example);
	const memo = new Map<string, number>();
	const paths = countPathsWithRequiredNodes('svr', 'out', graph, memo, 0);

	if (paths !== 2) {
		console.error(`Part 2 example test failed: expected 2, got ${paths}`);
	}
}

runExampleTest();
runPart2ExampleTest();

const input = fs.readFileSync('input.txt', 'utf-8').trim();
const graphReal = parseGraph(input);
const memoReal = new Map<string, number>();

const part1 = countPaths('you', 'out', graphReal, memoReal);
console.log(`Day 11 Part 1: ${part1}`);

const memoPart2 = new Map<string, number>();
const part2 = countPathsWithRequiredNodes('svr', 'out', graphReal, memoPart2, 0);
console.log(`Day 11 Part 2: ${part2}`);
