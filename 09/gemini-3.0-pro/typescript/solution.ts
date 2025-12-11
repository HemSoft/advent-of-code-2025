import * as fs from 'fs';
import * as path from 'path';

const input = fs.readFileSync(path.join(__dirname, 'input.txt'), 'utf-8');
const lines = input.split('\n').filter(line => line.trim() !== '');

interface Point {
    x: number;
    y: number;
}

const points: Point[] = lines.map(line => {
    const [x, y] = line.split(',').map(Number);
    return { x, y };
});

let maxAreaPart1 = 0;
let maxAreaPart2 = 0;

const edges: { p1: Point, p2: Point }[] = [];
for (let i = 0; i < points.length; i++) {
    edges.push({ p1: points[i], p2: points[(i + 1) % points.length] });
}

function isPointInPolygon(x: number, y: number): boolean {
    let inside = false;
    for (const edge of edges) {
        const p1 = edge.p1;
        const p2 = edge.p2;
        if ((p1.y > y) !== (p2.y > y)) {
            const intersectX = (p2.x - p1.x) * (y - p1.y) / (p2.y - p1.y) + p1.x;
            if (x < intersectX) {
                inside = !inside;
            }
        }
    }
    return inside;
}

function isValid(p1: Point, p2: Point): boolean {
    const x1 = Math.min(p1.x, p2.x);
    const x2 = Math.max(p1.x, p2.x);
    const y1 = Math.min(p1.y, p2.y);
    const y2 = Math.max(p1.y, p2.y);

    const cx = (x1 + x2) / 2;
    const cy = (y1 + y2) / 2;

    if (!isPointInPolygon(cx, cy)) {
        return false;
    }

    for (const edge of edges) {
        const ep1 = edge.p1;
        const ep2 = edge.p2;

        if (ep1.x === ep2.x) { // Vertical
            const ex = ep1.x;
            const eyMin = Math.min(ep1.y, ep2.y);
            const eyMax = Math.max(ep1.y, ep2.y);
            if (x1 < ex && ex < x2) {
                const overlapMin = Math.max(y1, eyMin);
                const overlapMax = Math.min(y2, eyMax);
                if (overlapMin < overlapMax) {
                    return false;
                }
            }
        } else if (ep1.y === ep2.y) { // Horizontal
            const ey = ep1.y;
            const exMin = Math.min(ep1.x, ep2.x);
            const exMax = Math.max(ep1.x, ep2.x);
            if (y1 < ey && ey < y2) {
                const overlapMin = Math.max(x1, exMin);
                const overlapMax = Math.min(x2, exMax);
                if (overlapMin < overlapMax) {
                    return false;
                }
            }
        }
    }
    return true;
}

for (let i = 0; i < points.length; i++) {
    for (let j = i + 1; j < points.length; j++) {
        const p1 = points[i];
        const p2 = points[j];

        const width = Math.abs(p1.x - p2.x) + 1;
        const height = Math.abs(p1.y - p2.y) + 1;
        const area = width * height;

        if (area > maxAreaPart1) {
            maxAreaPart1 = area;
        }

        if (isValid(p1, p2)) {
            if (area > maxAreaPart2) {
                maxAreaPart2 = area;
            }
        }
    }
}

console.log(`Day 09 Part 1: ${maxAreaPart1}`);
console.log(`Day 09 Part 2: ${maxAreaPart2}`);
