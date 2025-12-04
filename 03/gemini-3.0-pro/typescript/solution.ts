import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').split(/\r?\n/);

let totalJoltage = 0;

for (const line of lines) {
    if (!line.trim()) continue;

    let maxJoltage = 0;
    let found = false;

    for (let d1 = 9; d1 >= 1; d1--) {
        const c1 = d1.toString();
        const idx1 = line.indexOf(c1);

        if (idx1 === -1) continue;

        for (let d2 = 9; d2 >= 1; d2--) {
            const c2 = d2.toString();
            const idx2 = line.lastIndexOf(c2);

            if (idx2 === -1) continue;

            if (idx1 < idx2) {
                maxJoltage = d1 * 10 + d2;
                found = true;
                break;
            }
        }
        if (found) break;
    }
    totalJoltage += maxJoltage;
}

console.log(`Day 03 Part 1: ${totalJoltage}`);

let totalJoltagePart2 = 0n;

for (const line of lines) {
    if (!line.trim()) continue;

    let result = "";
    let currentIndex = 0;
    const digitsNeeded = 12;
    const len = line.length;

    for (let i = 0; i < digitsNeeded; i++) {
        const remainingNeeded = digitsNeeded - 1 - i;
        const searchEndIndex = len - 1 - remainingNeeded;

        let bestDigit = -1;
        let bestDigitIndex = -1;

        for (let d = 9; d >= 1; d--) {
            const c = d.toString();
            const idx = line.indexOf(c, currentIndex);

            if (idx !== -1 && idx <= searchEndIndex) {
                bestDigit = d;
                bestDigitIndex = idx;
                break;
            }
        }

        if (bestDigit !== -1) {
            result += bestDigit;
            currentIndex = bestDigitIndex + 1;
        }
    }

    if (result.length === 12) {
        totalJoltagePart2 += BigInt(result);
    }
}

console.log(`Day 03 Part 2: ${totalJoltagePart2}`);
