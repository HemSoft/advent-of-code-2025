import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();
const lines = input.split('\n').filter(l => l.trim() !== '');

function maxJoltage(line: string): number {
    const n = line.length;
    if (n < 2) return 0;

    // Precompute suffix maximum
    const suffixMax: number[] = new Array(n).fill(0);
    for (let i = n - 2; i >= 0; i--) {
        const digit = parseInt(line[i + 1]);
        suffixMax[i] = Math.max(digit, suffixMax[i + 1]);
    }

    // Find max joltage
    let maxJ = 0;
    for (let i = 0; i < n - 1; i++) {
        const tensDigit = parseInt(line[i]);
        const unitsDigit = suffixMax[i];
        const joltage = tensDigit * 10 + unitsDigit;
        maxJ = Math.max(maxJ, joltage);
    }

    return maxJ;
}

function maxJoltagePart2(line: string, k: number = 12): bigint {
    const n = line.length;
    if (n < k) return 0n;
    if (n === k) return BigInt(line);

    // Greedy: pick k digits to form largest number
    const result: string[] = [];
    let startIdx = 0;

    for (let i = 0; i < k; i++) {
        const remaining = k - i;
        const endIdx = n - remaining;

        let maxDigit = '0';
        let maxPos = startIdx;

        for (let j = startIdx; j <= endIdx; j++) {
            if (line[j] > maxDigit) {
                maxDigit = line[j];
                maxPos = j;
            }
        }

        result.push(maxDigit);
        startIdx = maxPos + 1;
    }

    return BigInt(result.join(''));
}

// Part 1
let part1 = 0;
for (const line of lines) {
    part1 += maxJoltage(line.trim());
}
console.log(`Day 03 Part 1: ${part1}`);

// Part 2
let part2 = 0n;
for (const line of lines) {
    part2 += maxJoltagePart2(line.trim());
}
console.log(`Day 03 Part 2: ${part2}`);
