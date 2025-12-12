package main

import (
"bufio"
"fmt"
"os"
"strconv"
"strings"
)

func main() {
file, _ := os.Open("input.txt")
defer file.Close()

scanner := bufio.NewScanner(file)
shapes := make(map[int]int) // shapeId -> cellCount
var regionLines []string
currentShapeId := -1
currentCellCount := 0

for scanner.Scan() {
line := strings.TrimRight(scanner.Text(), "\r")
if len(strings.TrimSpace(line)) == 0 {
continue
}

// Check if this is a shape definition
if len(line) > 0 && line[0] >= '0' && line[0] <= '9' && strings.Contains(line, ":") && !strings.Contains(line, "x") {
if currentShapeId >= 0 {
shapes[currentShapeId] = currentCellCount
}
parts := strings.Split(line, ":")
currentShapeId, _ = strconv.Atoi(parts[0])
currentCellCount = 0
} else if strings.Contains(line, "x") && strings.Contains(line, ":") {
if currentShapeId >= 0 {
shapes[currentShapeId] = currentCellCount
currentShapeId = -1
currentCellCount = 0
}
regionLines = append(regionLines, line)
} else if currentShapeId >= 0 && (strings.Contains(line, "#") || strings.Contains(line, ".")) {
currentCellCount += strings.Count(line, "#")
}
}

if currentShapeId >= 0 {
shapes[currentShapeId] = currentCellCount
}

part1 := 0

for _, regionLine := range regionLines {
colonIdx := strings.Index(regionLine, ":")
sizePart := regionLine[:colonIdx]
countsPart := strings.TrimSpace(regionLine[colonIdx+1:])

sizeParts := strings.Split(sizePart, "x")
width, _ := strconv.Atoi(sizeParts[0])
height, _ := strconv.Atoi(sizeParts[1])

countsStrs := strings.Fields(countsPart)
totalCellsNeeded := 0
for i, cs := range countsStrs {
count, _ := strconv.Atoi(cs)
totalCellsNeeded += count * shapes[i]
}

gridArea := width * height
if totalCellsNeeded <= gridArea {
part1++
}
}

fmt.Printf("Day 12 Part 1: %d\n", part1)
fmt.Printf("Day 12 Part 2: %d\n", 0)
}
