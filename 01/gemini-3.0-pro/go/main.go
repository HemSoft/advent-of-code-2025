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

	pos := 50
	count := 0
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		dir := line[0]
		amount, _ := strconv.Atoi(line[1:])

		if dir == 'R' {
			pos = (pos + amount) % 100
		} else if dir == 'L' {
			pos = (pos - amount) % 100
			if pos < 0 {
				pos += 100
			}
		}

		if pos == 0 {
			count++
		}
	}

	fmt.Printf("Day 01 Part 1: %d\n", count)
}
