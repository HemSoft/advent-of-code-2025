$inputData = Get-Content "input.txt" -Raw
$inputData = $inputData -replace "`r`n", "`n"
$sections = $inputData.Trim() -split "`n`n"

$ranges = @()
foreach ($line in ($sections[0] -split "`n")) {
    $line = $line.Trim()
    if ($line -ne "") {
        $parts = $line -split "-"
        $ranges += @{ Start = [long]$parts[0]; End = [long]$parts[1] }
    }
}

$ingredients = @()
foreach ($line in ($sections[1] -split "`n")) {
    $line = $line.Trim()
    if ($line -ne "") {
        $ingredients += [long]$line
    }
}

# Part 1
$part1 = 0
foreach ($id in $ingredients) {
    foreach ($range in $ranges) {
        if ($id -ge $range.Start -and $id -le $range.End) {
            $part1++
            break
        }
    }
}
Write-Host "Day 05 Part 1: $part1"

# Part 2: Merge overlapping ranges and count total unique IDs
$sorted = $ranges | Sort-Object { $_.Start }, { $_.End }
$merged = @()

foreach ($range in $sorted) {
    if ($merged.Count -eq 0 -or $merged[-1].End -lt ($range.Start - 1)) {
        $merged += @{ Start = $range.Start; End = $range.End }
    } else {
        $last = $merged[-1]
        $last.End = [Math]::Max($last.End, $range.End)
    }
}

[long]$part2 = 0
foreach ($r in $merged) {
    $part2 += ($r.End - $r.Start + 1)
}
Write-Host "Day 05 Part 2: $part2"
