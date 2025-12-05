package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, _ := os.ReadFile("input.txt")
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")

	var grid []string
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if len(line) > 0 {
			grid = append(grid, line)
		}
	}

	rows := len(grid)
	cols := len(grid[0])

	// Part 1: Count rolls with fewer than 4 adjacent rolls
	dx := []int{-1, -1, -1, 0, 0, 1, 1, 1}
	dy := []int{-1, 0, 1, -1, 1, -1, 0, 1}

	var part1 int64 = 0
	for r := 0; r < rows; r++ {
		for c := 0; c < cols; c++ {
			if grid[r][c] != '@' {
				continue
			}

			adjacentRolls := 0
			for d := 0; d < 8; d++ {
				nr := r + dx[d]
				nc := c + dy[d]
				if nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc] == '@' {
					adjacentRolls++
				}
			}

			if adjacentRolls < 4 {
				part1++
			}
		}
	}

	fmt.Printf("Day 04 Part 1: %d\n", part1)

	// Part 2: Iteratively remove accessible rolls until none remain
	mutableGrid := make([][]byte, rows)
	for i := range grid {
		mutableGrid[i] = []byte(grid[i])
	}

	var part2 int64 = 0

	for {
		var toRemove [][2]int

		for r := 0; r < rows; r++ {
			for c := 0; c < cols; c++ {
				if mutableGrid[r][c] != '@' {
					continue
				}

				adjacentRolls := 0
				for d := 0; d < 8; d++ {
					nr := r + dx[d]
					nc := c + dy[d]
					if nr >= 0 && nr < rows && nc >= 0 && nc < cols && mutableGrid[nr][nc] == '@' {
						adjacentRolls++
					}
				}

				if adjacentRolls < 4 {
					toRemove = append(toRemove, [2]int{r, c})
				}
			}
		}

		if len(toRemove) == 0 {
			break
		}

		for _, pos := range toRemove {
			mutableGrid[pos[0]][pos[1]] = '.'
		}

		part2 += int64(len(toRemove))
	}

	fmt.Printf("Day 04 Part 2: %d\n", part2)
}
