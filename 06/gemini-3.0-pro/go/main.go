package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	maxWidth := 0
	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, line)
		if len(line) > maxWidth {
			maxWidth = len(line)
		}
	}

	// Pad lines
	for i := range lines {
		if len(lines[i]) < maxWidth {
			lines[i] = lines[i] + strings.Repeat(" ", maxWidth-len(lines[i]))
		}
	}

	type Block struct {
		start, end int
	}
	var blocks []Block
	startCol := -1

	for col := 0; col < maxWidth; col++ {
		isEmpty := true
		for _, line := range lines {
			if line[col] != ' ' {
				isEmpty = false
				break
			}
		}

		if isEmpty {
			if startCol != -1 {
				blocks = append(blocks, Block{startCol, col - 1})
				startCol = -1
			}
		} else {
			if startCol == -1 {
				startCol = col
			}
		}
	}

	if startCol != -1 {
		blocks = append(blocks, Block{startCol, maxWidth - 1})
	}

	var totalSumP1 int64 = 0
	for _, b := range blocks {
		totalSumP1 += processBlock(lines, b.start, b.end)
	}
	fmt.Printf("Day 06 Part 1: %d\n", totalSumP1)

	var totalSumP2 int64 = 0
	for _, b := range blocks {
		totalSumP2 += processBlockPart2(lines, b.start, b.end)
	}
	fmt.Printf("Day 06 Part 2: %d\n", totalSumP2)
}

func processBlock(lines []string, start, end int) int64 {
	var numbers []int64
	var op string

	for _, line := range lines {
		segment := strings.TrimSpace(line[start : end+1])
		if segment == "" {
			continue
		}

		if segment == "+" || segment == "*" {
			op = segment
		} else {
			num, err := strconv.ParseInt(segment, 10, 64)
			if err == nil {
				numbers = append(numbers, num)
			}
		}
	}

	if op == "+" {
		var sum int64 = 0
		for _, n := range numbers {
			sum += n
		}
		return sum
	} else if op == "*" {
		var prod int64 = 1
		for _, n := range numbers {
			prod *= n
		}
		return prod
	}
	return 0
}

func processBlockPart2(lines []string, start, end int) int64 {
	var numbers []int64
	var op string

	for col := start; col <= end; col++ {
		var chars []byte
		for _, line := range lines {
			if line[col] != ' ' {
				chars = append(chars, line[col])
			}
		}

		if len(chars) == 0 {
			continue
		}

		lastChar := chars[len(chars)-1]
		if lastChar == '+' || lastChar == '*' {
			op = string(lastChar)
			chars = chars[:len(chars)-1]
		}

		if len(chars) > 0 {
			numStr := string(chars)
			num, err := strconv.ParseInt(numStr, 10, 64)
			if err == nil {
				numbers = append(numbers, num)
			}
		}
	}

	if op == "+" {
		var sum int64 = 0
		for _, n := range numbers {
			sum += n
		}
		return sum
	} else if op == "*" {
		var prod int64 = 1
		for _, n := range numbers {
			prod *= n
		}
		return prod
	}
	return 0
}
