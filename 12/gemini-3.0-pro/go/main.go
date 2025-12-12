package main

import (
"fmt"
"os"
"sort"
"strconv"
"strings"
)

type Point struct {
r, c int
}

type RegionTask struct {
w, h   int
counts []int
}

type AnchoredShape struct {
points []Point
}

func main() {
inputFile := "input.txt"
if len(os.Args) > 1 {
inputFile = os.Args[1]
}

data, err := os.ReadFile(inputFile)
if err != nil {
fmt.Printf("Input file %s not found.\n", inputFile)
return
}

content := strings.ReplaceAll(string(data), "\r\n", "\n")
parts := strings.Split(content, "\n\n")

shapes := make(map[int][][]Point)
var regions []RegionTask

for _, part := range parts {
lines := strings.Split(strings.TrimSpace(part), "\n")
if len(lines) == 0 {
continue
}

if strings.Contains(lines[0], ":") {
if strings.Contains(lines[0], "x") { // Region
for _, line := range lines {
if strings.TrimSpace(line) != "" {
parseRegion(line, &regions)
}
}
} else { // Shape
parseShape(lines, shapes)
}
}
}

solvedCount := 0
for _, region := range regions {
if solveRegion(region, shapes) {
solvedCount++
}
}

fmt.Printf("Day 12 Part 1: %d\n", solvedCount)
// fmt.Printf("Day 12 Part 2: 0\n")
}

func parseShape(lines []string, shapes map[int][][]Point) {
header := strings.TrimSuffix(strings.TrimSpace(lines[0]), ":")
id, err := strconv.Atoi(header)
if err != nil {
return
}

points := make(map[Point]bool)
for r := 1; r < len(lines); r++ {
for c := 0; c < len(lines[r]); c++ {
if lines[r][c] == '#' {
points[Point{r - 1, c}] = true
}
}
}
shapes[id] = generateVariations(points)
}

func parseRegion(line string, regions *[]RegionTask) {
p := strings.Split(line, ":")
dims := strings.Split(p[0], "x")
w, _ := strconv.Atoi(dims[0])
h, _ := strconv.Atoi(dims[1])

countStrs := strings.Fields(strings.TrimSpace(p[1]))
counts := make([]int, len(countStrs))
for i, s := range countStrs {
counts[i], _ = strconv.Atoi(s)
}
*regions = append(*regions, RegionTask{w, h, counts})
}

func generateVariations(original map[Point]bool) [][]Point {
variations := make([][]Point, 0)
seen := make(map[string]bool)

current := original
for i := 0; i < 2; i++ { // Flip
for j := 0; j < 4; j++ { // Rotate
normalized := normalize(current)
key := pointsToString(normalized)
if !seen[key] {
variations = append(variations, normalized)
seen[key] = true
}
current = rotate(current)
}
current = flip(original)
}
return variations
}

func rotate(points map[Point]bool) map[Point]bool {
newPoints := make(map[Point]bool)
for p := range points {
newPoints[Point{p.c, -p.r}] = true
}
return newPoints
}

func flip(points map[Point]bool) map[Point]bool {
newPoints := make(map[Point]bool)
for p := range points {
newPoints[Point{p.r, -p.c}] = true
}
return newPoints
}

func normalize(points map[Point]bool) []Point {
if len(points) == 0 {
return []Point{}
}
minR, minC := 1000000, 1000000
for p := range points {
if p.r < minR {
minR = p.r
}
if p.c < minC {
minC = p.c
}
}
res := make([]Point, 0, len(points))
for p := range points {
res = append(res, Point{p.r - minR, p.c - minC})
}
// Sort for consistent key generation
sort.Slice(res, func(i, j int) bool {
if res[i].r != res[j].r {
return res[i].r < res[j].r
}
return res[i].c < res[j].c
})
return res
}

func pointsToString(points []Point) string {
var sb strings.Builder
for _, p := range points {
sb.WriteString(fmt.Sprintf("%d,%d;", p.r, p.c))
}
return sb.String()
}

type SolverContext struct {
w, h           int
counts         map[int]int
types          []int
anchoredShapes map[int][]AnchoredShape
}

func solveRegion(region RegionTask, shapes map[int][][]Point) bool {
presents := make([]int, 0)
totalArea := 0
for i, count := range region.counts {
for j := 0; j < count; j++ {
presents = append(presents, i)
totalArea += len(shapes[i][0])
}
}

if totalArea > region.w*region.h {
return false
}

maxSkips := (region.w * region.h) - totalArea
grid := make([]bool, region.w*region.h)

presentTypesMap := make(map[int]bool)
for _, p := range presents {
presentTypesMap[p] = true
}
presentTypes := make([]int, 0, len(presentTypesMap))
for p := range presentTypesMap {
presentTypes = append(presentTypes, p)
}
sort.Slice(presentTypes, func(i, j int) bool {
return len(shapes[presentTypes[i]][0]) > len(shapes[presentTypes[j]][0])
})

counts := make(map[int]int)
for _, p := range presents {
counts[p]++
}

anchoredShapes := make(map[int][]AnchoredShape)
for _, typeID := range presentTypes {
anchoredShapes[typeID] = make([]AnchoredShape, 0)
for _, v := range shapes[typeID] {
// v is already sorted in normalize
anchor := v[0]
points := make([]Point, len(v))
for i, p := range v {
points[i] = Point{p.r - anchor.r, p.c - anchor.c}
}
anchoredShapes[typeID] = append(anchoredShapes[typeID], AnchoredShape{points})
}
}

ctx := SolverContext{
w:              region.w,
h:              region.h,
counts:         counts,
types:          presentTypes,
anchoredShapes: anchoredShapes,
}

return backtrack(0, grid, ctx, maxSkips)
}

func backtrack(idx int, grid []bool, ctx SolverContext, skipsLeft int) bool {
for idx < len(grid) && grid[idx] {
idx++
}

if idx == len(grid) {
for _, c := range ctx.counts {
if c > 0 {
return false
}
}
return true
}

r := idx / ctx.w
c := idx % ctx.w

for _, typeID := range ctx.types {
if ctx.counts[typeID] > 0 {
variations := ctx.anchoredShapes[typeID]
for _, shape := range variations {
fits := true
for _, pt := range shape.points {
pr, pc := r+pt.r, c+pt.c
if pr < 0 || pr >= ctx.h || pc < 0 || pc >= ctx.w {
fits = false
break
}
if grid[pr*ctx.w+pc] {
fits = false
break
}
}

if fits {
for _, pt := range shape.points {
grid[(r+pt.r)*ctx.w+(c+pt.c)] = true
}
ctx.counts[typeID]--

if backtrack(idx+1, grid, ctx, skipsLeft) {
return true
}

ctx.counts[typeID]++
for _, pt := range shape.points {
grid[(r+pt.r)*ctx.w+(c+pt.c)] = false
}
}
}
}
}

if skipsLeft > 0 {
grid[idx] = true
if backtrack(idx+1, grid, ctx, skipsLeft-1) {
return true
}
grid[idx] = false
}

return false
}

