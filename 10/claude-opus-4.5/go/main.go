package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func solveMachine(line string) int {
	// Parse indicator lights pattern
	lightRe := regexp.MustCompile(`\[([.#]+)\]`)
	lightMatch := lightRe.FindStringSubmatch(line)
	pattern := lightMatch[1]
	n := len(pattern)

	// Target: 1 where '#', 0 where '.'
	target := make([]int, n)
	for i, c := range pattern {
		if c == '#' {
			target[i] = 1
		}
	}

	// Parse buttons
	buttonRe := regexp.MustCompile(`\(([0-9,]+)\)`)
	buttonMatches := buttonRe.FindAllStringSubmatch(line, -1)
	var buttons [][]int
	for _, m := range buttonMatches {
		parts := strings.Split(m[1], ",")
		var indices []int
		for _, p := range parts {
			idx, _ := strconv.Atoi(p)
			indices = append(indices, idx)
		}
		buttons = append(buttons, indices)
	}

	numButtons := len(buttons)

	// Build augmented matrix [A | target]
	matrix := make([][]int, n)
	for i := 0; i < n; i++ {
		matrix[i] = make([]int, numButtons+1)
		matrix[i][numButtons] = target[i]
	}
	for j, btn := range buttons {
		for _, idx := range btn {
			if idx < n {
				matrix[idx][j] = 1
			}
		}
	}

	// Gaussian elimination over GF(2)
	pivotCol := make([]int, n)
	for i := range pivotCol {
		pivotCol[i] = -1
	}
	rank := 0

	for col := 0; col < numButtons && rank < n; col++ {
		// Find pivot
		pivotRow := -1
		for row := rank; row < n; row++ {
			if matrix[row][col] == 1 {
				pivotRow = row
				break
			}
		}

		if pivotRow == -1 {
			continue
		}

		// Swap rows
		matrix[rank], matrix[pivotRow] = matrix[pivotRow], matrix[rank]
		pivotCol[rank] = col

		// Eliminate
		for row := 0; row < n; row++ {
			if row != rank && matrix[row][col] == 1 {
				for k := 0; k <= numButtons; k++ {
					matrix[row][k] ^= matrix[rank][k]
				}
			}
		}
		rank++
	}

	// Check for inconsistency
	for row := rank; row < n; row++ {
		if matrix[row][numButtons] == 1 {
			return 1<<31 - 1
		}
	}

	// Find free variables
	pivotCols := make(map[int]bool)
	for i := 0; i < rank; i++ {
		if pivotCol[i] >= 0 {
			pivotCols[pivotCol[i]] = true
		}
	}
	var freeVars []int
	for j := 0; j < numButtons; j++ {
		if !pivotCols[j] {
			freeVars = append(freeVars, j)
		}
	}

	// Try all combinations of free variables
	minPresses := 1<<31 - 1
	numFree := len(freeVars)

	for mask := 0; mask < (1 << numFree); mask++ {
		solution := make([]int, numButtons)

		// Set free variables
		for i, fv := range freeVars {
			solution[fv] = (mask >> i) & 1
		}

		// Back-substitute
		for row := rank - 1; row >= 0; row-- {
			col := pivotCol[row]
			val := matrix[row][numButtons]
			for j := col + 1; j < numButtons; j++ {
				val ^= matrix[row][j] * solution[j]
			}
			solution[col] = val
		}

		presses := 0
		for _, v := range solution {
			presses += v
		}
		if presses < minPresses {
			minPresses = presses
		}
	}

	return minPresses
}

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))
	lines := strings.Split(input, "\n")

	var part1 int64 = 0
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" {
			part1 += int64(solveMachine(line))
		}
	}
	fmt.Printf("Day 10 Part 1: %d\n", part1)

	// Part 2
	var part2 int64 = 0
	fmt.Printf("Day 10 Part 2: %d\n", part2)
}