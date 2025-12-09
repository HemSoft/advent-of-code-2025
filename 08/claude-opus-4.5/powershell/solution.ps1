$lines = Get-Content "input.txt" | Where-Object { $_.Trim() -ne "" }

$points = @()
foreach ($line in $lines) {
    $parts = $line.Split(',')
    $points += ,@([long]$parts[0], [long]$parts[1], [long]$parts[2])
}

$n = $points.Count

# Calculate all pairwise distances
$pairs = [System.Collections.ArrayList]::new()
for ($i = 0; $i -lt $n; $i++) {
    for ($j = $i + 1; $j -lt $n; $j++) {
        $dx = $points[$i][0] - $points[$j][0]
        $dy = $points[$i][1] - $points[$j][1]
        $dz = $points[$i][2] - $points[$j][2]
        $distSq = $dx * $dx + $dy * $dy + $dz * $dz
        [void]$pairs.Add(@{ DistSq = $distSq; I = $i; J = $j })
    }
}

# Sort by distance
$pairs = $pairs | Sort-Object { $_.DistSq }

# Union-Find
$parent = @(0..($n - 1))
$rank = @(0) * $n

function Find-Root($x) {
    if ($script:parent[$x] -ne $x) {
        $script:parent[$x] = Find-Root $script:parent[$x]
    }
    return $script:parent[$x]
}

function Unite($x, $y) {
    $px = Find-Root $x
    $py = Find-Root $y
    if ($px -eq $py) { return $false }
    if ($script:rank[$px] -lt $script:rank[$py]) {
        $temp = $px; $px = $py; $py = $temp
    }
    $script:parent[$py] = $px
    if ($script:rank[$px] -eq $script:rank[$py]) {
        $script:rank[$px]++
    }
    return $true
}

# Connect the 1000 shortest pairs for Part 1
$connections = [Math]::Min(1000, $pairs.Count)
for ($i = 0; $i -lt $connections; $i++) {
    [void](Unite $pairs[$i].I $pairs[$i].J)
}

# Count circuit sizes
$circuitSizes = @{}
for ($i = 0; $i -lt $n; $i++) {
    $root = Find-Root $i
    if (-not $circuitSizes.ContainsKey($root)) {
        $circuitSizes[$root] = 0
    }
    $circuitSizes[$root]++
}

# Get top 3 largest
$sizes = $circuitSizes.Values | Sort-Object -Descending | Select-Object -First 3
$part1 = [long]1
foreach ($size in $sizes) {
    $part1 *= $size
}

Write-Host "Day 08 Part 1: $part1"

# Part 2: Reset and find the last connection that unifies all into one circuit
$parent = @(0..($n - 1))
$rank = @(0) * $n

$numCircuits = $n
$lastI = -1
$lastJ = -1

foreach ($pair in $pairs) {
    if ($numCircuits -le 1) { break }
    $united = Unite $pair.I $pair.J
    if ($united) {
        $numCircuits--
        $lastI = $pair.I
        $lastJ = $pair.J
    }
}

$part2 = [long]$points[$lastI][0] * [long]$points[$lastJ][0]
Write-Host "Day 08 Part 2: $part2"
