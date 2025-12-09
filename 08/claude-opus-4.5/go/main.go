package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

type Point struct {
	X, Y, Z int64
}

type Pair struct {
	DistSq int64
	I, J   int
}

var parent []int
var rank_ []int

func find(x int) int {
	if parent[x] != x {
		parent[x] = find(parent[x])
	}
	return parent[x]
}

func unite(x, y int) bool {
	px, py := find(x), find(y)
	if px == py {
		return false
	}
	if rank_[px] < rank_[py] {
		px, py = py, px
	}
	parent[py] = px
	if rank_[px] == rank_[py] {
		rank_[px]++
	}
	return true
}

func main() {
	data, _ := os.ReadFile("input.txt")
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")

	var points []Point
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.Split(line, ",")
		x, _ := strconv.ParseInt(parts[0], 10, 64)
		y, _ := strconv.ParseInt(parts[1], 10, 64)
		z, _ := strconv.ParseInt(parts[2], 10, 64)
		points = append(points, Point{x, y, z})
	}

	n := len(points)

	// Calculate all pairwise distances
	var pairs []Pair
	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ {
			dx := points[i].X - points[j].X
			dy := points[i].Y - points[j].Y
			dz := points[i].Z - points[j].Z
			distSq := dx*dx + dy*dy + dz*dz
			pairs = append(pairs, Pair{distSq, i, j})
		}
	}

	// Sort by distance
	sort.Slice(pairs, func(i, j int) bool {
		return pairs[i].DistSq < pairs[j].DistSq
	})

	// Union-Find initialization
	parent = make([]int, n)
	rank_ = make([]int, n)
	for i := 0; i < n; i++ {
		parent[i] = i
	}

	// Connect the 1000 shortest pairs for Part 1
	connections := 1000
	if len(pairs) < connections {
		connections = len(pairs)
	}
	for i := 0; i < connections; i++ {
		unite(pairs[i].I, pairs[i].J)
	}

	// Count circuit sizes
	circuitSizes := make(map[int]int)
	for i := 0; i < n; i++ {
		root := find(i)
		circuitSizes[root]++
	}

	// Get top 3 largest
	var sizes []int
	for _, size := range circuitSizes {
		sizes = append(sizes, size)
	}
	sort.Sort(sort.Reverse(sort.IntSlice(sizes)))

	top := 3
	if len(sizes) < top {
		top = len(sizes)
	}

	var part1 int64 = 1
	for i := 0; i < top; i++ {
		part1 *= int64(sizes[i])
	}

	fmt.Printf("Day 08 Part 1: %d\n", part1)

	// Part 2: Reset and find the last connection that unifies all into one circuit
	for i := 0; i < n; i++ {
		parent[i] = i
		rank_[i] = 0
	}

	numCircuits := n
	lastI, lastJ := -1, -1

	for i := 0; i < len(pairs) && numCircuits > 1; i++ {
		if unite(pairs[i].I, pairs[i].J) {
			numCircuits--
			lastI = pairs[i].I
			lastJ = pairs[i].J
		}
	}

	part2 := points[lastI].X * points[lastJ].X
	fmt.Printf("Day 08 Part 2: %d\n", part2)
}
