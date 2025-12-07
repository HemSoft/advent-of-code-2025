$lines = Get-Content "input.txt"
if ($lines.Count -eq 0) { exit }

$width = ($lines | Measure-Object -Property Length -Maximum).Maximum
$paddedLines = $lines | ForEach-Object { $_.PadRight($width) }

$totalSum = [long]0
$startCol = -1
$blocks = @()

function Process-Block {
    param (
        $lines,
        $start,
        $end
    )
    $numbers = @()
    $op = ' '

    foreach ($line in $lines) {
        $segment = $line.Substring($start, $end - $start + 1).Trim()
        if ([string]::IsNullOrWhiteSpace($segment)) { continue }

        if ($segment -eq "+" -or $segment -eq "*") {
            $op = $segment
        } elseif ($segment -match '^\d+$') {
            $numbers += [long]$segment
        }
    }

    if ($op -eq '+') {
        $sum = [long]0
        $numbers | ForEach-Object { $sum += $_ }
        return $sum
    } elseif ($op -eq '*') {
        $prod = [long]1
        $numbers | ForEach-Object { $prod *= $_ }
        return $prod
    }
    return 0
}

function Process-BlockPart2 {
    param (
        $lines,
        $start,
        $end
    )
    $numbers = @()
    $op = $null

    for ($col = $start; $col -le $end; $col++) {
        $chars = @()
        foreach ($line in $lines) {
            if ($line[$col] -ne ' ') {
                $chars += $line[$col]
            }
        }

        if ($chars.Count -eq 0) { continue }

        $lastChar = $chars[$chars.Count - 1]
        if ($lastChar -eq '+' -or $lastChar -eq '*') {
            $op = $lastChar
            if ($chars.Count -gt 1) {
                $chars = $chars[0..($chars.Count - 2)]
            } else {
                $chars = @()
            }
        }

        if ($chars.Count -gt 0) {
            $numStr = -join $chars
            if ($numStr -match '^\d+$') {
                $numbers += [long]$numStr
            }
        }
    }

    if ($op -eq '+') {
        $sum = [long]0
        $numbers | ForEach-Object { $sum += $_ }
        return $sum
    } elseif ($op -eq '*') {
        $prod = [long]1
        $numbers | ForEach-Object { $prod *= $_ }
        return $prod
    }
    return 0
}

for ($col = 0; $col -lt $width; $col++) {
    $isEmpty = $true
    foreach ($line in $paddedLines) {
        if ($line[$col] -ne ' ') {
            $isEmpty = $false
            break
        }
    }

    if ($isEmpty) {
        if ($startCol -ne -1) {
            $blocks += @{ Start = $startCol; End = $col - 1 }
            $startCol = -1
        }
    } else {
        if ($startCol -eq -1) {
            $startCol = $col
        }
    }
}

if ($startCol -ne -1) {
    $blocks += @{ Start = $startCol; End = $width - 1 }
}

$totalSumP1 = [long]0
foreach ($block in $blocks) {
    $totalSumP1 += Process-Block -lines $paddedLines -start $block.Start -end $block.End
}
Write-Host "Day 06 Part 1: $totalSumP1"

$totalSumP2 = [long]0
foreach ($block in $blocks) {
    $totalSumP2 += Process-BlockPart2 -lines $paddedLines -start $block.Start -end $block.End
}
Write-Host "Day 06 Part 2: $totalSumP2"
