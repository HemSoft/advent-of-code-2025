import sys
from functools import lru_cache

# Increase recursion depth for deep graphs
sys.setrecursionlimit(20000)

def solve():
    try:
        with open("input.txt", "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print("Error: input.txt not found.")
        return

    graph = {}
    for line in lines:
        line = line.strip()
        if not line:
            continue
        source, targets_str = line.split(": ")
        targets = targets_str.split(" ")
        graph[source] = targets

    # Part 1
    @lru_cache(None)
    def count_paths_p1(current):
        if current == "out":
            return 1

        if current not in graph:
            return 0

        total = 0
        for neighbor in graph[current]:
            total += count_paths_p1(neighbor)
        return total

    paths_p1 = count_paths_p1("you")
    print(f"Day 11 Part 1: {paths_p1}")

    # Part 2
    @lru_cache(None)
    def count_paths_p2(current, visited_mask):
        # Mask: 1 = dac, 2 = fft
        if current == "dac":
            visited_mask |= 1
        elif current == "fft":
            visited_mask |= 2

        if current == "out":
            return 1 if visited_mask == 3 else 0

        if current not in graph:
            return 0

        total = 0
        for neighbor in graph[current]:
            total += count_paths_p2(neighbor, visited_mask)
        return total

    paths_p2 = count_paths_p2("svr", 0)
    print(f"Day 11 Part 2: {paths_p2}")

if __name__ == "__main__":
    solve()
