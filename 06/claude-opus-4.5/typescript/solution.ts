import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').split('\n');

// Remove trailing empty lines
while (lines.length > 0 && lines[lines.length - 1].trim() === '') {
    lines.pop();
}

// Find max width and pad lines
const maxWidth = Math.max(...lines.map(l => l.length));
const grid = lines.map(l => l.padEnd(maxWidth));
const rows = grid.length;
const cols = maxWidth;
const operatorRow = grid[rows - 1];

function isSeparatorColumn(col: number): boolean {
    for (let r = 0; r < rows - 1; r++) {
        if (col < grid[r].length && grid[r][col] !== ' ') {
            return false;
        }
    }
    return true;
}

interface Problem {
    numbers: bigint[];
    op: string;
}

const problems: Problem[] = [];
let colStart = 0;

while (colStart < cols) {
    // Skip separator columns
    while (colStart < cols && isSeparatorColumn(colStart)) {
        colStart++;
    }
    if (colStart >= cols) break;

    // Find end of this problem
    let colEnd = colStart;
    while (colEnd < cols && !isSeparatorColumn(colEnd)) {
        colEnd++;
    }

    // Extract numbers and operator
    const numbers: bigint[] = [];
    let op = ' ';

    for (let r = 0; r < rows - 1; r++) {
        const segment = grid[r].substring(colStart, colEnd).trim();
        if (segment !== '' && /^\d+$/.test(segment)) {
            numbers.push(BigInt(segment));
        }
    }

    // Get operator
    const opSegment = operatorRow.substring(colStart, colEnd).trim();
    if (opSegment.length > 0) {
        op = opSegment[0];
    }

    if (numbers.length > 0 && (op === '+' || op === '*')) {
        problems.push({ numbers, op });
    }

    colStart = colEnd;
}

// Calculate grand total
let part1 = 0n;
for (const p of problems) {
    let result = p.numbers[0];
    for (let i = 1; i < p.numbers.length; i++) {
        if (p.op === '+') {
            result += p.numbers[i];
        } else {
            result *= p.numbers[i];
        }
    }
    part1 += result;
}

console.log(`Day 06 Part 1: ${part1}`);

// Part 2: Read columns right-to-left, digits top-to-bottom form numbers
let part2 = 0n;
colStart = 0;

while (colStart < cols) {
    while (colStart < cols && isSeparatorColumn(colStart)) {
        colStart++;
    }
    if (colStart >= cols) break;

    let colEnd = colStart;
    while (colEnd < cols && !isSeparatorColumn(colEnd)) {
        colEnd++;
    }

    // Get operator
    const opSegment = operatorRow.substring(colStart, colEnd).trim();
    const op = opSegment.length > 0 ? opSegment[0] : ' ';

    // Read columns right-to-left within this problem block
    const numbers2: bigint[] = [];
    for (let c = colEnd - 1; c >= colStart; c--) {
        const digits: string[] = [];
        for (let r = 0; r < rows - 1; r++) {
            const ch = grid[r][c];
            if (/\d/.test(ch)) {
                digits.push(ch);
            }
        }
        if (digits.length > 0) {
            numbers2.push(BigInt(digits.join('')));
        }
    }

    if (numbers2.length > 0 && (op === '+' || op === '*')) {
        let result = numbers2[0];
        for (let i = 1; i < numbers2.length; i++) {
            if (op === '+') {
                result += numbers2[i];
            } else {
                result *= numbers2[i];
            }
        }
        part2 += result;
    }

    colStart = colEnd;
}

console.log(`Day 06 Part 2: ${part2}`);
