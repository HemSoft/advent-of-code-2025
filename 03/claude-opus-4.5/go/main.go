package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func maxJoltage(line string) int {
	n := len(line)
	if n < 2 {
		return 0
	}

	// Precompute suffix maximum
	suffixMax := make([]int, n)
	suffixMax[n-1] = 0
	for i := n - 2; i >= 0; i-- {
		digit := int(line[i+1] - '0')
		if digit > suffixMax[i+1] {
			suffixMax[i] = digit
		} else {
			suffixMax[i] = suffixMax[i+1]
		}
	}

	// Find max joltage
	maxJ := 0
	for i := 0; i < n-1; i++ {
		tensDigit := int(line[i] - '0')
		unitsDigit := suffixMax[i]
		joltage := tensDigit*10 + unitsDigit
		if joltage > maxJ {
			maxJ = joltage
		}
	}

	return maxJ
}

func maxJoltagePart2(line string, k int) int64 {
	n := len(line)
	if n < k {
		return 0
	}
	if n == k {
		val, _ := strconv.ParseInt(line, 10, 64)
		return val
	}

	// Greedy: pick k digits to form largest number
	result := make([]byte, k)
	startIdx := 0

	for i := 0; i < k; i++ {
		remaining := k - i
		endIdx := n - remaining

		maxDigit := byte('0')
		maxPos := startIdx

		for j := startIdx; j <= endIdx; j++ {
			if line[j] > maxDigit {
				maxDigit = line[j]
				maxPos = j
			}
		}

		result[i] = maxDigit
		startIdx = maxPos + 1
	}

	val, _ := strconv.ParseInt(string(result), 10, 64)
	return val
}

func main() {
	data, _ := os.ReadFile("input.txt")
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")

	// Part 1
	var part1 int64 = 0
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" {
			part1 += int64(maxJoltage(line))
		}
	}
	fmt.Printf("Day 03 Part 1: %d\n", part1)

	// Part 2
	var part2 int64 = 0
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" {
			part2 += maxJoltagePart2(line, 12)
		}
	}
	fmt.Printf("Day 03 Part 2: %d\n", part2)
}
