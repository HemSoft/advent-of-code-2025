package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Point struct {
	x, y int64
}

type Edge struct {
	p1, p2 Point
}

func abs(n int64) int64 {
	if n < 0 {
		return -n
	}
	return n
}

func min64(a, b int64) int64 {
	if a < b {
		return a
	}
	return b
}

func max64(a, b int64) int64 {
	if a > b {
		return a
	}
	return b
}

func isOnSegment(px, py, x1, y1, x2, y2 int64) bool {
	if x1 == x2 {
		return px == x1 && py >= min64(y1, y2) && py <= max64(y1, y2)
	}
	if y1 == y2 {
		return py == y1 && px >= min64(x1, x2) && px <= max64(x1, x2)
	}
	return false
}

func isInsidePolygon(px, py int64, edges []Edge) bool {
	crossings := 0
	for _, e := range edges {
		y1, y2 := e.p1.y, e.p2.y
		x1, x2 := e.p1.x, e.p2.x
		if (y1 <= py && y2 > py) || (y2 <= py && y1 > py) {
			xIntersect := float64(x1) + float64(py-y1)/float64(y2-y1)*float64(x2-x1)
			if float64(px) < xIntersect {
				crossings++
			}
		}
	}
	return crossings%2 == 1
}

func isValidPoint(px, py int64, edges []Edge, tilesSet map[Point]bool) bool {
	if tilesSet[Point{px, py}] {
		return true
	}
	for _, e := range edges {
		if isOnSegment(px, py, e.p1.x, e.p1.y, e.p2.x, e.p2.y) {
			return true
		}
	}
	return isInsidePolygon(px, py, edges)
}

func direction(x1, y1, x2, y2, x3, y3 int64) float64 {
	return float64(x3-x1)*float64(y2-y1) - float64(x2-x1)*float64(y3-y1)
}

func segmentsIntersect(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2 int64) bool {
	d1 := direction(bx1, by1, bx2, by2, ax1, ay1)
	d2 := direction(bx1, by1, bx2, by2, ax2, ay2)
	d3 := direction(ax1, ay1, ax2, ay2, bx1, by1)
	d4 := direction(ax1, ay1, ax2, ay2, bx2, by2)
	return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
		((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))
}

func getIntersection(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2 int64) (float64, float64, bool) {
	d := float64(ax2-ax1)*float64(by2-by1) - float64(ay2-ay1)*float64(bx2-bx1)
	if math.Abs(d) < 1e-10 {
		return 0, 0, false
	}
	t := (float64(bx1-ax1)*float64(by2-by1) - float64(by1-ay1)*float64(bx2-bx1)) / d
	return float64(ax1) + t*float64(ax2-ax1), float64(ay1) + t*float64(ay2-ay1), true
}

func edgeCrossesRectInterior(x1, y1, x2, y2, minX, maxX, minY, maxY int64) bool {
	p1Inside := x1 >= minX && x1 <= maxX && y1 >= minY && y1 <= maxY
	p2Inside := x2 >= minX && x2 <= maxX && y2 >= minY && y2 <= maxY
	if p1Inside && p2Inside {
		return false
	}

	// Check each rect edge
	edges := [][4]int64{
		{minX, minY, maxX, minY}, // top
		{minX, maxY, maxX, maxY}, // bottom
		{minX, minY, minX, maxY}, // left
		{maxX, minY, maxX, maxY}, // right
	}

	for i, re := range edges {
		if segmentsIntersect(x1, y1, x2, y2, re[0], re[1], re[2], re[3]) {
			ix, iy, ok := getIntersection(x1, y1, x2, y2, re[0], re[1], re[2], re[3])
			if ok {
				if i < 2 { // horizontal edges
					if ix > float64(minX) && ix < float64(maxX) {
						return true
					}
				} else { // vertical edges
					if iy > float64(minY) && iy < float64(maxY) {
						return true
					}
				}
			}
		}
	}
	return false
}

func isRectangleValid(minX, maxX, minY, maxY int64, edges []Edge) bool {
	for _, e := range edges {
		if edgeCrossesRectInterior(e.p1.x, e.p1.y, e.p2.x, e.p2.y, minX, maxX, minY, maxY) {
			return false
		}
	}
	return true
}

func main() {
	file, _ := os.Open("input.txt")
	defer file.Close()

	var tiles []Point
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		parts := strings.Split(line, ",")
		x, _ := strconv.ParseInt(parts[0], 10, 64)
		y, _ := strconv.ParseInt(parts[1], 10, 64)
		tiles = append(tiles, Point{x, y})
	}

	// Part 1
	var maxArea int64 = 0
	for i := 0; i < len(tiles); i++ {
		for j := i + 1; j < len(tiles); j++ {
			width := abs(tiles[j].x-tiles[i].x) + 1
			height := abs(tiles[j].y-tiles[i].y) + 1
			area := width * height
			if area > maxArea {
				maxArea = area
			}
		}
	}
	fmt.Printf("Day 09 Part 1: %d\n", maxArea)

	// Part 2
	edges := make([]Edge, len(tiles))
	for i := 0; i < len(tiles); i++ {
		edges[i] = Edge{tiles[i], tiles[(i+1)%len(tiles)]}
	}

	tilesSet := make(map[Point]bool)
	for _, t := range tiles {
		tilesSet[t] = true
	}

	var maxArea2 int64 = 0
	for i := 0; i < len(tiles); i++ {
		for j := i + 1; j < len(tiles); j++ {
			t1, t2 := tiles[i], tiles[j]
			minX, maxX := min64(t1.x, t2.x), max64(t1.x, t2.x)
			minY, maxY := min64(t1.y, t2.y), max64(t1.y, t2.y)

			corners := []Point{{minX, minY}, {minX, maxY}, {maxX, minY}, {maxX, maxY}}
			allValid := true
			for _, c := range corners {
				if !isValidPoint(c.x, c.y, edges, tilesSet) {
					allValid = false
					break
				}
			}
			if allValid && isRectangleValid(minX, maxX, minY, maxY, edges) {
				area := (maxX - minX + 1) * (maxY - minY + 1)
				if area > maxArea2 {
					maxArea2 = area
				}
			}
		}
	}
	fmt.Printf("Day 09 Part 2: %d\n", maxArea2)
}