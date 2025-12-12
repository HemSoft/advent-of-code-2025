import * as fs from 'fs';

function solve() {
    let inputFile = 'input.txt';
    if (process.argv.length > 2) {
        inputFile = process.argv[2];
    }

    if (!fs.existsSync(inputFile)) {
        console.log(`Input file ${inputFile} not found.`);
        return;
    }

    const content = fs.readFileSync(inputFile, 'utf-8').replace(/\r\n/g, '\n');
    const parts = content.split('\n\n');

    const shapes: { [id: number]: Set<string>[] } = {};
    const regions: RegionTask[] = [];

    for (const part of parts) {
        const lines = part.trim().split('\n');
        if (lines.length === 0) continue;

        if (lines[0].includes(':')) {
            if (lines[0].includes('x')) { // Region
                for (const line of lines) {
                    if (line.trim()) parseRegion(line, regions);
                }
            } else { // Shape
                parseShape(lines, shapes);
            }
        }
    }

    let solvedCount = 0;
    for (const region of regions) {
        if (solveRegion(region, shapes)) {
            solvedCount++;
        }
    }

    console.log(`Day 12 Part 1: ${solvedCount}`);
    // console.log(`Day 12 Part 2: 0`);
}

interface RegionTask {
    w: number;
    h: number;
    counts: number[];
}

function parseShape(lines: string[], shapes: { [id: number]: Set<string>[] }) {
    const header = lines[0].trim().replace(':', '');
    const id = parseInt(header);
    if (isNaN(id)) return;

    const points = new Set<string>();
    for (let r = 1; r < lines.length; r++) {
        for (let c = 0; c < lines[r].length; c++) {
            if (lines[r][c] === '#') {
                points.add(`${r - 1},${c}`);
            }
        }
    }
    shapes[id] = generateVariations(points);
}

function parseRegion(line: string, regions: RegionTask[]) {
    const p = line.split(':');
    const dims = p[0].split('x');
    const w = parseInt(dims[0]);
    const h = parseInt(dims[1]);
    const counts = p[1].trim().split(/\s+/).map(x => parseInt(x));
    regions.push({ w, h, counts });
}

function generateVariations(original: Set<string>): Set<string>[] {
    const variations: Set<string>[] = [];
    let current = original;
    for (let i = 0; i < 2; i++) { // Flip
        for (let j = 0; j < 4; j++) { // Rotate
            const normalized = normalize(current);
            if (!variations.some(v => setEquals(v, normalized))) {
                variations.push(normalized);
            }
            current = rotate(current);
        }
        current = flip(original);
    }
    return variations;
}

function rotate(points: Set<string>): Set<string> {
    const newPoints = new Set<string>();
    for (const p of points) {
        const [r, c] = p.split(',').map(Number);
        newPoints.add(`${c},${-r}`);
    }
    return newPoints;
}

function flip(points: Set<string>): Set<string> {
    const newPoints = new Set<string>();
    for (const p of points) {
        const [r, c] = p.split(',').map(Number);
        newPoints.add(`${r},${-c}`);
    }
    return newPoints;
}

function normalize(points: Set<string>): Set<string> {
    if (points.size === 0) return points;
    let minR = Infinity;
    let minC = Infinity;
    for (const p of points) {
        const [r, c] = p.split(',').map(Number);
        if (r < minR) minR = r;
        if (c < minC) minC = c;
    }
    const newPoints = new Set<string>();
    for (const p of points) {
        const [r, c] = p.split(',').map(Number);
        newPoints.add(`${r - minR},${c - minC}`);
    }
    return newPoints;
}

function setEquals(a: Set<string>, b: Set<string>): boolean {
    if (a.size !== b.size) return false;
    for (const p of a) {
        if (!b.has(p)) return false;
    }
    return true;
}

interface AnchoredShape {
    points: { dr: number, dc: number }[];
}

interface SolverContext {
    w: number;
    h: number;
    counts: { [id: number]: number };
    types: number[];
    anchoredShapes: { [id: number]: AnchoredShape[] };
}

function solveRegion(region: RegionTask, shapes: { [id: number]: Set<string>[] }): boolean {
    const presents: number[] = [];
    let totalArea = 0;
    for (let i = 0; i < region.counts.length; i++) {
        for (let j = 0; j < region.counts[i]; j++) {
            presents.push(i);
            totalArea += shapes[i][0].size;
        }
    }

    if (totalArea > region.w * region.h) return false;

    const maxSkips = (region.w * region.h) - totalArea;
    const grid = new Uint8Array(region.w * region.h); // 0: empty, 1: filled

    const presentTypes = Array.from(new Set(presents)).sort((a, b) => shapes[b][0].size - shapes[a][0].size);
    const counts: { [id: number]: number } = {};
    for (const p of presents) {
        counts[p] = (counts[p] || 0) + 1;
    }

    const anchoredShapes: { [id: number]: AnchoredShape[] } = {};
    for (const type of presentTypes) {
        anchoredShapes[type] = [];
        for (const v of shapes[type]) {
            const sortedPts = Array.from(v).map(p => {
                const [r, c] = p.split(',').map(Number);
                return { r, c };
            }).sort((a, b) => a.r - b.r || a.c - b.c);

            const anchor = sortedPts[0];
            const points = sortedPts.map(p => ({ dr: p.r - anchor.r, dc: p.c - anchor.c }));
            anchoredShapes[type].push({ points });
        }
    }

    const ctx: SolverContext = {
        w: region.w,
        h: region.h,
        counts,
        types: presentTypes,
        anchoredShapes
    };

    return backtrack(0, grid, ctx, maxSkips);
}

function backtrack(idx: number, grid: Uint8Array, ctx: SolverContext, skipsLeft: number): boolean {
    while (idx < grid.length && grid[idx] !== 0) {
        idx++;
    }

    if (idx === grid.length) {
        return Object.values(ctx.counts).every(c => c === 0);
    }

    const r = Math.floor(idx / ctx.w);
    const c = idx % ctx.w;

    for (const type of ctx.types) {
        if (ctx.counts[type] > 0) {
            const variations = ctx.anchoredShapes[type];
            for (const shape of variations) {
                let fits = true;
                for (const pt of shape.points) {
                    const pr = r + pt.dr;
                    const pc = c + pt.dc;
                    if (pr < 0 || pr >= ctx.h || pc < 0 || pc >= ctx.w) { fits = false; break; }
                    if (grid[pr * ctx.w + pc] !== 0) { fits = false; break; }
                }

                if (fits) {
                    for (const pt of shape.points) {
                        grid[(r + pt.dr) * ctx.w + (c + pt.dc)] = 1;
                    }
                    ctx.counts[type]--;

                    if (backtrack(idx + 1, grid, ctx, skipsLeft)) return true;

                    ctx.counts[type]++;
                    for (const pt of shape.points) {
                        grid[(r + pt.dr) * ctx.w + (c + pt.dc)] = 0;
                    }
                }
            }
        }
    }

    if (skipsLeft > 0) {
        grid[idx] = 1;
        if (backtrack(idx + 1, grid, ctx, skipsLeft - 1)) return true;
        grid[idx] = 0;
    }

    return false;
}

solve();
