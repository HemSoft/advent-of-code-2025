$inputData = Get-Content "input.txt" -Raw
$inputData = $inputData.Trim() -replace "`r`n", "`n"
$parts = $inputData -split "`n`n"

$rangesLines = $parts[0] -split "`n" | Where-Object { $_ -ne "" }
$idsLines = $parts[1] -split "`n" | Where-Object { $_ -ne "" }

$ranges = @()
foreach ($line in $rangesLines) {
    $split = $line.Trim() -split "-"
    $ranges += [PSCustomObject]@{
        Start = [int64]$split[0]
        End   = [int64]$split[1]
    }
}

$part1 = 0
foreach ($line in $idsLines) {
    $id = [int64]$line.Trim()
    $isFresh = $false
    foreach ($range in $ranges) {
        if ($id -ge $range.Start -and $id -le $range.End) {
            $isFresh = $true
            break
        }
    }
    if ($isFresh) {
        $part1++
    }
}

Write-Host "Day 05 Part 1: $part1"

# Part 2
$ranges = $ranges | Sort-Object Start

$mergedRanges = @()
if ($ranges.Count -gt 0) {
    $currStart = $ranges[0].Start
    $currEnd = $ranges[0].End

    for ($i = 1; $i -lt $ranges.Count; $i++) {
        $nextStart = $ranges[$i].Start
        $nextEnd = $ranges[$i].End

        if ($nextStart -le $currEnd + 1) {
            if ($nextEnd -gt $currEnd) {
                $currEnd = $nextEnd
            }
        } else {
            $mergedRanges += [PSCustomObject]@{
                Start = $currStart
                End   = $currEnd
            }
            $currStart = $nextStart
            $currEnd = $nextEnd
        }
    }
    $mergedRanges += [PSCustomObject]@{
        Start = $currStart
        End   = $currEnd
    }
}

$part2 = 0
foreach ($range in $mergedRanges) {
    $part2 += ($range.End - $range.Start + 1)
}

Write-Host "Day 05 Part 2: $part2"
