package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

type Range struct {
	Start int64
	End   int64
}

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))
	input = strings.ReplaceAll(input, "\r\n", "\n")
	parts := strings.Split(input, "\n\n")

	rangesLines := strings.Split(parts[0], "\n")
	idsLines := strings.Split(parts[1], "\n")

	var ranges []Range
	for _, line := range rangesLines {
		if line == "" {
			continue
		}
		split := strings.Split(line, "-")
		start, _ := strconv.ParseInt(split[0], 10, 64)
		end, _ := strconv.ParseInt(split[1], 10, 64)
		ranges = append(ranges, Range{Start: start, End: end})
	}

	var part1 int64 = 0
	for _, line := range idsLines {
		if line == "" {
			continue
		}
		id, _ := strconv.ParseInt(line, 10, 64)
		isFresh := false
		for _, r := range ranges {
			if id >= r.Start && id <= r.End {
				isFresh = true
				break
			}
		}
		if isFresh {
			part1++
		}
	}

	fmt.Printf("Day 05 Part 1: %d\n", part1)

	// Part 2
	sort.Slice(ranges, func(i, j int) bool {
		return ranges[i].Start < ranges[j].Start
	})

	var mergedRanges []Range
	if len(ranges) > 0 {
		currStart := ranges[0].Start
		currEnd := ranges[0].End

		for i := 1; i < len(ranges); i++ {
			nextStart := ranges[i].Start
			nextEnd := ranges[i].End

			if nextStart <= currEnd+1 {
				if nextEnd > currEnd {
					currEnd = nextEnd
				}
			} else {
				mergedRanges = append(mergedRanges, Range{Start: currStart, End: currEnd})
				currStart = nextStart
				currEnd = nextEnd
			}
		}
		mergedRanges = append(mergedRanges, Range{Start: currStart, End: currEnd})
	}

	var part2 int64 = 0
	for _, r := range mergedRanges {
		part2 += (r.End - r.Start + 1)
	}

	fmt.Printf("Day 05 Part 2: %d\n", part2)
}
