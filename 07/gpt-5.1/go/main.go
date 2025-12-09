package main

import (
	"bufio"
	"fmt"
	"os"
)

type point struct {
	r int
	c int
}

func solvePart1(lines []string) int64 {
	if len(lines) == 0 {
		return 0
	}

	height := len(lines)
	width := 0
	for _, line := range lines {
		if len(line) > width {
			width = len(line)
		}
	}

	grid := make([][]rune, height)
	for i, line := range lines {
		row := []rune(line)
		if len(row) < width {
			padded := make([]rune, width)
			copy(padded, row)
			for j := len(row); j < width; j++ {
				padded[j] = '.'
			}
			grid[i] = padded
		} else {
			grid[i] = row
		}
	}

	startRow, startCol := -1, -1
	for r := 0; r < height && startRow == -1; r++ {
		for c := 0; c < width; c++ {
			if grid[r][c] == 'S' {
				startRow, startCol = r, c
				break
			}
		}
	}

	if startRow == -1 {
		return 0
	}

	current := map[point]struct{}{
		{r: startRow, c: startCol}: {},
	}
	var splits int64

	for len(current) > 0 {
		next := make(map[point]struct{})
		for p := range current {
			nr := p.r + 1
			if nr >= height {
				continue
			}

			cell := grid[nr][p.c]
			if cell == '^' {
				splits++
				if p.c-1 >= 0 {
					next[point{r: nr, c: p.c - 1}] = struct{}{}
				}
				if p.c+1 < width {
					next[point{r: nr, c: p.c + 1}] = struct{}{}
				}
			} else {
				next[point{r: nr, c: p.c}] = struct{}{}
			}
		}
		current = next
	}

	return splits
}

func solvePart2(lines []string) int64 {
	if len(lines) == 0 {
		return 0
	}

	height := len(lines)
	width := 0
	for _, line := range lines {
		if len(line) > width {
			width = len(line)
		}
	}

	grid := make([][]rune, height)
	for i, line := range lines {
		row := []rune(line)
		if len(row) < width {
			padded := make([]rune, width)
			copy(padded, row)
			for j := len(row); j < width; j++ {
				padded[j] = '.'
			}
			grid[i] = padded
		} else {
			grid[i] = row
		}
	}

	startRow, startCol := -1, -1
	for r := 0; r < height && startRow == -1; r++ {
		for c := 0; c < width; c++ {
			if grid[r][c] == 'S' {
				startRow, startCol = r, c
				break
			}
		}
	}

	if startRow == -1 {
		return 0
	}

	current := map[point]int64{
		{r: startRow, c: startCol}: 1,
	}
	var finished int64

	for len(current) > 0 {
		next := make(map[point]int64)
		for p, count := range current {
			nr := p.r + 1
			if nr >= height {
				finished += count
				continue
			}

			cell := grid[nr][p.c]
			if cell == '^' {
				if p.c-1 >= 0 {
					key := point{r: nr, c: p.c - 1}
					next[key] += count
				}
				if p.c+1 < width {
					key := point{r: nr, c: p.c + 1}
					next[key] += count
				}
			} else {
				key := point{r: nr, c: p.c}
				next[key] += count
			}
		}
		current = next
	}

	return finished
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var lines []string
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		panic(err)
	}

	part1 := solvePart1(lines)
	fmt.Printf("Day 07 Part 1: %d\n", part1)

	part2 := solvePart2(lines)
	fmt.Printf("Day 07 Part 2: %d\n", part2)
}