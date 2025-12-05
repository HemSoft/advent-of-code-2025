import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();
let grid = input.split('\n').map(line => line.trim().split(''));

const rows = grid.length;
const cols = rows > 0 ? grid[0].length : 0;

let totalRemoved = 0;
let iteration = 0;

while (true) {
    iteration++;
    const toRemove: [number, number][] = [];

    for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
            if (grid[r][c] === '@') {
                let neighborCount = 0;
                for (let dr = -1; dr <= 1; dr++) {
                    for (let dc = -1; dc <= 1; dc++) {
                        if (dr === 0 && dc === 0) continue;

                        const nr = r + dr;
                        const nc = c + dc;

                        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
                            if (grid[nr][nc] === '@') {
                                neighborCount++;
                            }
                        }
                    }
                }

                if (neighborCount < 4) {
                    toRemove.push([r, c]);
                }
            }
        }
    }

    if (toRemove.length === 0) {
        break;
    }

    if (iteration === 1) {
        console.log(`Day 04 Part 1: ${toRemove.length}`);
    }

    totalRemoved += toRemove.length;

    for (const [r, c] of toRemove) {
        grid[r][c] = '.';
    }
}

console.log(`Day 04 Part 2: ${totalRemoved}`);
