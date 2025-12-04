$lines = Get-Content "input.txt" | Where-Object { $_.Trim() -ne "" }

function Get-MaxJoltage {
    param([string]$line)

    $n = $line.Length
    $maxJoltage = 0

    # Precompute suffix maximum
    $suffixMax = @(0) * $n
    for ($i = $n - 2; $i -ge 0; $i--) {
        $currentDigit = [int]::Parse($line[$i + 1])
        $suffixMax[$i] = [Math]::Max($currentDigit, $suffixMax[$i + 1])
    }

    # Find max joltage
    for ($i = 0; $i -lt $n - 1; $i++) {
        $tensDigit = [int]::Parse($line[$i])
        $unitsDigit = $suffixMax[$i]
        $joltage = $tensDigit * 10 + $unitsDigit
        $maxJoltage = [Math]::Max($maxJoltage, $joltage)
    }

    return $maxJoltage
}

function Get-MaxJoltagePart2 {
    param([string]$line, [int]$k = 12)

    $n = $line.Length
    if ($n -lt $k) { return 0 }
    if ($n -eq $k) { return [long]$line }

    # Greedy: pick k digits to form largest number
    $result = @()
    $startIdx = 0

    for ($i = 0; $i -lt $k; $i++) {
        $remaining = $k - $i
        $endIdx = $n - $remaining

        $maxDigit = '0'
        $maxPos = $startIdx

        for ($j = $startIdx; $j -le $endIdx; $j++) {
            if ($line[$j] -gt $maxDigit) {
                $maxDigit = $line[$j]
                $maxPos = $j
            }
        }

        $result += $maxDigit
        $startIdx = $maxPos + 1
    }

    return [long]($result -join '')
}

# Part 1
$part1 = 0
foreach ($line in $lines) {
    $part1 += Get-MaxJoltage $line
}
Write-Host "Day 03 Part 1: $part1"

# Part 2
[long]$part2 = 0
foreach ($line in $lines) {
    $part2 += Get-MaxJoltagePart2 $line
}
Write-Host "Day 03 Part 2: $part2"
