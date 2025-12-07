import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8');
let lines = input.split(/\r?\n/);
if (lines.length > 0 && lines[lines.length - 1].length === 0) {
    lines.pop();
}

const width = Math.max(...lines.map(l => l.length));
const paddedLines = lines.map(l => l.padEnd(width, ' '));

let totalSum = 0;
let startCol = -1;
const blocks: {start: number, end: number}[] = [];

function processBlock(lines: string[], start: number, end: number): number {
    const numbers: number[] = [];
    let op = ' ';

    for (const line of lines) {
        const segment = line.substring(start, end + 1).trim();
        if (!segment) continue;

        if (segment === '+' || segment === '*') {
            op = segment;
        } else if (/^\d+$/.test(segment)) {
            numbers.push(parseInt(segment, 10));
        }
    }

    if (op === '+') {
        return numbers.reduce((a, b) => a + b, 0);
    } else if (op === '*') {
        return numbers.reduce((a, b) => a * b, 1);
    }
    return 0;
}

function processBlockPart2(lines: string[], start: number, end: number): number {
    const numbers: number[] = [];
    let op: string | null = null;

    for (let col = start; col <= end; col++) {
        let chars: string[] = [];
        for (const line of lines) {
            if (line[col] !== ' ') {
                chars.push(line[col]);
            }
        }

        if (chars.length === 0) continue;

        const lastChar = chars[chars.length - 1];
        if (lastChar === '+' || lastChar === '*') {
            op = lastChar;
            chars.pop();
        }

        if (chars.length > 0) {
            numbers.push(parseInt(chars.join(''), 10));
        }
    }

    if (op === '+') {
        return numbers.reduce((a, b) => a + b, 0);
    } else if (op === '*') {
        return numbers.reduce((a, b) => a * b, 1);
    }
    return 0;
}

for (let col = 0; col < width; col++) {
    let isEmpty = true;
    for (const line of paddedLines) {
        if (line[col] !== ' ') {
            isEmpty = false;
            break;
        }
    }

    if (isEmpty) {
        if (startCol !== -1) {
            blocks.push({start: startCol, end: col - 1});
            startCol = -1;
        }
    } else {
        if (startCol === -1) {
            startCol = col;
        }
    }
}

if (startCol !== -1) {
    blocks.push({start: startCol, end: width - 1});
}

let totalSumP1 = 0;
for (const block of blocks) {
    totalSumP1 += processBlock(paddedLines, block.start, block.end);
}
console.log(`Day 06 Part 1: ${totalSumP1}`);

let totalSumP2 = 0;
for (const block of blocks) {
    totalSumP2 += processBlockPart2(paddedLines, block.start, block.end);
}
console.log(`Day 06 Part 2: ${totalSumP2}`);
