package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

type Range struct {
	start, end int64
}

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))
	input = strings.ReplaceAll(input, "\r\n", "\n")
	sections := strings.Split(input, "\n\n")

	var ranges []Range
	for _, line := range strings.Split(sections[0], "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.Split(line, "-")
		start, _ := strconv.ParseInt(parts[0], 10, 64)
		end, _ := strconv.ParseInt(parts[1], 10, 64)
		ranges = append(ranges, Range{start, end})
	}

	var ingredients []int64
	for _, line := range strings.Split(sections[1], "\n") {
		line = strings.TrimSpace(line)
		if line != "" {
			id, _ := strconv.ParseInt(line, 10, 64)
			ingredients = append(ingredients, id)
		}
	}

	// Part 1
	var part1 int64 = 0
	for _, id := range ingredients {
		for _, r := range ranges {
			if id >= r.start && id <= r.end {
				part1++
				break
			}
		}
	}
	fmt.Printf("Day 05 Part 1: %d\n", part1)

	// Part 2: Merge overlapping ranges and count total unique IDs
	sort.Slice(ranges, func(i, j int) bool {
		if ranges[i].start != ranges[j].start {
			return ranges[i].start < ranges[j].start
		}
		return ranges[i].end < ranges[j].end
	})

	var merged []Range
	for _, r := range ranges {
		if len(merged) == 0 || merged[len(merged)-1].end < r.start-1 {
			merged = append(merged, r)
		} else {
			if r.end > merged[len(merged)-1].end {
				merged[len(merged)-1].end = r.end
			}
		}
	}

	var part2 int64 = 0
	for _, r := range merged {
		part2 += r.end - r.start + 1
	}
	fmt.Printf("Day 05 Part 2: %d\n", part2)
}
