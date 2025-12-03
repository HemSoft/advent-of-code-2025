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

	position := 50
	zeroCount := int64(0)

	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			continue
		}

		dir := line[0]
		var distance int
		_, err := fmt.Sscanf(line[1:], "%d", &distance)
		if err != nil {
			continue
		}

		distance = distance % 100

		if dir == 'R' {
			position = (position + distance) % 100
		} else if dir == 'L' {
			position = (position - distance) % 100
			if position < 0 {
				position += 100
			}
		}

		if position == 0 {
			zeroCount++
		}
	}

	// Part 1
	part1 := zeroCount
	fmt.Printf("Day 01 Part 1: %d\n", part1)

	// Part 2 (not implemented yet)
	part2 := int64(0)
	fmt.Printf("Day 01 Part 2: %d\n", part2)
}
