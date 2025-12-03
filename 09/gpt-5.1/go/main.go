package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))
	_ = input

	// Part 1
	var part1 int64 = 0
	fmt.Printf("Day 09 Part 1: %d\n", part1)

	// Part 2
	var part2 int64 = 0
	fmt.Printf("Day 09 Part 2: %d\n", part2)
}