import * as fs from 'fs';

function solve() {
    const input = fs.readFileSync('input.txt', 'utf-8');
    let totalPressesPart1 = 0;
    let totalPressesPart2 = 0;

    const lines = input.split('\n');
    for (const line of lines) {
        if (!line.trim()) continue;
        totalPressesPart1 += solvePart1(line);
        totalPressesPart2 += solvePart2(line);
    }

    console.log(`Day 10 Part 1: ${totalPressesPart1}`);
    console.log(`Day 10 Part 2: ${totalPressesPart2}`);
}

function solvePart1(line: string): number {
    const targetMatch = line.match(/\[([.#]+)\]/);
    if (!targetMatch) return 0;
    const targetStr = targetMatch[1];
    const L = targetStr.length;
    const target = new Array(L).fill(0);
    for (let i = 0; i < L; i++) {
        target[i] = targetStr[i] === '#' ? 1 : 0;
    }

    const buttonMatches = Array.from(line.matchAll(/\(([\d,]+)\)/g));
    const buttons: number[][] = [];
    for (const bm of buttonMatches) {
        const b = new Array(L).fill(0);
        const parts = bm[1].split(',');
        for (const p of parts) {
            const idx = parseInt(p);
            if (!isNaN(idx) && idx < L) {
                b[idx] = 1;
            }
        }
        buttons.push(b);
    }

    const B = buttons.length;
    const M: number[][] = [];
    for (let r = 0; r < L; r++) {
        M[r] = new Array(B + 1).fill(0);
        for (let c = 0; c < B; c++) {
            M[r][c] = buttons[c][r];
        }
        M[r][B] = target[r];
    }

    let pivotRow = 0;
    const pivotCols: number[] = [];
    const colToPivotRow = new Array(B).fill(-1);

    for (let c = 0; c < B && pivotRow < L; c++) {
        let sel = -1;
        for (let r = pivotRow; r < L; r++) {
            if (M[r][c] === 1) {
                sel = r;
                break;
            }
        }

        if (sel === -1) continue;

        // Swap
        [M[pivotRow], M[sel]] = [M[sel], M[pivotRow]];

        // Eliminate
        for (let r = 0; r < L; r++) {
            if (r !== pivotRow && M[r][c] === 1) {
                for (let k = c; k <= B; k++) {
                    M[r][k] ^= M[pivotRow][k];
                }
            }
        }

        pivotCols.push(c);
        colToPivotRow[c] = pivotRow;
        pivotRow++;
    }

    for (let r = pivotRow; r < L; r++) {
        if (M[r][B] === 1) return 0;
    }

    const freeCols: number[] = [];
    for (let c = 0; c < B; c++) {
        if (!pivotCols.includes(c)) freeCols.push(c);
    }

    let minPresses = Number.MAX_SAFE_INTEGER;
    const numFree = freeCols.length;
    const combinations = 1 << numFree;

    for (let i = 0; i < combinations; i++) {
        const x = new Array(B).fill(0);
        let currentPresses = 0;

        for (let k = 0; k < numFree; k++) {
            if ((i & (1 << k)) !== 0) {
                x[freeCols[k]] = 1;
                currentPresses++;
            }
        }

        for (const pCol of pivotCols) {
            const r = colToPivotRow[pCol];
            let val = M[r][B];
            for (const fCol of freeCols) {
                if (M[r][fCol] === 1 && x[fCol] === 1) {
                    val ^= 1;
                }
            }
            x[pCol] = val;
            if (val === 1) currentPresses++;
        }

        if (currentPresses < minPresses) {
            minPresses = currentPresses;
        }
    }

    return minPresses;
}

function solvePart2(line: string): number {
    const targetMatch = line.match(/\{([\d,]+)\}/);
    if (!targetMatch) return 0;
    const targetParts = targetMatch[1].split(',').map(Number);
    const L = targetParts.length;
    const b = targetParts;

    const buttonMatches = Array.from(line.matchAll(/\(([\d,]+)\)/g));
    const A_cols: number[][] = [];
    for (const bm of buttonMatches) {
        const col = new Array(L).fill(0);
        const parts = bm[1].split(',');
        for (const p of parts) {
            const idx = parseInt(p);
            if (!isNaN(idx) && idx < L) {
                col[idx] = 1;
            }
        }
        A_cols.push(col);
    }

    const B = A_cols.length;
    const matrix: number[][] = [];
    for (let r = 0; r < L; r++) {
        matrix[r] = new Array(B + 1).fill(0);
        for (let c = 0; c < B; c++) {
            matrix[r][c] = A_cols[c][r];
        }
        matrix[r][B] = b[r];
    }

    let pivotRow = 0;
    const pivotCols: number[] = [];
    const colToPivotRow = new Array(B).fill(-1);

    for (let c = 0; c < B && pivotRow < L; c++) {
        let sel = -1;
        for (let r = pivotRow; r < L; r++) {
            if (Math.abs(matrix[r][c]) > 1e-9) {
                sel = r;
                break;
            }
        }

        if (sel === -1) continue;

        [matrix[pivotRow], matrix[sel]] = [matrix[sel], matrix[pivotRow]];

        const pivotVal = matrix[pivotRow][c];
        for (let k = c; k <= B; k++) matrix[pivotRow][k] /= pivotVal;

        for (let r = 0; r < L; r++) {
            if (r !== pivotRow && Math.abs(matrix[r][c]) > 1e-9) {
                const factor = matrix[r][c];
                for (let k = c; k <= B; k++) matrix[r][k] -= factor * matrix[pivotRow][k];
            }
        }

        pivotCols.push(c);
        colToPivotRow[c] = pivotRow;
        pivotRow++;
    }

    for (let r = pivotRow; r < L; r++) {
        if (Math.abs(matrix[r][B]) > 1e-9) return 0;
    }

    const freeCols: number[] = [];
    for (let c = 0; c < B; c++) {
        if (!pivotCols.includes(c)) freeCols.push(c);
    }

    const UBs = new Array(B).fill(0);
    for (let c = 0; c < B; c++) {
        let minUb = Number.MAX_SAFE_INTEGER;
        let bounded = false;
        for (let r = 0; r < L; r++) {
            if (A_cols[c][r] > 0.5) {
                const val = Math.floor(b[r] / A_cols[c][r]);
                if (val < minUb) minUb = val;
                bounded = true;
            }
        }
        UBs[c] = bounded ? minUb : 0;
    }

    let minTotalPresses = Number.MAX_SAFE_INTEGER;
    let found = false;

    function search(freeIdx: number, currentFreeVals: number[]) {
        if (freeIdx === freeCols.length) {
            let currentPresses = 0;
            for (const v of currentFreeVals) currentPresses += v;

            let possible = true;
            for (const pCol of pivotCols) {
                const r = colToPivotRow[pCol];
                let val = matrix[r][B];
                for (let j = 0; j < freeCols.length; j++) {
                    const fCol = freeCols[j];
                    val -= matrix[r][fCol] * currentFreeVals[j];
                }

                if (val < -1e-9) { possible = false; break; }
                const longVal = Math.round(val);
                if (Math.abs(val - longVal) > 1e-9) { possible = false; break; }
                currentPresses += longVal;
            }

            if (possible) {
                if (currentPresses < minTotalPresses) {
                    minTotalPresses = currentPresses;
                    found = true;
                }
            }
            return;
        }

        const fColIdx = freeCols[freeIdx];
        const limit = UBs[fColIdx];

        for (let val = 0; val <= limit; val++) {
            currentFreeVals[freeIdx] = val;
            search(freeIdx + 1, currentFreeVals);
        }
    }

    search(0, new Array(freeCols.length).fill(0));

    return found ? minTotalPresses : 0;
}

solve();
