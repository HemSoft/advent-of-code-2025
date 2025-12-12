package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

var graph = make(map[string][]string)
var memo1 = make(map[string]int64)
var memo2 = make(map[string]int64)

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.TrimSpace(line) == "" {
			continue
		}
		parts := strings.Split(line, ": ")
		source := parts[0]
		targets := strings.Split(parts[1], " ")
		graph[source] = targets
	}

	paths1 := countPathsP1("you")
	fmt.Printf("Day 11 Part 1: %d\n", paths1)

	paths2 := countPathsP2("svr", 0)
	fmt.Printf("Day 11 Part 2: %d\n", paths2)
}

func countPathsP1(current string) int64 {
	if current == "out" {
		return 1
	}
	if val, ok := memo1[current]; ok {
		return val
	}

	if _, ok := graph[current]; !ok {
		return 0
	}

	var total int64 = 0
	for _, neighbor := range graph[current] {
		total += countPathsP1(neighbor)
	}

	memo1[current] = total
	return total
}

func countPathsP2(current string, mask int) int64 {
	if current == "dac" {
		mask |= 1
	} else if current == "fft" {
		mask |= 2
	}

	if current == "out" {
		if mask == 3 {
			return 1
		}
		return 0
	}

	key := fmt.Sprintf("%s-%d", current, mask)
	if val, ok := memo2[key]; ok {
		return val
	}

	if _, ok := graph[current]; !ok {
		return 0
	}

	var total int64 = 0
	for _, neighbor := range graph[current] {
		total += countPathsP2(neighbor, mask)
	}

	memo2[key] = total
	return total
}
