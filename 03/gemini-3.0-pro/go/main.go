package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var totalJoltage int64 = 0
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" {
			continue
		}

		maxJoltage := 0
		found := false

		for d1 := 9; d1 >= 1; d1-- {
			c1 := string(rune('0' + d1))
			idx1 := strings.Index(line, c1)

			if idx1 == -1 {
				continue
			}

			for d2 := 9; d2 >= 1; d2-- {
				c2 := string(rune('0' + d2))
				idx2 := strings.LastIndex(line, c2)

				if idx2 == -1 {
					continue
				}

				if idx1 < idx2 {
					maxJoltage = d1*10 + d2
					found = true
					break
				}
			}
			if found {
				break
			}
		}
		totalJoltage += int64(maxJoltage)
	}

	fmt.Printf("Day 03 Part 1: %d\n", totalJoltage)

	// Reset file pointer for Part 2
	file.Seek(0, 0)
	scanner = bufio.NewScanner(file)
	var totalJoltagePart2 int64 = 0

	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" {
			continue
		}

		var result strings.Builder
		currentIndex := 0
		digitsNeeded := 12
		length := len(line)

		for i := 0; i < digitsNeeded; i++ {
			remainingNeeded := digitsNeeded - 1 - i
			searchEndIndex := length - 1 - remainingNeeded

			bestDigit := -1
			bestDigitIndex := -1

			for d := 9; d >= 1; d-- {
				c := string(rune('0' + d))
				idx := strings.Index(line[currentIndex:], c)

				if idx != -1 {
					realIdx := currentIndex + idx
					if realIdx <= searchEndIndex {
						bestDigit = d
						bestDigitIndex = realIdx
						break
					}
				}
			}

			if bestDigit != -1 {
				result.WriteString(fmt.Sprintf("%d", bestDigit))
				currentIndex = bestDigitIndex + 1
			}
		}

		if result.Len() == 12 {
			val := int64(0)
			fmt.Sscanf(result.String(), "%d", &val)
			totalJoltagePart2 += val
		}
	}

	fmt.Printf("Day 03 Part 2: %d\n", totalJoltagePart2)
}
