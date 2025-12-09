$lines = Get-Content "input.txt"
$rows = $lines.Count
$cols = if ($rows -gt 0) { $lines[0].Length } else { 0 }

# Find starting position S
$startRow = 0
$startCol = 0
for ($r = 0; $r -lt $rows; $r++) {
    $c = $lines[$r].IndexOf('S')
    if ($c -ne -1) {
        $startRow = $r
        $startCol = $c
        break
    }
}

# Part 1: Count total splits
$splitCount = 0
$currentBeams = @{ $startCol = $true }

for ($row = $startRow + 1; $row -lt $rows -and $currentBeams.Count -gt 0; $row++) {
    $nextBeams = @{}
    foreach ($col in $currentBeams.Keys) {
        if ($col -lt 0 -or $col -ge $cols) { continue }
        $cell = $lines[$row][$col]
        if ($cell -eq '^') {
            $splitCount++
            if ($col - 1 -ge 0) { $nextBeams[$col - 1] = $true }
            if ($col + 1 -lt $cols) { $nextBeams[$col + 1] = $true }
        } else {
            $nextBeams[$col] = $true
        }
    }
    $currentBeams = $nextBeams
}

Write-Host "Day 07 Part 1: $splitCount"

# Part 2: Count timelines (each particle takes both paths at each splitter)
$particleCounts = @{ $startCol = [long]1 }

for ($row = $startRow + 1; $row -lt $rows -and $particleCounts.Count -gt 0; $row++) {
    $nextCounts = @{}
    foreach ($col in @($particleCounts.Keys)) {
        if ($col -lt 0 -or $col -ge $cols) { continue }
        $cell = $lines[$row][$col]
        $count = $particleCounts[$col]
        if ($cell -eq '^') {
            if ($col - 1 -ge 0) {
                if (-not $nextCounts.ContainsKey($col - 1)) { $nextCounts[$col - 1] = [long]0 }
                $nextCounts[$col - 1] += $count
            }
            if ($col + 1 -lt $cols) {
                if (-not $nextCounts.ContainsKey($col + 1)) { $nextCounts[$col + 1] = [long]0 }
                $nextCounts[$col + 1] += $count
            }
        } else {
            if (-not $nextCounts.ContainsKey($col)) { $nextCounts[$col] = [long]0 }
            $nextCounts[$col] += $count
        }
    }
    $particleCounts = $nextCounts
}

$part2 = [long]0
foreach ($count in $particleCounts.Values) {
    $part2 += $count
}
Write-Host "Day 07 Part 2: $part2"
