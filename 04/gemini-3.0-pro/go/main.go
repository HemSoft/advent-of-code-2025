package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}
	input := strings.TrimSpace(string(data))
	linesStr := strings.Split(input, "\n")

	var grid [][]rune
	for _, line := range linesStr {
		grid = append(grid, []rune(strings.TrimSpace(line)))
	}

	rows := len(grid)
	cols := 0
	if rows > 0 {
		cols = len(grid[0])
	}

	totalRemoved := 0
	iteration := 0

	for {
		iteration++
		var toRemove [][2]int

		for r := 0; r < rows; r++ {
			for c := 0; c < cols; c++ {
				if grid[r][c] == '@' {
					neighborCount := 0
					for dr := -1; dr <= 1; dr++ {
						for dc := -1; dc <= 1; dc++ {
							if dr == 0 && dc == 0 {
								continue
							}

							nr := r + dr
							nc := c + dc

							if nr >= 0 && nr < rows && nc >= 0 && nc < cols {
								if grid[nr][nc] == '@' {
									neighborCount++
								}
							}
						}
					}

					if neighborCount < 4 {
						toRemove = append(toRemove, [2]int{r, c})
					}
				}
			}
		}

		if len(toRemove) == 0 {
			break
		}

		if iteration == 1 {
			fmt.Printf("Day 04 Part 1: %d\n", len(toRemove))
		}

		totalRemoved += len(toRemove)

		for _, coords := range toRemove {
			grid[coords[0]][coords[1]] = '.'
		}
	}

	fmt.Printf("Day 04 Part 2: %d\n", totalRemoved)
}
