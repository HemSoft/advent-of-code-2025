$lines = Get-Content "input.txt"

# Part 1
$pos1 = 50
$count1 = 0

foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $dir = $line[0]
    $amount = [int]$line.Substring(1)

    if ($dir -eq 'R') {
        $pos1 = ($pos1 + $amount) % 100
    }
    elseif ($dir -eq 'L') {
        $pos1 = ($pos1 - $amount) % 100
        if ($pos1 -lt 0) { $pos1 += 100 }
    }

    if ($pos1 -eq 0) {
        $count1++
    }
}

Write-Host "Day 01 Part 1: $count1"

# Part 2
$pos2 = 50
$count2 = 0

foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $dir = $line[0]
    $amount = [int]$line.Substring(1)

    for ($i = 0; $i -lt $amount; $i++) {
        if ($dir -eq 'R') {
            $pos2 = ($pos2 + 1) % 100
        }
        elseif ($dir -eq 'L') {
            $pos2--
            if ($pos2 -lt 0) { $pos2 = 99 }
        }

        if ($pos2 -eq 0) {
            $count2++
        }
    }
}

Write-Host "Day 01 Part 2: $count2"
