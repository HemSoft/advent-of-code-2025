package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	data, _ := os.ReadFile("input.txt")
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")

	position := 50
	zeroCountPart1 := 0
	zeroCountPart2 := 0

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		direction := line[0]
		distance, _ := strconv.Atoi(line[1:])

		var newPosition, firstHit int
		if direction == 'L' {
			newPosition = ((position - distance) % 100 + 100) % 100
			if position == 0 {
				firstHit = 100
			} else {
				firstHit = position
			}
		} else {
			newPosition = (position + distance) % 100
			if position == 0 {
				firstHit = 100
			} else {
				firstHit = 100 - position
			}
		}

		if newPosition == 0 {
			zeroCountPart1++
		}

		if firstHit <= distance {
			zeroCountPart2 += 1 + (distance-firstHit)/100
		}

		position = newPosition
	}

	fmt.Printf("Day 01 Part 1: %d\n", zeroCountPart1)
	fmt.Printf("Day 01 Part 2: %d\n", zeroCountPart2)
}
