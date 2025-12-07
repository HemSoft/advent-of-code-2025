package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func solve(lines []string) int64 {
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

	// Pad lines to equal width
	grid := make([]string, height)
	for i, line := range lines {
		trimmed := strings.TrimRight(line, "\r\n")
		if len(trimmed) < width {
			trimmed = trimmed + strings.Repeat(" ", width-len(trimmed))
		}
		grid[i] = trimmed
	}

	type rng struct{ start, end int }
	ranges := []rng{}
	inBlock := false
	startCol := 0

	for x := 0; x < width; x++ {
		allSpace := true
		for y := 0; y < height; y++ {
			if grid[y][x] != ' ' {
				allSpace = false
				break
			}
		}

		if allSpace {
			if inBlock {
				ranges = append(ranges, rng{start: startCol, end: x - 1})
				inBlock = false
			}
		} else if !inBlock {
			inBlock = true
			startCol = x
		}
	}

	if inBlock {
		ranges = append(ranges, rng{start: startCol, end: width - 1})
	}

	var total int64 = 0

	for _, r := range ranges {
		start, end := r.start, r.end
		// Find operator in bottom row
		var op byte = 0
		for x := start; x <= end; x++ {
			c := grid[height-1][x]
			if c == '+' || c == '*' {
				op = c
				break
			}
		}
		if op == 0 {
			continue
		}

		nums := []int64{}
		for y := 0; y < height-1; y++ {
			segment := grid[y][start : end+1]
			s := strings.TrimSpace(segment)
			if s == "" {
				continue
			}
			var n int64
			fmt.Sscanf(s, "%d", &n)
			nums = append(nums, n)
		}

		if len(nums) == 0 {
			continue
		}

		var value int64
		if op == '+' {
			value = 0
			for _, n := range nums {
				value += n
			}
		} else { // '*'
			value = 1
			for _, n := range nums {
				value *= n
			}
		}

		total += value
	}

	return total
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lines := []string{}
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	// Part 1
	part1 := solve(lines)
	fmt.Printf("Day 06 Part 1: %d\n", part1)

	// Part 2
	part2 := solvePart2(lines)
	fmt.Printf("Day 06 Part 2: %d\n", part2)
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

	grid := make([]string, height)
	for i, line := range lines {
		trimmed := strings.TrimRight(line, "\r\n")
		if len(trimmed) < width {
			trimmed = trimmed + strings.Repeat(" ", width-len(trimmed))
		}
		grid[i] = trimmed
	}

	type rng struct{ start, end int }
	ranges := []rng{}
	inBlock := false
	startCol := 0

	for x := 0; x < width; x++ {
		allSpace := true
		for y := 0; y < height; y++ {
			if grid[y][x] != ' ' {
				allSpace = false
				break
			}
		}

		if allSpace {
			if inBlock {
				ranges = append(ranges, rng{start: startCol, end: x - 1})
				inBlock = false
			}
		} else if !inBlock {
			inBlock = true
			startCol = x
		}
	}

	if inBlock {
		ranges = append(ranges, rng{start: startCol, end: width - 1})
	}

	var total int64 = 0

	for _, r := range ranges {
		start, end := r.start, r.end

		var op byte = 0
		for x := start; x <= end; x++ {
			c := grid[height-1][x]
			if c == '+' || c == '*' {
				op = c
				break
			}
		}
		if op == 0 {
			continue
		}

		nums := []int64{}

		for x := end; x >= start; x-- {
			var digits strings.Builder
			for y := 0; y < height-1; y++ {
				c := grid[y][x]
				if c >= '0' && c <= '9' {
					digits.WriteByte(c)
				}
			}

			if digits.Len() > 0 {
				var n int64
				fmt.Sscanf(digits.String(), "%d", &n)
				nums = append(nums, n)
			}
		}

		if len(nums) == 0 {
			continue
		}

		var value int64
		if op == '+' {
			value = 0
			for _, n := range nums {
				value += n
			}
		} else {
			value = 1
			for _, n := range nums {
				value *= n
			}
		}

		total += value
	}

	return total
}
