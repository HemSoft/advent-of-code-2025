package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"sort"
	"strconv"
	"strings"
)

type Point struct {
	x, y, z int
}

type Pair struct {
	dist float64
	i, j int
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	var points []Point
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		parts := strings.Split(line, ",")
		if len(parts) == 3 {
			x, _ := strconv.Atoi(parts[0])
			y, _ := strconv.Atoi(parts[1])
			z, _ := strconv.Atoi(parts[2])
			points = append(points, Point{x, y, z})
		}
	}

	var pairs []Pair
	for i := 0; i < len(points); i++ {
		for j := i + 1; j < len(points); j++ {
			p1 := points[i]
			p2 := points[j]
			distSq := float64((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y) + (p1.z-p2.z)*(p1.z-p2.z))
			dist := math.Sqrt(distSq)
			pairs = append(pairs, Pair{dist, i, j})
		}
	}

	sort.Slice(pairs, func(i, j int) bool {
		return pairs[i].dist < pairs[j].dist
	})

	parent := make([]int, len(points))
	for i := range parent {
		parent[i] = i
	}

	var find func(int) int
	find = func(i int) int {
		if parent[i] == i {
			return i
		}
		parent[i] = find(parent[i])
		return parent[i]
	}

	union := func(i, j int) {
		rootI := find(i)
		rootJ := find(j)
		if rootI != rootJ {
			parent[rootI] = rootJ
		}
	}

	limit := 1000
	if len(pairs) < limit {
		limit = len(pairs)
	}

	for k := 0; k < limit; k++ {
		union(pairs[k].i, pairs[k].j)
	}

	counts := make(map[int]int)
	for i := range points {
		root := find(i)
		counts[root]++
	}

	var sizes []int
	for _, count := range counts {
		sizes = append(sizes, count)
	}

	sort.Sort(sort.Reverse(sort.IntSlice(sizes)))

	var result int64 = 0
	if len(sizes) >= 3 {
		result = int64(sizes[0]) * int64(sizes[1]) * int64(sizes[2])
	} else if len(sizes) > 0 {
		result = 1
		for _, s := range sizes {
			result *= int64(s)
		}
	}

	fmt.Printf("Day 08 Part 1: %d\n", result)

	// Part 2
	for i := range parent {
		parent[i] = i
	}
	numComponents := len(points)
	var part2Result int64 = 0

	for _, pair := range pairs {
		rootI := find(pair.i)
		rootJ := find(pair.j)
		if rootI != rootJ {
			parent[rootI] = rootJ
			numComponents--
			if numComponents == 1 {
				part2Result = int64(points[pair.i].x) * int64(points[pair.j].x)
				break
			}
		}
	}

	fmt.Printf("Day 08 Part 2: %d\n", part2Result)
}