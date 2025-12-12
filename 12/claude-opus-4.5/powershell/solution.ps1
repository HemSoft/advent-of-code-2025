$lines = Get-Content "input.txt"

$shapes = @{}
$regionLines = @()
$currentShapeId = -1
$currentCellCount = 0

foreach ($line in $lines) {
    $line = $line.TrimEnd()
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    if ($line -match '^\d+:' -and $line -notmatch 'x') {
        if ($currentShapeId -ge 0) {
            $shapes[$currentShapeId] = $currentCellCount
        }
        $currentShapeId = [int]($line -split ':')[0]
        $currentCellCount = 0
    }
    elseif ($line -match 'x' -and $line -match ':') {
        if ($currentShapeId -ge 0) {
            $shapes[$currentShapeId] = $currentCellCount
            $currentShapeId = -1
            $currentCellCount = 0
        }
        $regionLines += $line
    }
    elseif ($currentShapeId -ge 0 -and ($line -match '#' -or $line -match '\.')) {
        $currentCellCount += ($line.ToCharArray() | Where-Object { $_ -eq '#' }).Count
    }
}

if ($currentShapeId -ge 0) {
    $shapes[$currentShapeId] = $currentCellCount
}

$part1 = 0

foreach ($regionLine in $regionLines) {
    $colonIdx = $regionLine.IndexOf(':')
    $sizePart = $regionLine.Substring(0, $colonIdx)
    $countsPart = $regionLine.Substring($colonIdx + 1).Trim()

    $sizeParts = $sizePart -split 'x'
    $width = [int]$sizeParts[0]
    $height = [int]$sizeParts[1]

    $counts = ($countsPart -split '\s+') | ForEach-Object { [int]$_ }

    $totalCellsNeeded = 0
    for ($i = 0; $i -lt $counts.Count; $i++) {
        if ($shapes.ContainsKey($i)) {
            $totalCellsNeeded += $counts[$i] * $shapes[$i]
        }
    }

    $gridArea = $width * $height
    if ($totalCellsNeeded -le $gridArea) {
        $part1++
    }
}

Write-Host "Day 12 Part 1: $part1"
Write-Host "Day 12 Part 2: 0"
