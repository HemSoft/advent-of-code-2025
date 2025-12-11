import * as fs from 'fs';

function solveMachine(line: string): number {
    // Parse indicator lights pattern
    const lightMatch = line.match(/\[([.#]+)\]/);
    const pattern = lightMatch![1];
    const n = pattern.length;
    
    // Target: 1 where '#', 0 where '.'
    const target: number[] = [];
    for (let i = 0; i < n; i++) {
        target.push(pattern[i] === '#' ? 1 : 0);
    }
    
    // Parse buttons
    const buttonMatches = line.matchAll(/\(([0-9,]+)\)/g);
    const buttons: number[][] = [];
    for (const m of buttonMatches) {
        const indices = m[1].split(',').map(Number);
        buttons.push(indices);
    }
    
    const numButtons = buttons.length;
    
    // Build augmented matrix [A | target]
    const matrix: number[][] = [];
    for (let i = 0; i < n; i++) {
        matrix.push(new Array(numButtons + 1).fill(0));
        matrix[i][numButtons] = target[i];
    }
    for (let j = 0; j < numButtons; j++) {
        for (const idx of buttons[j]) {
            if (idx < n) {
                matrix[idx][j] = 1;
            }
        }
    }
    
    // Gaussian elimination over GF(2)
    const pivotCol: number[] = new Array(n).fill(-1);
    let rank = 0;
    
    for (let col = 0; col < numButtons && rank < n; col++) {
        // Find pivot
        let pivotRow = -1;
        for (let row = rank; row < n; row++) {
            if (matrix[row][col] === 1) {
                pivotRow = row;
                break;
            }
        }
        
        if (pivotRow === -1) continue;
        
        // Swap rows
        [matrix[rank], matrix[pivotRow]] = [matrix[pivotRow], matrix[rank]];
        pivotCol[rank] = col;
        
        // Eliminate
        for (let row = 0; row < n; row++) {
            if (row !== rank && matrix[row][col] === 1) {
                for (let k = 0; k <= numButtons; k++) {
                    matrix[row][k] ^= matrix[rank][k];
                }
            }
        }
        rank++;
    }
    
    // Check for inconsistency
    for (let row = rank; row < n; row++) {
        if (matrix[row][numButtons] === 1) {
            return Number.MAX_SAFE_INTEGER;
        }
    }
    
    // Find free variables
    const pivotCols = new Set(pivotCol.filter(x => x >= 0));
    const freeVars: number[] = [];
    for (let j = 0; j < numButtons; j++) {
        if (!pivotCols.has(j)) {
            freeVars.push(j);
        }
    }
    
    // Try all combinations of free variables
    let minPresses = Number.MAX_SAFE_INTEGER;
    const numFree = freeVars.length;
    
    for (let mask = 0; mask < (1 << numFree); mask++) {
        const solution: number[] = new Array(numButtons).fill(0);
        
        // Set free variables
        for (let i = 0; i < numFree; i++) {
            solution[freeVars[i]] = (mask >> i) & 1;
        }
        
        // Back-substitute
        for (let row = rank - 1; row >= 0; row--) {
            const col = pivotCol[row];
            let val = matrix[row][numButtons];
            for (let j = col + 1; j < numButtons; j++) {
                val ^= matrix[row][j] * solution[j];
            }
            solution[col] = val;
        }
        
        const presses = solution.reduce((a, b) => a + b, 0);
        if (presses < minPresses) {
            minPresses = presses;
        }
    }
    
    return minPresses;
}

const input = fs.readFileSync('input.txt', 'utf-8').trim();
const lines = input.split('\n');

let part1 = 0;
for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed) {
        part1 += solveMachine(trimmed);
    }
}
console.log(`Day 10 Part 1: ${part1}`);

// Part 2
let part2 = 0;
console.log(`Day 10 Part 2: ${part2}`);