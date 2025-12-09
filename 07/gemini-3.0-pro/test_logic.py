
def solve():
    grid = [
        ".......S.......",
        "...............",
        ".......^.......",
        "...............",
        "......^.^......",
        "...............",
        ".....^.^.^.....",
        "...............",
        "....^.^...^....",
        "...............",
        "...^.^...^.^...",
        "...............",
        "..^...^.....^..",
        "...............",
        ".^.^.^.^.^...^.",
        "..............."
    ]

    rows = len(grid)
    cols = len(grid[0])
    
    start_pos = None
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == 'S':
                start_pos = (r, c)
                break
        if start_pos: break
        
    if not start_pos:
        print("No start found")
        return

    current_beams = {start_pos}
    split_count = 0
    
    # We need to be careful. The loop should continue as long as there are beams.
    # But beams move down. Eventually they exit.
    
    while current_beams:
        next_beams = set()
        for r, c in current_beams:
            next_r = r + 1
            next_c = c
            
            if next_r >= rows:
                continue
            
            cell = grid[next_r][next_c]
            
            if cell == '^':
                split_count += 1
                # New beams at left and right of the splitter
                # The splitter is at (next_r, next_c)
                # New beams start at (next_r, next_c - 1) and (next_r, next_c + 1)
                
                # Check bounds for new beams?
                # "exit the manifold"
                if 0 <= next_c - 1 < cols:
                    next_beams.add((next_r, next_c - 1))
                if 0 <= next_c + 1 < cols:
                    next_beams.add((next_r, next_c + 1))
            else:
                # Continue straight
                next_beams.add((next_r, next_c))
        
        current_beams = next_beams
        
    print(f"Splits: {split_count}")

solve()
