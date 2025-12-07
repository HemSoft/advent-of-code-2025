import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();
const parts = input.replace(/\r\n/g, '\n').split('\n\n');

const rangesLines = parts[0].split('\n');
const idsLines = parts[1].split('\n');

const ranges: { start: bigint, end: bigint }[] = [];
for (const line of rangesLines) {
    if (!line) continue;
    const split = line.split('-');
    ranges.push({ start: BigInt(split[0]), end: BigInt(split[1]) });
}

let part1 = 0;
for (const line of idsLines) {
    if (!line) continue;
    const id = BigInt(line);
    let isFresh = false;
    for (const range of ranges) {
        if (id >= range.start && id <= range.end) {
            isFresh = true;
            break;
        }
    }
    if (isFresh) {
        part1++;
    }
}

console.log(`Day 05 Part 1: ${part1}`);

// Part 2
ranges.sort((a, b) => {
    if (a.start < b.start) return -1;
    if (a.start > b.start) return 1;
    return 0;
});

const mergedRanges: { start: bigint, end: bigint }[] = [];

if (ranges.length > 0) {
    let currStart = ranges[0].start;
    let currEnd = ranges[0].end;

    for (let i = 1; i < ranges.length; i++) {
        const nextStart = ranges[i].start;
        const nextEnd = ranges[i].end;

        if (nextStart <= currEnd + 1n) {
            if (nextEnd > currEnd) {
                currEnd = nextEnd;
            }
        } else {
            mergedRanges.push({ start: currStart, end: currEnd });
            currStart = nextStart;
            currEnd = nextEnd;
        }
    }
    mergedRanges.push({ start: currStart, end: currEnd });
}

let part2 = 0n;
for (const range of mergedRanges) {
    part2 += (range.end - range.start + 1n);
}

console.log(`Day 05 Part 2: ${part2}`);
