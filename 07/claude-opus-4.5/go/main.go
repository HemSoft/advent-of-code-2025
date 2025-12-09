package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))
	lines := strings.Split(input, "\n")

	rows := len(lines)
	cols := 0
	if rows > 0 {
		cols = len(lines[0])
	}

	// Find starting position S
	startRow, startCol := 0, 0
	for r := 0; r < rows; r++ {
		c := strings.Index(lines[r], "S")
		if c != -1 {
			startRow, startCol = r, c
			break
		}
	}

	// Part 1: Count total splits
	var splitCount int64 = 0
	currentBeams := make(map[int]bool)
	currentBeams[startCol] = true

	for row := startRow + 1; row < rows && len(currentBeams) > 0; row++ {
		nextBeams := make(map[int]bool)
		lineLen := len(lines[row])
		for col := range currentBeams {
			if col < 0 || col >= lineLen {
				continue
			}
			cell := lines[row][col]
			if cell == '^' {
				splitCount++
				if col-1 >= 0 {
					nextBeams[col-1] = true
				}
				if col+1 < cols {
					nextBeams[col+1] = true
				}
			} else {
				nextBeams[col] = true
			}
		}
		currentBeams = nextBeams
	}

	fmt.Printf("Day 07 Part 1: %d\n", splitCount)

	// Part 2: Count timelines (each particle takes both paths at each splitter)
	particleCounts := make(map[int]int64)
	particleCounts[startCol] = 1

	for row := startRow + 1; row < rows && len(particleCounts) > 0; row++ {
		nextCounts := make(map[int]int64)
		lineLen := len(lines[row])
		for col, count := range particleCounts {
			if col < 0 || col >= lineLen {
				continue
			}
			cell := lines[row][col]
			if cell == '^' {
				if col-1 >= 0 {
					nextCounts[col-1] += count
				}
				if col+1 < cols {
					nextCounts[col+1] += count
				}
			} else {
				nextCounts[col] += count
			}
		}
		particleCounts = nextCounts
	}

	var part2 int64 = 0
	for _, count := range particleCounts {
		part2 += count
	}
	fmt.Printf("Day 07 Part 2: %d\n", part2)
}
