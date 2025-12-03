import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();

function isInvalidIdPart1(num: bigint): boolean {
    const s = num.toString();
    if (s.length % 2 !== 0) return false;
    const half = s.length / 2;
    return s.substring(0, half) === s.substring(half);
}

function isInvalidIdPart2(num: bigint): boolean {
    const s = num.toString();
    // Check for patterns repeated at least twice
    for (let patternLen = 1; patternLen <= Math.floor(s.length / 2); patternLen++) {
        if (s.length % patternLen !== 0) continue;
        const pattern = s.substring(0, patternLen);
        const repetitions = Math.floor(s.length / patternLen);
        if (repetitions < 2) continue;
        let isRepeated = true;
        for (let i = 1; i < repetitions; i++) {
            if (s.substring(i * patternLen, (i + 1) * patternLen) !== pattern) {
                isRepeated = false;
                break;
            }
        }
        if (isRepeated) return true;
    }
    return false;
}

// Part 1
let part1 = 0n;
const ranges = input.split(',').filter(r => r.length > 0);
for (const range of ranges) {
    const [startStr, endStr] = range.split('-');
    const start = BigInt(startStr);
    const end = BigInt(endStr);
    for (let id = start; id <= end; id++) {
        if (isInvalidIdPart1(id)) {
            part1 += id;
        }
    }
}
console.log(`Day 02 Part 1: ${part1}`);

// Part 2
let part2 = 0n;
for (const range of ranges) {
    const [startStr, endStr] = range.split('-');
    const start = BigInt(startStr);
    const end = BigInt(endStr);
    for (let id = start; id <= end; id++) {
        if (isInvalidIdPart2(id)) {
            part2 += id;
        }
    }
}
console.log(`Day 02 Part 2: ${part2}`);
