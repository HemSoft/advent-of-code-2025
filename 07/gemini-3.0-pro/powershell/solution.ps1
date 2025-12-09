$content = Get-Content -Path "input.txt" -ErrorAction SilentlyContinue
if (-not $content) {
    Write-Host "Error reading input.txt"
    exit
}

$lines = $content
$width = $lines[0].Length
$height = $lines.Count

$startCol = -1
$startRow = -1

for ($r = 0; $r -lt $height; $r++) {
    $idx = $lines[$r].IndexOf('S')
    if ($idx -ne -1) {
        $startCol = $idx
        $startRow = $r
        break
    }
}

if ($startCol -eq -1) {
    Write-Host "Start not found"
    exit
}

$activeBeams = [System.Collections.Generic.HashSet[int]]::new()
$null = $activeBeams.Add($startCol)
$totalSplits = 0

for ($r = $startRow + 1; $r -lt $height; $r++) {
    $nextBeams = [System.Collections.Generic.HashSet[int]]::new()
    $line = $lines[$r]

    foreach ($c in $activeBeams) {
        if ($c -lt 0 -or $c -ge $width) { continue }

        $char = $line[$c]
        if ($char -eq '^') {
            $totalSplits++
            if ($c - 1 -ge 0) { $null = $nextBeams.Add($c - 1) }
            if ($c + 1 -lt $width) { $null = $nextBeams.Add($c + 1) }
        } else {
            $null = $nextBeams.Add($c)
        }
    }
    $activeBeams = $nextBeams
    if ($activeBeams.Count -eq 0) { break }
}

Write-Host "Day 07 Part 1: $totalSplits"

# Part 2
$memo = @{}

function Count-Paths {
    param (
        [int]$r,
        [int]$c
    )

    if ($c -lt 0 -or $c -ge $width) { return 1 }

    $key = "$r,$c"
    if ($memo.ContainsKey($key)) { return $memo[$key] }

    for ($currR = $r + 1; $currR -lt $height; $currR++) {
        if ($lines[$currR][$c] -eq '^') {
            $res = (Count-Paths -r $currR -c ($c - 1)) + (Count-Paths -r $currR -c ($c + 1))
            $memo[$key] = $res
            return $res
        }
    }

    $memo[$key] = 1
    return 1
}

$part2Ans = Count-Paths -r $startRow -c $startCol
Write-Host "Day 07 Part 2: $part2Ans"
