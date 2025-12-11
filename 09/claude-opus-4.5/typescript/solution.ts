import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();

interface Point {
    x: number;
    y: number;
}

interface Edge {
    p1: Point;
    p2: Point;
}

const tiles: Point[] = input.split('\n')
    .filter(line => line.trim())
    .map(line => {
        const [x, y] = line.split(',').map(Number);
        return { x, y };
    });

// Part 1
let maxArea = 0;
for (let i = 0; i < tiles.length; i++) {
    for (let j = i + 1; j < tiles.length; j++) {
        const width = Math.abs(tiles[j].x - tiles[i].x) + 1;
        const height = Math.abs(tiles[j].y - tiles[i].y) + 1;
        const area = width * height;
        if (area > maxArea) maxArea = area;
    }
}
console.log(`Day 09 Part 1: ${maxArea}`);

// Part 2
const edges: Edge[] = tiles.map((t, i) => ({
    p1: t,
    p2: tiles[(i + 1) % tiles.length]
}));

const tilesSet = new Set(tiles.map(t => `${t.x},${t.y}`));

function isOnSegment(px: number, py: number, x1: number, y1: number, x2: number, y2: number): boolean {
    if (x1 === x2) return px === x1 && py >= Math.min(y1, y2) && py <= Math.max(y1, y2);
    if (y1 === y2) return py === y1 && px >= Math.min(x1, x2) && px <= Math.max(x1, x2);
    return false;
}

function isInsidePolygon(px: number, py: number, edges: Edge[]): boolean {
    let crossings = 0;
    for (const e of edges) {
        const { x: x1, y: y1 } = e.p1;
        const { x: x2, y: y2 } = e.p2;
        if ((y1 <= py && y2 > py) || (y2 <= py && y1 > py)) {
            const xIntersect = x1 + (py - y1) / (y2 - y1) * (x2 - x1);
            if (px < xIntersect) crossings++;
        }
    }
    return crossings % 2 === 1;
}

function isValidPoint(px: number, py: number, edges: Edge[], tilesSet: Set<string>): boolean {
    if (tilesSet.has(`${px},${py}`)) return true;
    for (const e of edges) {
        if (isOnSegment(px, py, e.p1.x, e.p1.y, e.p2.x, e.p2.y)) return true;
    }
    return isInsidePolygon(px, py, edges);
}

function direction(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number): number {
    return (x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1);
}

function segmentsIntersect(ax1: number, ay1: number, ax2: number, ay2: number, 
                          bx1: number, by1: number, bx2: number, by2: number): boolean {
    const d1 = direction(bx1, by1, bx2, by2, ax1, ay1);
    const d2 = direction(bx1, by1, bx2, by2, ax2, ay2);
    const d3 = direction(ax1, ay1, ax2, ay2, bx1, by1);
    const d4 = direction(ax1, ay1, ax2, ay2, bx2, by2);
    return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
           ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

function getIntersection(ax1: number, ay1: number, ax2: number, ay2: number,
                        bx1: number, by1: number, bx2: number, by2: number): { x: number, y: number } | null {
    const d = (ax2 - ax1) * (by2 - by1) - (ay2 - ay1) * (bx2 - bx1);
    if (Math.abs(d) < 1e-10) return null;
    const t = ((bx1 - ax1) * (by2 - by1) - (by1 - ay1) * (bx2 - bx1)) / d;
    return { x: ax1 + t * (ax2 - ax1), y: ay1 + t * (ay2 - ay1) };
}

function edgeCrossesRectInterior(x1: number, y1: number, x2: number, y2: number,
                                minX: number, maxX: number, minY: number, maxY: number): boolean {
    const p1Inside = x1 >= minX && x1 <= maxX && y1 >= minY && y1 <= maxY;
    const p2Inside = x2 >= minX && x2 <= maxX && y2 >= minY && y2 <= maxY;
    if (p1Inside && p2Inside) return false;

    const rectEdges = [
        [minX, minY, maxX, minY], // top
        [minX, maxY, maxX, maxY], // bottom
        [minX, minY, minX, maxY], // left
        [maxX, minY, maxX, maxY], // right
    ];

    for (let i = 0; i < rectEdges.length; i++) {
        const [rx1, ry1, rx2, ry2] = rectEdges[i];
        if (segmentsIntersect(x1, y1, x2, y2, rx1, ry1, rx2, ry2)) {
            const intersect = getIntersection(x1, y1, x2, y2, rx1, ry1, rx2, ry2);
            if (intersect) {
                if (i < 2) { // horizontal
                    if (intersect.x > minX && intersect.x < maxX) return true;
                } else { // vertical
                    if (intersect.y > minY && intersect.y < maxY) return true;
                }
            }
        }
    }
    return false;
}

function isRectangleValid(minX: number, maxX: number, minY: number, maxY: number, edges: Edge[]): boolean {
    for (const e of edges) {
        if (edgeCrossesRectInterior(e.p1.x, e.p1.y, e.p2.x, e.p2.y, minX, maxX, minY, maxY)) {
            return false;
        }
    }
    return true;
}

let maxArea2 = 0;
for (let i = 0; i < tiles.length; i++) {
    for (let j = i + 1; j < tiles.length; j++) {
        const t1 = tiles[i], t2 = tiles[j];
        const minX = Math.min(t1.x, t2.x), maxX = Math.max(t1.x, t2.x);
        const minY = Math.min(t1.y, t2.y), maxY = Math.max(t1.y, t2.y);

        const corners = [{ x: minX, y: minY }, { x: minX, y: maxY }, { x: maxX, y: minY }, { x: maxX, y: maxY }];
        const allValid = corners.every(c => isValidPoint(c.x, c.y, edges, tilesSet));
        
        if (allValid && isRectangleValid(minX, maxX, minY, maxY, edges)) {
            const area = (maxX - minX + 1) * (maxY - minY + 1);
            if (area > maxArea2) maxArea2 = area;
        }
    }
}
console.log(`Day 09 Part 2: ${maxArea2}`);