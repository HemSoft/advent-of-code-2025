from __future__ import annotations

from dataclasses import dataclass


@dataclass
class Interval:
    start: int
    end: int


with open("input.txt", encoding="utf-8") as f:
    lines = [line.strip() for line in f.read().splitlines() if line.strip()]

ranges: list[Interval] = []
available_ids: list[int] = []

index = 0
while index < len(lines) and "-" in lines[index]:
    line = lines[index]
    left, right = (part.strip() for part in line.split("-", 1))
    start = int(left)
    end = int(right)
    if end < start:
        start, end = end, start
    ranges.append(Interval(start, end))
    index += 1

while index < len(lines):
    line = lines[index]
    if line:
        available_ids.append(int(line))
    index += 1

ranges.sort(key=lambda r: (r.start, r.end))

merged: list[Interval] = []
for r in ranges:
    if not merged:
        merged.append(Interval(r.start, r.end))
        continue
    last = merged[-1]
    if r.start <= last.end + 1:
        if r.end > last.end:
            last.end = r.end
    else:
        merged.append(Interval(r.start, r.end))

part1 = 0
for value in available_ids:
    for rng in merged:
        if value < rng.start:
            break
        if value <= rng.end:
            part1 += 1
            break

print(f"Day 05 Part 1: {part1}")

part2 = 0
for rng in merged:
    part2 += rng.end - rng.start + 1

print(f"Day 05 Part 2: {part2}")