import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').trim().split('\n');
const grid = lines.filter(l => l.length > 0);
const rows = grid.length;
const cols = grid[0].length;

// Part 1: Count rolls with fewer than 4 adjacent rolls
const dx = [-1, -1, -1, 0, 0, 1, 1, 1];
const dy = [-1, 0, 1, -1, 1, -1, 0, 1];

let part1 = 0;
for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
        if (grid[r][c] !== '@') continue;

        let adjacentRolls = 0;
        for (let d = 0; d < 8; d++) {
            const nr = r + dx[d];
            const nc = c + dy[d];
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc] === '@') {
                adjacentRolls++;
            }
        }

        if (adjacentRolls < 4) {
            part1++;
        }
    }
}

console.log(`Day 04 Part 1: ${part1}`);

// Part 2: Iteratively remove accessible rolls until none remain
const mutableGrid: string[][] = grid.map(row => row.split(''));

let part2 = 0;

while (true) {
    const toRemove: [number, number][] = [];

    for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
            if (mutableGrid[r][c] !== '@') continue;

            let adjacentRolls = 0;
            for (let d = 0; d < 8; d++) {
                const nr = r + dx[d];
                const nc = c + dy[d];
                if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && mutableGrid[nr][nc] === '@') {
                    adjacentRolls++;
                }
            }

            if (adjacentRolls < 4) {
                toRemove.push([r, c]);
            }
        }
    }

    if (toRemove.length === 0) break;

    for (const [r, c] of toRemove) {
        mutableGrid[r][c] = '.';
    }

    part2 += toRemove.length;
}

console.log(`Day 04 Part 2: ${part2}`);
