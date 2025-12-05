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

	pos1 := 50
	count1 := 0

	// Read lines into a slice first to iterate twice
	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, strings.TrimSpace(scanner.Text()))
	}

	// Part 1
	for _, line := range lines {
		if line == "" {
			continue
		}

		dir := line[0]
		amount, _ := strconv.Atoi(line[1:])

		if dir == 'R' {
			pos1 = (pos1 + amount) % 100
		} else if dir == 'L' {
			pos1 = (pos1 - amount) % 100
			if pos1 < 0 {
				pos1 += 100
			}
		}

		if pos1 == 0 {
			count1++
		}
	}

	fmt.Printf("Day 01 Part 1: %d\n", count1)

	// Part 2
	pos2 := 50
	count2 := 0

	for _, line := range lines {
		if line == "" {
			continue
		}

		dir := line[0]
		amount, _ := strconv.Atoi(line[1:])

		for i := 0; i < amount; i++ {
			if dir == 'R' {
				pos2 = (pos2 + 1) % 100
			} else if dir == 'L' {
				pos2--
				if pos2 < 0 {
					pos2 = 99
				}
			}

			if pos2 == 0 {
				count2++
			}
		}
	}

	fmt.Printf("Day 01 Part 2: %d\n", count2)
}
