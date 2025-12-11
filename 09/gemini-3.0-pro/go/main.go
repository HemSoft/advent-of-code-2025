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

func isPointInPolygon(x, y float64, edges []Edge) bool {
	inside := false
	for _, edge := range edges {
		p1 := edge.p1
		p2 := edge.p2
		if (float64(p1.y) > y) != (float64(p2.y) > y) {
			intersectX := float64(p2.x-p1.x)*(y-float64(p1.y))/(float64(p2.y)-float64(p1.y)) + float64(p1.x)
			if x < intersectX {
				inside = !inside
			}
		}
	}
	return inside
}

func min(a, b int64) int64 {
	if a < b {
		return a
	}
	return b
}

func max(a, b int64) int64 {
	if a > b {
		return a
	}
	return b
}

func isValid(p1, p2 Point, edges []Edge) bool {
	x1 := min(p1.x, p2.x)
	x2 := max(p1.x, p2.x)
	y1 := min(p1.y, p2.y)
	y2 := max(p1.y, p2.y)

	cx := float64(x1+x2) / 2.0
	cy := float64(y1+y2) / 2.0

	if !isPointInPolygon(cx, cy, edges) {
		return false
	}

	for _, edge := range edges {
		ep1 := edge.p1
		ep2 := edge.p2

		if ep1.x == ep2.x { // Vertical
			ex := ep1.x
			eyMin := min(ep1.y, ep2.y)
			eyMax := max(ep1.y, ep2.y)
			if x1 < ex && ex < x2 {
				overlapMin := max(y1, eyMin)
				overlapMax := min(y2, eyMax)
				if overlapMin < overlapMax {
					return false
				}
			}
		} else if ep1.y == ep2.y { // Horizontal
			ey := ep1.y
			exMin := min(ep1.x, ep2.x)
			exMax := max(ep1.x, ep2.x)
			if y1 < ey && ey < y2 {
				overlapMin := max(x1, exMin)
				overlapMax := min(x2, exMax)
				if overlapMin < overlapMax {
					return false
				}
			}
		}
	}
	return true
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var points []Point
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" {
			continue
		}
		parts := strings.Split(line, ",")
		x, _ := strconv.ParseInt(parts[0], 10, 64)
		y, _ := strconv.ParseInt(parts[1], 10, 64)
		points = append(points, Point{x, y})
	}

	var edges []Edge
	n := len(points)
	for i := 0; i < n; i++ {
		edges = append(edges, Edge{points[i], points[(i+1)%n]})
	}

	var maxAreaPart1 int64 = 0
	var maxAreaPart2 int64 = 0

	for i := 0; i < len(points); i++ {
		for j := i + 1; j < len(points); j++ {
			p1 := points[i]
			p2 := points[j]

			width := int64(math.Abs(float64(p1.x - p2.x))) + 1
			height := int64(math.Abs(float64(p1.y - p2.y))) + 1
			area := width * height

			if area > maxAreaPart1 {
				maxAreaPart1 = area
			}

			if isValid(p1, p2, edges) {
				if area > maxAreaPart2 {
					maxAreaPart2 = area
				}
			}
		}
	}

	fmt.Printf("Day 09 Part 1: %d\n", maxAreaPart1)
	fmt.Printf("Day 09 Part 2: %d\n", maxAreaPart2)
}
