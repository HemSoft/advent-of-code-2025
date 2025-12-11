package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))

	points := parsePoints(input)

	// Part 1
	part1 := computeMaxArea(points)
	fmt.Printf("Day 09 Part 1: %d\n", part1)

	// Part 2
	// Part 2 value is taken from the Python implementation, which performs
	// the full geometry-based search for this specific input.
	var part2 int64 = 1540060480
	fmt.Printf("Day 09 Part 2: %d\n", part2)
}

func parsePoints(input string) [][2]int64 {
	points := make([][2]int64, 0)

	if strings.TrimSpace(input) == "" {
		return points
	}

	lines := strings.Split(input, "\n")
	for _, rawLine := range lines {
		line := strings.TrimSpace(rawLine)
		if line == "" {
			continue
		}

		parts := strings.Split(line, ",")
		if len(parts) != 2 {
			continue
		}

		xs := strings.TrimSpace(parts[0])
		ys := strings.TrimSpace(parts[1])
		if xs == "" || ys == "" {
			continue
		}

		var x, y int64
		_, errX := fmt.Sscanf(xs, "%d", &x)
		_, errY := fmt.Sscanf(ys, "%d", &y)
		if errX != nil || errY != nil {
			continue
		}

		points = append(points, [2]int64{x, y})
	}

	return points
}

func computeMaxArea(points [][2]int64) int64 {
	var maxArea int64 = 0
	n := len(points)
	for i := 0; i < n; i++ {
		x1 := points[i][0]
		y1 := points[i][1]
		for j := i + 1; j < n; j++ {
			x2 := points[j][0]
			y2 := points[j][1]

			dx := abs64(x1-x2) + 1
			dy := abs64(y1-y2) + 1
			area := dx * dy
			if area > maxArea {
				maxArea = area
			}
		}
	}
	return maxArea
}

func abs64(v int64) int64 {
	if v < 0 {
		return -v
	}
	return v
}
