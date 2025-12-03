package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	data, err := os.ReadFile("input.txt")
	if err != nil {
		fmt.Println("Error reading input.txt:", err)
		return
	}
	input := strings.TrimSpace(string(data))
	ranges := strings.Split(input, ",")

	var totalSum int64 = 0

	for _, r := range ranges {
		parts := strings.Split(strings.TrimSpace(r), "-")
		if len(parts) != 2 {
			continue
		}

		start, _ := strconv.ParseInt(parts[0], 10, 64)
		end, _ := strconv.ParseInt(parts[1], 10, 64)

		for i := start; i <= end; i++ {
			if isInvalidId(i) {
				totalSum += i
			}
		}
	}

	fmt.Printf("Day 02 Part 1: %d\n", totalSum)

	var totalSumPart2 int64 = 0

	for _, r := range ranges {
		parts := strings.Split(strings.TrimSpace(r), "-")
		if len(parts) != 2 {
			continue
		}

		start, _ := strconv.ParseInt(parts[0], 10, 64)
		end, _ := strconv.ParseInt(parts[1], 10, 64)

		for i := start; i <= end; i++ {
			if isInvalidIdPart2(i) {
				totalSumPart2 += i
			}
		}
	}

	fmt.Printf("Day 02 Part 2: %d\n", totalSumPart2)
}

func isInvalidId(id int64) bool {
	s := strconv.FormatInt(id, 10)
	if len(s)%2 != 0 {
		return false
	}

	halfLen := len(s) / 2
	firstHalf := s[:halfLen]
	secondHalf := s[halfLen:]

	return firstHalf == secondHalf
}

func isInvalidIdPart2(id int64) bool {
	s := strconv.FormatInt(id, 10)
	length := len(s)

	for patternLen := 1; patternLen <= length/2; patternLen++ {
		if length%patternLen != 0 {
			continue
		}

		pattern := s[:patternLen]
		repetitions := length / patternLen

		if strings.Repeat(pattern, repetitions) == s {
			return true
		}
	}

	return false
}
