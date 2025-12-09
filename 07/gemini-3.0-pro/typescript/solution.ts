import * as fs from 'fs';
import * as path from 'path';

function solve() {
    const inputPath = path.join(__dirname, 'input.txt');
    let input: string;
    try {
        input = fs.readFileSync(inputPath, 'utf-8');
    } catch (e) {
        console.error("Error reading input.txt");
        return;
    }

    const lines = input.split(/\r?\n/).filter(line => line.length > 0);
    if (lines.length === 0) return;

    const width = lines[0].length;
    const height = lines.length;

    let startCol = -1;
    let startRow = -1;

    for (let r = 0; r < height; r++) {
        const idx = lines[r].indexOf('S');
        if (idx !== -1) {
            startCol = idx;
            startRow = r;
            break;
        }
    }

    if (startCol === -1) {
        console.log("Start not found");
        return;
    }

    let activeBeams = new Set<number>();
    activeBeams.add(startCol);
    let totalSplits = 0;

    for (let r = startRow + 1; r < height; r++) {
        const nextBeams = new Set<number>();
        const line = lines[r];

        for (const c of activeBeams) {
            if (c < 0 || c >= width) continue;

            const char = line[c];
            if (char === '^') {
                totalSplits++;
                if (c - 1 >= 0) nextBeams.add(c - 1);
                if (c + 1 < width) nextBeams.add(c + 1);
            } else {
                nextBeams.add(c);
            }
        }
        activeBeams = nextBeams;
        if (activeBeams.size === 0) break;
    }

    console.log(`Day 07 Part 1: ${totalSplits}`);

    // Part 2
    const memo = new Map<string, number>();

    function countPaths(r: number, c: number): number {
        if (c < 0 || c >= width) return 1;

        const key = `${r},${c}`;
        if (memo.has(key)) return memo.get(key)!;

        for (let currR = r + 1; currR < height; currR++) {
            const char = lines[currR][c];
            if (char === '^') {
                const res = countPaths(currR, c - 1) + countPaths(currR, c + 1);
                memo.set(key, res);
                return res;
            }
        }

        memo.set(key, 1);
        return 1;
    }

    const part2Ans = countPaths(startRow, startCol);
    console.log(`Day 07 Part 2: ${part2Ans}`);
}

solve();
