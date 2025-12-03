$lines = Get-Content "input.txt"
$pos = 50
$count = 0

foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $dir = $line[0]
    $amount = [int]$line.Substring(1)

    if ($dir -eq 'R') {
        $pos = ($pos + $amount) % 100
    }
    elseif ($dir -eq 'L') {
        $pos = ($pos - $amount) % 100
        if ($pos -lt 0) { $pos += 100 }
    }

    if ($pos -eq 0) {
        $count++
    }
}

Write-Host "Day 01 Part 1: $count"
