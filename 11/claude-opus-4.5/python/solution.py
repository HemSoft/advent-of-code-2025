import sys
from functools import lru_cache
sys.setrecursionlimit(10000)

with open("input.txt") as f:
    lines = f.read().strip().split('\n')

graph = {}
for line in lines:
    if not line.strip():
        continue
    parts = line.split(':')
    source = parts[0].strip()
    destinations = tuple(parts[1].strip().split())
    graph[source] = destinations

@lru_cache(maxsize=None)
def count_paths(current, target):
    if current == target:
        return 1

    if current not in graph:
        return 0

    count = 0
    for neighbor in graph[current]:
        count += count_paths(neighbor, target)
    return count

@lru_cache(maxsize=None)
def count_paths_with_required(current, target, visited_dac, visited_fft):
    if current == "dac":
        visited_dac = True
    if current == "fft":
        visited_fft = True

    if current == target:
        return 1 if visited_dac and visited_fft else 0

    if current not in graph:
        return 0

    count = 0
    for neighbor in graph[current]:
        count += count_paths_with_required(neighbor, target, visited_dac, visited_fft)
    return count

# Part 1
part1 = count_paths("you", "out")
print(f"Day 11 Part 1: {part1}")

# Part 2
part2 = count_paths_with_required("svr", "out", False, False)
print(f"Day 11 Part 2: {part2}")
