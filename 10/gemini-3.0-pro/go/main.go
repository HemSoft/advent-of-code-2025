package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"regexp"
	"strconv"
	"strings"
)

func main() {
	content, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(content), "\n")
	var totalPressesPart1 int64 = 0
	var totalPressesPart2 int64 = 0

	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}
		totalPressesPart1 += solvePart1(line)
		totalPressesPart2 += solvePart2(line)
	}

	fmt.Printf("Day 10 Part 1: %d\n", totalPressesPart1)
	fmt.Printf("Day 10 Part 2: %d\n", totalPressesPart2)
}

func solvePart1(line string) int64 {
	reTarget := regexp.MustCompile(`\[([.#]+)\]`)
	match := reTarget.FindStringSubmatch(line)
	if match == nil {
		return 0
	}
	targetStr := match[1]
	L := len(targetStr)
	target := make([]int, L)
	for i, c := range targetStr {
		if c == '#' {
			target[i] = 1
		} else {
			target[i] = 0
		}
	}

	reButtons := regexp.MustCompile(`\(([\d,]+)\)`)
	buttonMatches := reButtons.FindAllStringSubmatch(line, -1)
	var buttons [][]int
	for _, bm := range buttonMatches {
		b := make([]int, L)
		parts := strings.Split(bm[1], ",")
		for _, p := range parts {
			idx, err := strconv.Atoi(p)
			if err == nil && idx < L {
				b[idx] = 1
			}
		}
		buttons = append(buttons, b)
	}

	B := len(buttons)
	M := make([][]int, L)
	for i := range M {
		M[i] = make([]int, B+1)
	}

	for r := 0; r < L; r++ {
		for c := 0; c < B; c++ {
			M[r][c] = buttons[c][r]
		}
		M[r][B] = target[r]
	}

	pivotRow := 0
	var pivotCols []int
	colToPivotRow := make([]int, B)
	for i := 0; i < B; i++ {
		colToPivotRow[i] = -1
	}

	for c := 0; c < B && pivotRow < L; c++ {
		sel := -1
		for r := pivotRow; r < L; r++ {
			if M[r][c] == 1 {
				sel = r
				break
			}
		}

		if sel == -1 {
			continue
		}

		// Swap
		M[pivotRow], M[sel] = M[sel], M[pivotRow]

		// Eliminate
		for r := 0; r < L; r++ {
			if r != pivotRow && M[r][c] == 1 {
				for k := c; k <= B; k++ {
					M[r][k] ^= M[pivotRow][k]
				}
			}
		}

		pivotCols = append(pivotCols, c)
		colToPivotRow[c] = pivotRow
		pivotRow++
	}

	for r := pivotRow; r < L; r++ {
		if M[r][B] == 1 {
			return 0
		}
	}

	var freeCols []int
	pivotSet := make(map[int]bool)
	for _, p := range pivotCols {
		pivotSet[p] = true
	}
	for c := 0; c < B; c++ {
		if !pivotSet[c] {
			freeCols = append(freeCols, c)
		}
	}

	minPresses := int64(math.MaxInt64)
	numFree := len(freeCols)
	combinations := int64(1) << numFree

	for i := int64(0); i < combinations; i++ {
		x := make([]int, B)
		var currentPresses int64 = 0

		for k := 0; k < numFree; k++ {
			if (i & (1 << k)) != 0 {
				x[freeCols[k]] = 1
				currentPresses++
			}
		}

		for _, pCol := range pivotCols {
			r := colToPivotRow[pCol]
			val := M[r][B]
			for _, fCol := range freeCols {
				if M[r][fCol] == 1 && x[fCol] == 1 {
					val ^= 1
				}
			}
			x[pCol] = val
			if val == 1 {
				currentPresses++
			}
		}

		if currentPresses < minPresses {
			minPresses = currentPresses
		}
	}

	return minPresses
}

func solvePart2(line string) int64 {
	reTarget := regexp.MustCompile(`\{([\d,]+)\}`)
	match := reTarget.FindStringSubmatch(line)
	if match == nil {
		return 0
	}
	targetParts := strings.Split(match[1], ",")
	L := len(targetParts)
	b := make([]float64, L)
	for i, p := range targetParts {
		val, _ := strconv.ParseFloat(p, 64)
		b[i] = val
	}

	reButtons := regexp.MustCompile(`\(([\d,]+)\)`)
	buttonMatches := reButtons.FindAllStringSubmatch(line, -1)
	var A_cols [][]float64
	for _, bm := range buttonMatches {
		col := make([]float64, L)
		parts := strings.Split(bm[1], ",")
		for _, p := range parts {
			idx, err := strconv.Atoi(p)
			if err == nil && idx < L {
				col[idx] = 1.0
			}
		}
		A_cols = append(A_cols, col)
	}

	B := len(A_cols)
	matrix := make([][]float64, L)
	for i := range matrix {
		matrix[i] = make([]float64, B+1)
	}

	for r := 0; r < L; r++ {
		for c := 0; c < B; c++ {
			matrix[r][c] = A_cols[c][r]
		}
		matrix[r][B] = b[r]
	}

	pivotRow := 0
	var pivotCols []int
	colToPivotRow := make([]int, B)
	for i := 0; i < B; i++ {
		colToPivotRow[i] = -1
	}

	for c := 0; c < B && pivotRow < L; c++ {
		sel := -1
		for r := pivotRow; r < L; r++ {
			if math.Abs(matrix[r][c]) > 1e-9 {
				sel = r
				break
			}
		}

		if sel == -1 {
			continue
		}

		matrix[pivotRow], matrix[sel] = matrix[sel], matrix[pivotRow]

		pivotVal := matrix[pivotRow][c]
		for k := c; k <= B; k++ {
			matrix[pivotRow][k] /= pivotVal
		}

		for r := 0; r < L; r++ {
			if r != pivotRow && math.Abs(matrix[r][c]) > 1e-9 {
				factor := matrix[r][c]
				for k := c; k <= B; k++ {
					matrix[r][k] -= factor * matrix[pivotRow][k]
				}
			}
		}

		pivotCols = append(pivotCols, c)
		colToPivotRow[c] = pivotRow
		pivotRow++
	}

	for r := pivotRow; r < L; r++ {
		if math.Abs(matrix[r][B]) > 1e-9 {
			return 0
		}
	}

	var freeCols []int
	pivotSet := make(map[int]bool)
	for _, p := range pivotCols {
		pivotSet[p] = true
	}
	for c := 0; c < B; c++ {
		if !pivotSet[c] {
			freeCols = append(freeCols, c)
		}
	}

	UBs := make([]int64, B)
	for c := 0; c < B; c++ {
		minUb := int64(math.MaxInt64)
		bounded := false
		for r := 0; r < L; r++ {
			if A_cols[c][r] > 0.5 {
				val := int64(b[r] / A_cols[c][r])
				if val < minUb {
					minUb = val
				}
				bounded = true
			}
		}
		if bounded {
			UBs[c] = minUb
		} else {
			UBs[c] = 0
		}
	}

	minTotalPresses := int64(math.MaxInt64)
	found := false

	var search func(freeIdx int, currentFreeVals []int64)
	search = func(freeIdx int, currentFreeVals []int64) {
		if freeIdx == len(freeCols) {
			var currentPresses int64 = 0
			for _, v := range currentFreeVals {
				currentPresses += v
			}

			possible := true
			for _, pCol := range pivotCols {
				r := colToPivotRow[pCol]
				val := matrix[r][B]
				for j, fCol := range freeCols {
					val -= matrix[r][fCol] * float64(currentFreeVals[j])
				}

				if val < -1e-9 {
					possible = false
					break
				}
				longVal := int64(math.Round(val))
				if math.Abs(val - float64(longVal)) > 1e-9 {
					possible = false
					break
				}
				currentPresses += longVal
			}

			if possible {
				if currentPresses < minTotalPresses {
					minTotalPresses = currentPresses
					found = true
				}
			}
			return
		}

		fColIdx := freeCols[freeIdx]
		limit := UBs[fColIdx]

		for val := int64(0); val <= limit; val++ {
			currentFreeVals[freeIdx] = val
			search(freeIdx+1, currentFreeVals)
		}
	}

	search(0, make([]int64, len(freeCols)))

	if found {
		return minTotalPresses
	}
	return 0
}
