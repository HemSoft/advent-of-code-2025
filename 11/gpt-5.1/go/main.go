package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func parseGraph(input string) map[string][]string {
	graph := make(map[string][]string)
	scanner := bufio.NewScanner(strings.NewReader(input))

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		parts := strings.SplitN(line, ":", 2)
		if len(parts) != 2 {
			continue
		}

		from := strings.TrimSpace(parts[0])
		targetsPart := strings.TrimSpace(parts[1])

		var targets []string
		if targetsPart != "" {
			for _, t := range strings.Fields(targetsPart) {
				t = strings.TrimSpace(t)
				if t != "" {
					targets = append(targets, t)
				}
			}
		}

		graph[from] = targets
	}

	return graph
}

func countPaths(node, destination string, graph map[string][]string, memo map[string]int64) int64 {
	if node == destination {
		return 1
	}

	if v, ok := memo[node]; ok {
		return v
	}

	var total int64
	if children, ok := graph[node]; ok {
		for _, child := range children {
			total += countPaths(child, destination, graph, memo)
		}
	}

	memo[node] = total
	return total
}

func countPathsWithRequiredNodes(node, destination string, graph map[string][]string, memo map[string]int64, mask int) int64 {
	updatedMask := mask
	if node == "fft" {
		updatedMask |= 1
	} else if node == "dac" {
		updatedMask |= 2
	}

	if node == destination {
		if (updatedMask & 0b11) == 0b11 {
			return 1
		}
		return 0
	}

	key := fmt.Sprintf("%s|%d", node, updatedMask)
	if v, ok := memo[key]; ok {
		return v
	}

	var total int64
	if children, ok := graph[node]; ok {
		for _, child := range children {
			total += countPathsWithRequiredNodes(child, destination, graph, memo, updatedMask)
		}
	}

	memo[key] = total
	return total
}

func runExampleTest() {
	example := strings.TrimSpace(`
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
`)

	graph := parseGraph(example)
	memo := make(map[string]int64)
	paths := countPaths("you", "out", graph, memo)
	if paths != 5 {
		fmt.Fprintf(os.Stderr, "Example test failed: expected 5, got %d\n", paths)
	}
}

func main() {
	runExampleTest()

	example2 := strings.TrimSpace(`
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
`)
	graph2 := parseGraph(example2)
	memo2 := make(map[string]int64)
	paths2 := countPathsWithRequiredNodes("svr", "out", graph2, memo2, 0)
	if paths2 != 2 {
		fmt.Fprintf(os.Stderr, "Part 2 example test failed: expected 2, got %d\n", paths2)
	}

	data, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}
	input := strings.TrimSpace(string(data))

	graphReal := parseGraph(input)
	memoReal := make(map[string]int64)
	part1 := countPaths("you", "out", graphReal, memoReal)
	fmt.Printf("Day 11 Part 1: %d\n", part1)

	memoPart2 := make(map[string]int64)
	part2 := countPathsWithRequiredNodes("svr", "out", graphReal, memoPart2, 0)
	fmt.Printf("Day 11 Part 2: %d\n", part2)
}
