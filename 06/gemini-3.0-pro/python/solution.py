import sys
import re

def solve():
    try:
        with open("input.txt") as f:
            lines = f.read().splitlines()
    except FileNotFoundError:
        return

    if not lines:
        return

    width = max(len(line) for line in lines)
    padded_lines = [line.ljust(width) for line in lines]

    # Find empty columns
    empty_cols = []
    for x in range(width):
        is_empty = True
        for y in range(len(padded_lines)):
            if padded_lines[y][x] != ' ':
                is_empty = False
                break
        if is_empty:
            empty_cols.append(x)

    # Define blocks
    blocks = []
    start = 0
    for col in empty_cols:
        if col > start:
            blocks.append((start, col))
        start = col + 1
    if start < width:
        blocks.append((start, width))

    total_sum = 0

    for start_col, end_col in blocks:
        block_text = ""
        for line in padded_lines:
            block_text += line[start_col:end_col] + " "
        
        # Find numbers
        numbers = [int(n) for n in re.findall(r'\d+', block_text)]
        
        # Find operator
        op_match = re.search(r'[\+\*]', block_text)
        op = op_match.group(0) if op_match else '+' 
        
        if not numbers:
            continue

        if op == '+':
            res = sum(numbers)
        elif op == '*':
            res = 1
            for n in numbers:
                res *= n
        else:
            res = 0
        
        total_sum += res

    print(f"Day 06 Part 1: {total_sum}")

if __name__ == "__main__":
    solve()
