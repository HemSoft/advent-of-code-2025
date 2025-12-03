package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strings"
)

func main() {
	data, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}
	input := strings.TrimSpace(string(data))

	part1 := sumInvalidIDs(input)
	fmt.Printf("Day 02 Part 1: %d\n", part1)
	part2 := sumInvalidIDsPart2(input)
	fmt.Printf("Day 02 Part 2: %d\n", part2)
}

func sumInvalidIDs(input string) int64 {
	sum := int64(0)
	ranges := strings.Split(input, ",")
	for _, r := range ranges {
		r = strings.TrimSpace(r)
		if r == "" {
			continue
		}
		parts := strings.Split(r, "-")
		if len(parts) != 2 {
			continue
		}
		start, err1 := parseInt64(strings.TrimSpace(parts[0]))
		end, err2 := parseInt64(strings.TrimSpace(parts[1]))
		if err1 != nil || err2 != nil {
			continue
		}
		if end < start {
			start, end = end, start
		}

		minLen := digitsCount(start)
		maxLen := digitsCount(end)
		for l := minLen; l <= maxLen; l++ {
			if l%2 != 0 {
				continue
			}
			half := l / 2
			pow10 := pow10Int64(half)
			first := pow10Int64(l - 1)
			last := pow10Int64(l) - 1

			low := maxInt64(start, first)
			high := minInt64(end, last)
			if low > high {
				continue
			}

			den := float64(pow10 + 1)
			aStart := int64(math.Ceil(float64(low) / den))
			aEnd := int64(math.Floor(float64(high) / den))
			if aStart > aEnd {
				continue
			}

			count := aEnd - aStart + 1
			termsSum := (aStart + aEnd) * count / 2
			contrib := termsSum * (pow10 + 1)
			sum += contrib
		}
	}
	return sum
}

func sumInvalidIDsPart2(input string) int64 {
	sum := int64(0)
	ranges := strings.Split(input, ",")
	for _, r := range ranges {
		r = strings.TrimSpace(r)
		if r == "" {
			continue
		}
		parts := strings.Split(r, "-")
		if len(parts) != 2 {
			continue
		}
		start, err1 := parseInt64(strings.TrimSpace(parts[0]))
		end, err2 := parseInt64(strings.TrimSpace(parts[1]))
		if err1 != nil || err2 != nil {
			continue
		}
		if end < start {
			start, end = end, start
		}

		minLen := digitsCount(start)
		maxLen := digitsCount(end)
		for l := minLen; l <= maxLen; l++ {
			for k := 2; k*k <= l; k++ {
				if l%k != 0 {
					continue
				}
				baseLen := l / k
				pow10Base := pow10Int64(baseLen)
				first := pow10Int64(l - 1)
				last := pow10Int64(l) - 1

				low := maxInt64(start, first)
				high := minInt64(end, last)
				if low > high {
					continue
				}

				// geometric series factor: 1 + 10^{baseLen} + ...
				geom := int64(0)
				factor := int64(1)
				for i := 0; i < k; i++ {
					geom += factor
					factor *= pow10Base
				}

				aStart := int64(math.Ceil(float64(low) / float64(geom)))
				aEnd := int64(math.Floor(float64(high) / float64(geom)))
				if aStart > aEnd {
					continue
				}

				count := aEnd - aStart + 1
				termsSum := (aStart + aEnd) * count / 2
				contrib := termsSum * geom
				sum += contrib
			}
		}
	}
	return sum
}

func parseInt64(s string) (int64, error) {
	reader := strings.NewReader(s)
	scanner := bufio.NewScanner(reader)
	scanner.Split(bufio.ScanWords)
	if scanner.Scan() {
		var v int64
		_, err := fmt.Sscan(scanner.Text(), &v)
		return v, err
	}
	return 0, fmt.Errorf("invalid int64")
}

func digitsCount(n int64) int {
	if n < 0 {
		n = -n
	}
	count := 1
	for n >= 10 {
		n /= 10
		count++
	}
	return count
}

func pow10Int64(exp int) int64 {
	res := int64(1)
	for i := 0; i < exp; i++ {
		res *= 10
	}
	return res
}

func maxInt64(a, b int64) int64 {
	if a > b {
		return a
	}
	return b
}

func minInt64(a, b int64) int64 {
	if a < b {
		return a
	}
	return b
}
