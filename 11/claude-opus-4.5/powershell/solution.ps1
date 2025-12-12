$lines = Get-Content "input.txt" | Where-Object { $_.Trim() -ne "" }

$graph = @{}

foreach ($line in $lines) {
    $parts = $line -split ":"
    $source = $parts[0].Trim()
    $destinations = ($parts[1].Trim() -split "\s+") | Where-Object { $_ -ne "" }
    $graph[$source] = $destinations
}

$memo1 = @{}

function Count-Paths {
    param (
        [string]$current,
        [string]$target
    )

    if ($current -eq $target) {
        return 1
    }

    if ($memo1.ContainsKey($current)) {
        return $memo1[$current]
    }

    if (-not $graph.ContainsKey($current)) {
        return 0
    }

    $count = [long]0
    foreach ($neighbor in $graph[$current]) {
        $count += Count-Paths -current $neighbor -target $target
    }
    $memo1[$current] = $count
    return $count
}

$memo2 = @{}

function Count-PathsWithRequired {
    param (
        [string]$current,
        [string]$target,
        [bool]$visitedDac,
        [bool]$visitedFft
    )

    if ($current -eq "dac") { $visitedDac = $true }
    if ($current -eq "fft") { $visitedFft = $true }

    if ($current -eq $target) {
        if ($visitedDac -and $visitedFft) { return 1 }
        return 0
    }

    $key = "${current}_${visitedDac}_${visitedFft}"
    if ($memo2.ContainsKey($key)) {
        return $memo2[$key]
    }

    if (-not $graph.ContainsKey($current)) {
        return 0
    }

    $count = [long]0
    foreach ($neighbor in $graph[$current]) {
        $count += Count-PathsWithRequired -current $neighbor -target $target -visitedDac $visitedDac -visitedFft $visitedFft
    }
    $memo2[$key] = $count
    return $count
}

# Part 1
$part1 = Count-Paths -current "you" -target "out"
Write-Host "Day 11 Part 1: $part1"

# Part 2
$part2 = Count-PathsWithRequired -current "svr" -target "out" -visitedDac $false -visitedFft $false
Write-Host "Day 11 Part 2: $part2"
