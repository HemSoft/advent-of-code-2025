package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func isInvalidIdPart1(num int64) bool {
	s := strconv.FormatInt(num, 10)
	if len(s)%2 != 0 {
		return false
	}
	half := len(s) / 2
	return s[:half] == s[half:]
}

func isInvalidIdPart2(num int64) bool {
	s := strconv.FormatInt(num, 10)
	// Check for patterns repeated at least twice
	for patternLen := 1; patternLen <= len(s)/2; patternLen++ {
		if len(s)%patternLen != 0 {
			continue
		}
		pattern := s[:patternLen]
		repetitions := len(s) / patternLen
		if repetitions < 2 {
			continue
		}
		isRepeated := true
		for i := 1; i < repetitions; i++ {
			if s[i*patternLen:(i+1)*patternLen] != pattern {
				isRepeated = false
				break
			}
		}
		if isRepeated {
			return true
		}
	}
	return false
}

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))

	// Part 1
	var part1 int64 = 0
	ranges := strings.Split(input, ",")
	for _, r := range ranges {
		if r == "" {
			continue
		}
		parts := strings.Split(r, "-")
		start, _ := strconv.ParseInt(parts[0], 10, 64)
		end, _ := strconv.ParseInt(parts[1], 10, 64)
		for id := start; id <= end; id++ {
			if isInvalidIdPart1(id) {
				part1 += id
			}
		}
	}
	fmt.Printf("Day 02 Part 1: %d\n", part1)

	// Part 2
	var part2 int64 = 0
	for _, r := range ranges {
		if r == "" {
			continue
		}
		parts := strings.Split(r, "-")
		start, _ := strconv.ParseInt(parts[0], 10, 64)
		end, _ := strconv.ParseInt(parts[1], 10, 64)
		for id := start; id <= end; id++ {
			if isInvalidIdPart2(id) {
				part2 += id
			}
		}
	}
	fmt.Printf("Day 02 Part 2: %d\n", part2)
}
