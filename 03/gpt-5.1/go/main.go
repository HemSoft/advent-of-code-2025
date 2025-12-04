package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var totalJoltagePart1 int64
	var totalJoltagePart2 int64

	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			continue
		}

		maxJoltagePart1 := 0
		found := false

		for d1 := 9; d1 >= 1 && !found; d1-- {
			c1 := byte('0' + d1)
			idx1 := indexByte(line, c1)
			if idx1 < 0 {
				continue
			}

			for d2 := 9; d2 >= 1; d2-- {
				c2 := byte('0' + d2)
				idx2 := lastIndexByte(line, c2)
				if idx2 < 0 {
					continue
				}

				if idx1 < idx2 {
					maxJoltagePart1 = d1*10 + d2
					found = true
					break
				}
			}
		}

		totalJoltagePart1 += int64(maxJoltagePart1)

		// Part 2: choose exactly 12 digits to form the largest possible number
		digits := line
		targetLength := 12
		chosen := make([]byte, targetLength)
		start := 0

		for pos := 0; pos < targetLength; pos++ {
			remainingNeeded := targetLength - pos - 1
			bestDigit := byte('0')
			bestIndex := -1

			for d := 9; d >= 0; d-- {
				ch := byte('0' + d)
				lastIndex := lastIndexByteFrom(digits, ch, start)
				if lastIndex < start {
					continue
				}

				if lastIndex <= len(digits)-1-remainingNeeded {
					bestDigit = ch
					bestIndex = lastIndex
					break
				}
			}

			if bestIndex == -1 {
				bestDigit = digits[start]
				bestIndex = start
			}

			chosen[pos] = bestDigit
			start = bestIndex + 1
		}

		lineJoltagePart2 := int64(0)
		for _, ch := range chosen {
			lineJoltagePart2 = lineJoltagePart2*10 + int64(ch-'0')
		}

		totalJoltagePart2 += lineJoltagePart2
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}

	fmt.Printf("Day 03 Part 1: %d\n", totalJoltagePart1)
	fmt.Printf("Day 03 Part 2: %d\n", totalJoltagePart2)
}

func indexByte(s string, c byte) int {
	for i := 0; i < len(s); i++ {
		if s[i] == c {
			return i
		}
	}
	return -1
}

func lastIndexByte(s string, c byte) int {
	for i := len(s) - 1; i >= 0; i-- {
		if s[i] == c {
			return i
		}
	}
	return -1
}

func lastIndexByteFrom(s string, c byte, start int) int {
	last := -1
	for i := start; i < len(s); i++ {
		if s[i] == c {
			last = i
		}
	}
	return last
}
