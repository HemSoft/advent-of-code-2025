import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();
const ranges = input.split(',');

let totalSum = 0n;

for (const range of ranges) {
    const parts = range.trim().split('-');
    if (parts.length !== 2) continue;

    const start = BigInt(parts[0]);
    const end = BigInt(parts[1]);

    for (let i = start; i <= end; i++) {
        if (isInvalidId(i)) {
            totalSum += i;
        }
    }
}

console.log(`Day 02 Part 1: ${totalSum}`);

let totalSumPart2 = 0n;

for (const range of ranges) {
    const parts = range.trim().split('-');
    if (parts.length !== 2) continue;

    const start = BigInt(parts[0]);
    const end = BigInt(parts[1]);

    for (let i = start; i <= end; i++) {
        if (isInvalidIdPart2(i)) {
            totalSumPart2 += i;
        }
    }
}

console.log(`Day 02 Part 2: ${totalSumPart2}`);

function isInvalidId(id: bigint): boolean {
    const s = id.toString();
    if (s.length % 2 !== 0) return false;

    const halfLen = s.length / 2;
    const firstHalf = s.substring(0, halfLen);
    const secondHalf = s.substring(halfLen);

    return firstHalf === secondHalf;
}

function isInvalidIdPart2(id: bigint): boolean {
    const s = id.toString();
    const len = s.length;

    for (let patternLen = 1; patternLen <= Math.floor(len / 2); patternLen++) {
        if (len % patternLen !== 0) continue;

        const pattern = s.substring(0, patternLen);
        const repetitions = len / patternLen;

        if (pattern.repeat(repetitions) === s) {
            return true;
        }
    }

    return false;
}
