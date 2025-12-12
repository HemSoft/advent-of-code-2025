package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func parseInput(path string) (map[int]int, []string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, nil, err
	}
	defer file.Close()

	shapeSizes := make(map[int]int)
	var regionLines []string
	currentShapeId := -1
	currentShapeCount := 0

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimRight(scanner.Text(), "\r")
		if strings.TrimSpace(line) == "" {
			continue
		}

		if len(line) > 0 && line[0] >= '0' && line[0] <= '9' && strings.Contains(line, ":") && !strings.Contains(line, "x") {
			if currentShapeId >= 0 {
				shapeSizes[currentShapeId] = currentShapeCount
			}
			idPart := strings.SplitN(line, ":", 2)[0]
			idVal, err := strconv.Atoi(idPart)
			if err != nil {
				return nil, nil, err
			}
			currentShapeId = idVal
			currentShapeCount = 0
		} else if strings.Contains(line, "x") && strings.Contains(line, ":") {
			if currentShapeId >= 0 {
				shapeSizes[currentShapeId] = currentShapeCount
				currentShapeId = -1
				currentShapeCount = 0
			}
			regionLines = append(regionLines, strings.TrimSpace(line))
		} else if currentShapeId >= 0 && (strings.Contains(line, "#") || strings.Contains(line, ".")) {
			currentShapeCount += strings.Count(line, "#")
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, nil, err
	}

	if currentShapeId >= 0 {
		shapeSizes[currentShapeId] = currentShapeCount
	}

	return shapeSizes, regionLines, nil
}

func solvePart1(path string) (int, error) {
	shapeSizes, regionLines, err := parseInput(path)
	if err != nil {
		return 0, err
	}

	countFit := 0
	for _, regionLine := range regionLines {
		parts := strings.SplitN(regionLine, ":", 2)
		if len(parts) != 2 {
			continue
		}
		sizePart := strings.TrimSpace(parts[0])
		countsPart := strings.TrimSpace(parts[1])

		sz := strings.Split(sizePart, "x")
		if len(sz) != 2 {
			continue
		}
		w, _ := strconv.Atoi(sz[0])
		h, _ := strconv.Atoi(sz[1])

		countStrs := strings.Fields(countsPart)
		totalCells := 0
		for i, s := range countStrs {
			c, _ := strconv.Atoi(s)
			if c == 0 {
				continue
			}
			if size, ok := shapeSizes[i]; ok {
				totalCells += c * size
			}
		}

		gridArea := w * h
		if totalCells <= gridArea {
			countFit++
		}
	}

	return countFit, nil
}

func main() {
	part1, err := solvePart1("input.txt")
	if err != nil {
		panic(err)
	}

	fmt.Printf("Day 12 Part 1: %d\n", part1)

	// Part 2 placeholder
	var part2 int64 = 0
	fmt.Printf("Day 12 Part 2: %d\n", part2)
}
