package main

import (
	"fmt"
	"os"
	"strings"
)

var graph map[string][]string
var memo1 map[string]int64
var memo2 map[string]int64

func countPaths(current, target string) int64 {
	if current == target {
		return 1
	}

	if val, ok := memo1[current]; ok {
		return val
	}

	neighbors, exists := graph[current]
	if !exists {
		return 0
	}

	var count int64 = 0
	for _, neighbor := range neighbors {
		count += countPaths(neighbor, target)
	}
	memo1[current] = count
	return count
}

func countPathsWithRequired(current, target string, visitedDac, visitedFft bool) int64 {
	if current == "dac" {
		visitedDac = true
	}
	if current == "fft" {
		visitedFft = true
	}

	if current == target {
		if visitedDac && visitedFft {
			return 1
		}
		return 0
	}

	key := fmt.Sprintf("%s_%t_%t", current, visitedDac, visitedFft)
	if val, ok := memo2[key]; ok {
		return val
	}

	neighbors, exists := graph[current]
	if !exists {
		return 0
	}

	var count int64 = 0
	for _, neighbor := range neighbors {
		count += countPathsWithRequired(neighbor, target, visitedDac, visitedFft)
	}
	memo2[key] = count
	return count
}

func main() {
	data, _ := os.ReadFile("input.txt")
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")

	graph = make(map[string][]string)
	memo1 = make(map[string]int64)
	memo2 = make(map[string]int64)

	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}
		parts := strings.Split(line, ":")
		source := strings.TrimSpace(parts[0])
		destStr := strings.TrimSpace(parts[1])
		destinations := strings.Fields(destStr)
		graph[source] = destinations
	}

	// Part 1
	var part1 int64 = countPaths("you", "out")
	fmt.Printf("Day 11 Part 1: %d\n", part1)

	// Part 2
	var part2 int64 = countPathsWithRequired("svr", "out", false, false)
	fmt.Printf("Day 11 Part 2: %d\n", part2)
}
