$inputData = (Get-Content "input.txt" -Raw).Trim()

function Test-InvalidIdPart1 {
    param([long]$num)
    $s = $num.ToString()
    if ($s.Length % 2 -ne 0) { return $false }
    $half = $s.Length / 2
    return $s.Substring(0, $half) -eq $s.Substring($half)
}

function Test-InvalidIdPart2 {
    param([long]$num)
    $s = $num.ToString()
    # Check for patterns repeated at least twice
    for ($patternLen = 1; $patternLen -le [Math]::Floor($s.Length / 2); $patternLen++) {
        if ($s.Length % $patternLen -ne 0) { continue }
        $pattern = $s.Substring(0, $patternLen)
        $repetitions = $s.Length / $patternLen
        if ($repetitions -lt 2) { continue }
        $isRepeated = $true
        for ($i = 1; $i -lt $repetitions; $i++) {
            if ($s.Substring($i * $patternLen, $patternLen) -ne $pattern) {
                $isRepeated = $false
                break
            }
        }
        if ($isRepeated) { return $true }
    }
    return $false
}

# Part 1
[long]$part1 = 0
$ranges = $inputData -split ','
foreach ($range in $ranges) {
    if (-not $range) { continue }
    $parts = $range -split '-'
    $start = [long]$parts[0]
    $end = [long]$parts[1]
    for ($id = $start; $id -le $end; $id++) {
        if (Test-InvalidIdPart1 $id) {
            $part1 += $id
        }
    }
}
Write-Host "Day 02 Part 1: $part1"

# Part 2
[long]$part2 = 0
foreach ($range in $ranges) {
    if (-not $range) { continue }
    $parts = $range -split '-'
    $start = [long]$parts[0]
    $end = [long]$parts[1]
    for ($id = $start; $id -le $end; $id++) {
        if (Test-InvalidIdPart2 $id) {
            $part2 += $id
        }
    }
}
Write-Host "Day 02 Part 2: $part2"
