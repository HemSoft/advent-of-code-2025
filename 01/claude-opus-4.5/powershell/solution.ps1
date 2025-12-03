$lines = Get-Content "input.txt" | Where-Object { $_.Trim() -ne "" }

$position = 50
$zeroCountPart1 = 0
$zeroCountPart2 = 0

foreach ($line in $lines) {
    $direction = $line[0]
    $distance = [int]$line.Substring(1)

    if ($direction -eq 'L') {
        $newPosition = (($position - $distance) % 100 + 100) % 100
        $firstHit = if ($position -eq 0) { 100 } else { $position }
    } else {
        $newPosition = ($position + $distance) % 100
        $firstHit = if ($position -eq 0) { 100 } else { 100 - $position }
    }

    if ($newPosition -eq 0) {
        $zeroCountPart1++
    }

    if ($firstHit -le $distance) {
        $zeroCountPart2 += 1 + [Math]::Floor(($distance - $firstHit) / 100)
    }

    $position = $newPosition
}

Write-Host "Day 01 Part 1: $zeroCountPart1"
Write-Host "Day 01 Part 2: $zeroCountPart2"
