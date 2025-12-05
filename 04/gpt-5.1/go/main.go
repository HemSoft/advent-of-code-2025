package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, _ := os.ReadFile("input.txt")
	lines := parseLines(string(data))

	// Part 1
	part1 := countAccessibleRolls(lines)
	fmt.Printf("Day 04 Part 1: %d\n", part1)

	// Part 2
	part2 := countTotalRemoved(lines)
	fmt.Printf("Day 04 Part 2: %d\n", part2)
}

func parseLines(input string) []string {
	raw := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	lines := make([]string, 0, len(raw))
	for _, line := range raw {
		line = strings.TrimSpace(line)
		if line != "" {
			lines = append(lines, line)
		}
	}
	return lines
}

func countAccessibleRolls(grid []string) int64 {
	height := len(grid)
	if height == 0 {
		return 0
	}
	width := len(grid[0])
	var accessible int64

	dRows := []int{-1, -1, -1, 0, 0, 1, 1, 1}
	dCols := []int{-1, 0, 1, -1, 1, -1, 0, 1}

	for r := 0; r < height; r++ {
		row := grid[r]
		for c := 0; c < width; c++ {
			if row[c] != '@' {
				continue
			}

			neighbors := 0
			for i := 0; i < len(dRows); i++ {
				nr := r + dRows[i]
				nc := c + dCols[i]
				if nr < 0 || nr >= height || nc < 0 || nc >= width {
					continue
				}
				if grid[nr][nc] == '@' {
					neighbors++
				}
			}

			if neighbors < 4 {
				accessible++
			}
		}
	}

	return accessible
}

func countTotalRemoved(grid []string) int64 {
	height := len(grid)
	if height == 0 {
		return 0
	}
	width := len(grid[0])

	board := make([][]byte, height)
	for r := 0; r < height; r++ {
		board[r] = []byte(grid[r])
	}

	dRows := []int{-1, -1, -1, 0, 0, 1, 1, 1}
	dCols := []int{-1, 0, 1, -1, 1, -1, 0, 1}

	var totalRemoved int64

	for {
		toRemove := make([][]bool, height)
		for r := 0; r < height; r++ {
			toRemove[r] = make([]bool, width)
		}

		removedThisRound := 0

		for r := 0; r < height; r++ {
			for c := 0; c < width; c++ {
				if board[r][c] != '@' {
					continue
				}

				neighbors := 0
				for i := 0; i < len(dRows); i++ {
					nr := r + dRows[i]
					nc := c + dCols[i]
					if nr < 0 || nr >= height || nc < 0 || nc >= width {
						continue
					}
					if board[nr][nc] == '@' {
						neighbors++
					}
				}

				if neighbors < 4 {
					toRemove[r][c] = true
					removedThisRound++
				}
			}
		}

		if removedThisRound == 0 {
			break
		}

		for r := 0; r < height; r++ {
			for c := 0; c < width; c++ {
				if toRemove[r][c] {
					board[r][c] = '.'
				}
			}
		}

		totalRemoved += int64(removedThisRound)
	}

	return totalRemoved
}
