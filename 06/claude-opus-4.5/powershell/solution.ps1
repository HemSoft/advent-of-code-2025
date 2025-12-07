$lines = Get-Content "input.txt"

# Find the max width and pad all lines
$maxWidth = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
$grid = $lines | ForEach-Object { $_.PadRight($maxWidth) }
$rows = $grid.Count
$cols = $maxWidth

# The last row contains operators
$operatorRow = $grid[$rows - 1]

function IsSeparatorColumn($grid, $col, $dataRowCount) {
    for ($r = 0; $r -lt $dataRowCount; $r++) {
        if ($col -lt $grid[$r].Length -and $grid[$r][$col] -ne ' ') {
            return $false
        }
    }
    return $true
}

$problems = @()
$colStart = 0

while ($colStart -lt $cols) {
    # Skip separator columns
    while ($colStart -lt $cols -and (IsSeparatorColumn $grid $colStart ($rows - 1))) {
        $colStart++
    }

    if ($colStart -ge $cols) { break }

    # Find the end of this problem
    $colEnd = $colStart
    while ($colEnd -lt $cols -and -not (IsSeparatorColumn $grid $colEnd ($rows - 1))) {
        $colEnd++
    }

    # Extract numbers and operator
    $numbers = @()
    $op = ' '

    for ($r = 0; $r -lt $rows - 1; $r++) {
        $segment = $grid[$r].Substring($colStart, $colEnd - $colStart).Trim()
        if ($segment -ne '' -and $segment -match '^\d+$') {
            $numbers += [long]$segment
        }
    }

    # Get operator
    $opSegment = $operatorRow.Substring($colStart, $colEnd - $colStart).Trim()
    if ($opSegment.Length -gt 0) {
        $op = $opSegment[0]
    }

    if ($numbers.Count -gt 0 -and ($op -eq '+' -or $op -eq '*')) {
        $problems += ,@($numbers, $op)
    }

    $colStart = $colEnd
}

# Calculate grand total
[long]$part1 = 0
foreach ($problem in $problems) {
    $nums = $problem[0]
    $op = $problem[1]
    [long]$result = $nums[0]
    for ($i = 1; $i -lt $nums.Count; $i++) {
        if ($op -eq '+') {
            $result += $nums[$i]
        } else {
            $result *= $nums[$i]
        }
    }
    $part1 += $result
}

Write-Host "Day 06 Part 1: $part1"

# Part 2: Read columns right-to-left, digits top-to-bottom form numbers
[long]$part2 = 0
$colStart = 0

while ($colStart -lt $cols) {
    while ($colStart -lt $cols -and (IsSeparatorColumn $grid $colStart ($rows - 1))) {
        $colStart++
    }

    if ($colStart -ge $cols) { break }

    $colEnd = $colStart
    while ($colEnd -lt $cols -and -not (IsSeparatorColumn $grid $colEnd ($rows - 1))) {
        $colEnd++
    }

    # Get operator
    $opSegment = $operatorRow.Substring($colStart, $colEnd - $colStart).Trim()
    $op = if ($opSegment.Length -gt 0) { $opSegment[0] } else { ' ' }

    # Read columns right-to-left within this problem block
    $numbers2 = @()
    for ($c = $colEnd - 1; $c -ge $colStart; $c--) {
        $digits = @()
        for ($r = 0; $r -lt $rows - 1; $r++) {
            $ch = $grid[$r][$c]
            if ($ch -match '\d') {
                $digits += $ch
            }
        }
        if ($digits.Count -gt 0) {
            $numbers2 += [long]($digits -join '')
        }
    }

    if ($numbers2.Count -gt 0 -and ($op -eq '+' -or $op -eq '*')) {
        [long]$result = $numbers2[0]
        for ($i = 1; $i -lt $numbers2.Count; $i++) {
            if ($op -eq '+') {
                $result += $numbers2[$i]
            } else {
                $result *= $numbers2[$i]
            }
        }
        $part2 += $result
    }

    $colStart = $colEnd
}

Write-Host "Day 06 Part 2: $part2"
