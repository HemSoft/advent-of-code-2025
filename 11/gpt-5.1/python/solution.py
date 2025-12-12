from __future__ import annotations

from collections import defaultdict
from typing import Dict, List


def parse_graph(text: str) -> Dict[str, List[str]]:
    graph: Dict[str, List[str]] = {}
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue

        parts = line.split(":", 1)
        if len(parts) != 2:
            continue

        src = parts[0].strip()
        targets_part = parts[1].strip()

        targets: List[str] = []
        if targets_part:
            for t in targets_part.split():
                tt = t.strip()
                if tt:
                    targets.append(tt)

        graph[src] = targets

    return graph


def count_paths(node: str, destination: str, graph: Dict[str, List[str]], memo: Dict[str, int]) -> int:
    if node == destination:
        return 1

    if node in memo:
        return memo[node]

    total = 0
    for child in graph.get(node, []):
        total += count_paths(child, destination, graph, memo)

    memo[node] = total
    return total


def count_paths_with_required_nodes(
    node: str,
    destination: str,
    graph: Dict[str, List[str]],
    memo: Dict[tuple[str, int], int],
    mask: int,
) -> int:
    updated_mask = mask
    if node == "fft":
        updated_mask |= 1
    elif node == "dac":
        updated_mask |= 2

    if node == destination:
        return 1 if (updated_mask & 0b11) == 0b11 else 0

    key = (node, updated_mask)
    if key in memo:
        return memo[key]

    total = 0
    for child in graph.get(node, []):
        total += count_paths_with_required_nodes(child, destination, graph, memo, updated_mask)

    memo[key] = total
    return total


def run_example_test() -> None:
    example = """
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
""".strip()

    graph = parse_graph(example)
    memo: Dict[str, int] = {}
    paths = count_paths("you", "out", graph, memo)

    if paths != 5:
        print(f"Example test failed: expected 5, got {paths}", flush=True)


def run_part2_example_test() -> None:
    example = """
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
""".strip()

    graph = parse_graph(example)
    memo: Dict[tuple[str, int], int] = {}
    paths = count_paths_with_required_nodes("svr", "out", graph, memo, 0)

    if paths != 2:
        print(f"Part 2 example test failed: expected 2, got {paths}", flush=True)


def main() -> None:
    run_example_test()
    run_part2_example_test()

    with open("input.txt", "r", encoding="utf-8") as f:
        input_data = f.read().strip()

    graph_real = parse_graph(input_data)
    memo_real: Dict[str, int] = {}
    part1 = count_paths("you", "out", graph_real, memo_real)
    print(f"Day 11 Part 1: {part1}")

    memo_part2: Dict[tuple[str, int], int] = {}
    part2 = count_paths_with_required_nodes("svr", "out", graph_real, memo_part2, 0)
    print(f"Day 11 Part 2: {part2}")


if __name__ == "__main__":
    main()
