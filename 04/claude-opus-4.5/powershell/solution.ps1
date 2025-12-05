$lines = Get-Content "input.txt"
$grid = $lines | Where-Object { $_.Length -gt 0 }
$rows = $grid.Count
$cols = $grid[0].Length

# Part 1: Count rolls with fewer than 4 adjacent rolls
$part1 = 0
$dx = @(-1, -1, -1, 0, 0, 1, 1, 1)
$dy = @(-1, 0, 1, -1, 1, -1, 0, 1)

for ($r = 0; $r -lt $rows; $r++) {
    for ($c = 0; $c -lt $cols; $c++) {
        if ($grid[$r][$c] -ne '@') { continue }

        $adjacentRolls = 0
        for ($d = 0; $d -lt 8; $d++) {
            $nr = $r + $dx[$d]
            $nc = $c + $dy[$d]
            if ($nr -ge 0 -and $nr -lt $rows -and $nc -ge 0 -and $nc -lt $cols -and $grid[$nr][$nc] -eq '@') {
                $adjacentRolls++
            }
        }

        if ($adjacentRolls -lt 4) {
            $part1++
        }
    }
}

Write-Host "Day 04 Part 1: $part1"

# Part 2: Iteratively remove accessible rolls until none remain
$mutableGrid = @()
foreach ($row in $grid) {
    $mutableGrid += ,($row.ToCharArray())
}

$part2 = 0

while ($true) {
    $toRemove = @()

    for ($r = 0; $r -lt $rows; $r++) {
        for ($c = 0; $c -lt $cols; $c++) {
            if ($mutableGrid[$r][$c] -ne '@') { continue }

            $adjacentRolls = 0
            for ($d = 0; $d -lt 8; $d++) {
                $nr = $r + $dx[$d]
                $nc = $c + $dy[$d]
                if ($nr -ge 0 -and $nr -lt $rows -and $nc -ge 0 -and $nc -lt $cols -and $mutableGrid[$nr][$nc] -eq '@') {
                    $adjacentRolls++
                }
            }

            if ($adjacentRolls -lt 4) {
                $toRemove += ,@($r, $c)
            }
        }
    }

    if ($toRemove.Count -eq 0) { break }

    foreach ($pos in $toRemove) {
        $mutableGrid[$pos[0]][$pos[1]] = '.'
    }

    $part2 += $toRemove.Count
}

Write-Host "Day 04 Part 2: $part2"
