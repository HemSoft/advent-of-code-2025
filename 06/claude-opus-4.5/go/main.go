package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Problem struct {
	numbers []int64
	op      rune
}

func isSeparatorColumn(grid []string, col int, dataRowCount int) bool {
	for r := 0; r < dataRowCount; r++ {
		if col < len(grid[r]) && grid[r][col] != ' ' {
			return false
		}
	}
	return true
}

func main() {
	data, _ := os.ReadFile("input.txt")
	lines := strings.Split(string(data), "\n")

	// Remove trailing empty lines
	for len(lines) > 0 && strings.TrimSpace(lines[len(lines)-1]) == "" {
		lines = lines[:len(lines)-1]
	}

	// Find max width and pad lines
	maxWidth := 0
	for _, line := range lines {
		if len(line) > maxWidth {
			maxWidth = len(line)
		}
	}

	grid := make([]string, len(lines))
	for i, line := range lines {
		grid[i] = line + strings.Repeat(" ", maxWidth-len(line))
	}

	rows := len(grid)
	cols := maxWidth
	operatorRow := grid[rows-1]

	var problems []Problem
	colStart := 0

	for colStart < cols {
		// Skip separator columns
		for colStart < cols && isSeparatorColumn(grid, colStart, rows-1) {
			colStart++
		}
		if colStart >= cols {
			break
		}

		// Find end of this problem
		colEnd := colStart
		for colEnd < cols && !isSeparatorColumn(grid, colEnd, rows-1) {
			colEnd++
		}

		// Extract numbers and operator
		var numbers []int64
		var op rune = ' '

		for r := 0; r < rows-1; r++ {
			segment := strings.TrimSpace(grid[r][colStart:colEnd])
			if segment != "" {
				if num, err := strconv.ParseInt(segment, 10, 64); err == nil {
					numbers = append(numbers, num)
				}
			}
		}

		// Get operator
		opSegment := strings.TrimSpace(operatorRow[colStart:colEnd])
		if len(opSegment) > 0 {
			op = rune(opSegment[0])
		}

		if len(numbers) > 0 && (op == '+' || op == '*') {
			problems = append(problems, Problem{numbers: numbers, op: op})
		}

		colStart = colEnd
	}

	// Calculate grand total
	var part1 int64 = 0
	for _, p := range problems {
		result := p.numbers[0]
		for i := 1; i < len(p.numbers); i++ {
			if p.op == '+' {
				result += p.numbers[i]
			} else {
				result *= p.numbers[i]
			}
		}
		part1 += result
	}

	fmt.Printf("Day 06 Part 1: %d\n", part1)

	// Part 2: Read columns right-to-left, digits top-to-bottom form numbers
	var part2 int64 = 0
	colStart = 0
	for colStart < cols {
		for colStart < cols && isSeparatorColumn(grid, colStart, rows-1) {
			colStart++
		}
		if colStart >= cols {
			break
		}

		colEnd := colStart
		for colEnd < cols && !isSeparatorColumn(grid, colEnd, rows-1) {
			colEnd++
		}

		// Get operator
		opSegment := strings.TrimSpace(operatorRow[colStart:colEnd])
		var op rune = ' '
		if len(opSegment) > 0 {
			op = rune(opSegment[0])
		}

		// Read columns right-to-left within this problem block
		var numbers2 []int64
		for c := colEnd - 1; c >= colStart; c-- {
			var digits []byte
			for r := 0; r < rows-1; r++ {
				ch := grid[r][c]
				if ch >= '0' && ch <= '9' {
					digits = append(digits, ch)
				}
			}
			if len(digits) > 0 {
				num, _ := strconv.ParseInt(string(digits), 10, 64)
				numbers2 = append(numbers2, num)
			}
		}

		if len(numbers2) > 0 && (op == '+' || op == '*') {
			result := numbers2[0]
			for i := 1; i < len(numbers2); i++ {
				if op == '+' {
					result += numbers2[i]
				} else {
					result *= numbers2[i]
				}
			}
			part2 += result
		}

		colStart = colEnd
	}

	fmt.Printf("Day 06 Part 2: %d\n", part2)
}
