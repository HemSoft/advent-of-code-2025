package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
)

type interval struct {
	start int64
	end   int64
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	ranges := make([]interval, 0)
	available := make([]int64, 0)

	parsingRanges := true
	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			parsingRanges = false
			continue
		}

		if parsingRanges {
			var s, e int64
			_, err := fmt.Sscanf(line, "%d-%d", &s, &e)
			if err == nil {
				if e < s {
					s, e = e, s
				}
				ranges = append(ranges, interval{start: s, end: e})
			}
		} else {
			var id int64
			_, err := fmt.Sscanf(line, "%d", &id)
			if err == nil {
				available = append(available, id)
			}
		}
	}

	// Merge overlapping/adjacent ranges
	sort.Slice(ranges, func(i, j int) bool {
		if ranges[i].start == ranges[j].start {
			return ranges[i].end < ranges[j].end
		}
		return ranges[i].start < ranges[j].start
	})

	merged := make([]interval, 0, len(ranges))
	for _, r := range ranges {
		if len(merged) == 0 {
			merged = append(merged, r)
			continue
		}
		last := &merged[len(merged)-1]
		if r.start <= last.end+1 {
			if r.end > last.end {
				last.end = r.end
			}
		} else {
			merged = append(merged, r)
		}
	}

	// Part 1: count available IDs that fall within any merged range
	var part1 int64
	for _, id := range available {
		for _, r := range merged {
			if id < r.start {
				break
			}
			if id <= r.end {
				part1++
				break
			}
		}
	}
	fmt.Printf("Day 05 Part 1: %d\n", part1)

	// Part 2: count all unique IDs covered by any merged range
	var part2 int64
	for _, r := range merged {
		part2 += (r.end - r.start + 1)
	}
	fmt.Printf("Day 05 Part 2: %d\n", part2)
}