import * as fs from 'fs';

const lines = fs.readFileSync('input.txt', 'utf-8').split('\n').map(l => l.replace(/\r$/, ''));

const shapes: Map<number, number> = new Map();
const regionLines: string[] = [];
let currentShapeId = -1;
let currentCellCount = 0;

for (const line of lines) {
    if (!line.trim()) continue;

    if (/^\d+:/.test(line) && !line.includes('x')) {
        if (currentShapeId >= 0) {
            shapes.set(currentShapeId, currentCellCount);
        }
        currentShapeId = parseInt(line.split(':')[0]);
        currentCellCount = 0;
    } else if (line.includes('x') && line.includes(':')) {
        if (currentShapeId >= 0) {
            shapes.set(currentShapeId, currentCellCount);
            currentShapeId = -1;
            currentCellCount = 0;
        }
        regionLines.push(line);
    } else if (currentShapeId >= 0 && (line.includes('#') || line.includes('.'))) {
        currentCellCount += (line.match(/#/g) || []).length;
    }
}

if (currentShapeId >= 0) {
    shapes.set(currentShapeId, currentCellCount);
}

let part1 = 0;

for (const regionLine of regionLines) {
    const colonIdx = regionLine.indexOf(':');
    const sizePart = regionLine.substring(0, colonIdx);
    const countsPart = regionLine.substring(colonIdx + 1).trim();

    const [width, height] = sizePart.split('x').map(Number);
    const counts = countsPart.split(/\s+/).map(Number);

    let totalCellsNeeded = 0;
    for (let i = 0; i < counts.length; i++) {
        totalCellsNeeded += counts[i] * (shapes.get(i) || 0);
    }

    const gridArea = width * height;
    if (totalCellsNeeded <= gridArea) {
        part1++;
    }
}

console.log(`Day 12 Part 1: ${part1}`);
console.log(`Day 12 Part 2: 0`);
