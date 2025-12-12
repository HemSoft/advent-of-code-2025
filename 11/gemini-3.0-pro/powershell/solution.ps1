$inputData = Get-Content "input.txt"
$graph = @{}
$memo1 = @{}
$memo2 = @{}

foreach ($line in $inputData) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split ": "
    $source = $parts[0]
    $targets = $parts[1] -split " "
    $graph[$source] = $targets
}

function Count-PathsP1 {
    param ($current)

    if ($current -eq "out") { return 1 }
    if ($memo1.ContainsKey($current)) { return $memo1[$current] }

    if (-not $graph.ContainsKey($current)) {
        return 0
    }

    [long]$total = 0
    foreach ($neighbor in $graph[$current]) {
        $total += Count-PathsP1 -current $neighbor
    }

    $memo1[$current] = $total
    return $total
}

$paths1 = Count-PathsP1 -current "you"
Write-Host "Day 11 Part 1: $paths1"

function Count-PathsP2 {
    param ($current, [int]$mask)

    if ($current -eq "dac") { $mask = $mask -bor 1 }
    elseif ($current -eq "fft") { $mask = $mask -bor 2 }

    if ($current -eq "out") {
        if ($mask -eq 3) { return 1 }
        return 0
    }

    $key = "$current-$mask"
    if ($memo2.ContainsKey($key)) { return $memo2[$key] }

    if (-not $graph.ContainsKey($current)) {
        return 0
    }

    [long]$total = 0
    foreach ($neighbor in $graph[$current]) {
        $total += Count-PathsP2 -current $neighbor -mask $mask
    }

    $memo2[$key] = $total
    return $total
}

$paths2 = Count-PathsP2 -current "svr" -mask 0
Write-Host "Day 11 Part 2: $paths2"
