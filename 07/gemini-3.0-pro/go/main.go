package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		fmt.Println("Error reading input.txt:", err)
		return
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	if len(lines) == 0 {
		return
	}

	width := len(lines[0])
	height := len(lines)

	startCol := -1
	startRow := -1

	for r, line := range lines {
		idx := strings.Index(line, "S")
		if idx != -1 {
			startCol = idx
			startRow = r
			break
		}
	}

	if startCol == -1 {
		fmt.Println("Start not found")
		return
	}

	activeBeams := make(map[int]bool)
	activeBeams[startCol] = true
	totalSplits := 0

	for r := startRow + 1; r < height; r++ {
		nextBeams := make(map[int]bool)
		line := lines[r]

		for c := range activeBeams {
			if c < 0 || c >= width {
				continue
			}

			char := line[c]
			if char == '^' {
				totalSplits++
				if c-1 >= 0 {
					nextBeams[c-1] = true
				}
				if c+1 < width {
					nextBeams[c+1] = true
				}
			} else {
				nextBeams[c] = true
			}
		}
		activeBeams = nextBeams
		if len(activeBeams) == 0 {
			break
		}
	}

	fmt.Printf("Day 07 Part 1: %d\n", totalSplits)

	// Part 2
	memo := make(map[string]int64)
	var countPaths func(r, c int) int64
	countPaths = func(r, c int) int64 {
		if c < 0 || c >= width {
			return 1
		}

		key := fmt.Sprintf("%d,%d", r, c)
		if val, ok := memo[key]; ok {
			return val
		}

		for currR := r + 1; currR < height; currR++ {
			if lines[currR][c] == '^' {
				res := countPaths(currR, c-1) + countPaths(currR, c+1)
				memo[key] = res
				return res
			}
		}

		memo[key] = 1
		return 1
	}

	part2Ans := countPaths(startRow, startCol)
	fmt.Printf("Day 07 Part 2: %d\n", part2Ans)
}
