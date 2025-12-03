$inputData = Get-Content "input.txt" -Raw
$ranges = $inputData.Trim() -split ","

$totalSum = [bigint]0

foreach ($range in $ranges) {
    if ([string]::IsNullOrWhiteSpace($range)) { continue }

    $parts = $range.Trim() -split "-"
    $start = [long]$parts[0]
    $end = [long]$parts[1]

    for ($i = $start; $i -le $end; $i++) {
        $s = $i.ToString()
        if ($s.Length % 2 -ne 0) { continue }

        $halfLen = $s.Length / 2
        $firstHalf = $s.Substring(0, $halfLen)
        $secondHalf = $s.Substring($halfLen)

        if ($firstHalf -eq $secondHalf) {
            $totalSum += $i
        }
    }
}

Write-Host "Day 02 Part 1: $totalSum"

$totalSumPart2 = [bigint]0

foreach ($range in $ranges) {
    if ([string]::IsNullOrWhiteSpace($range)) { continue }

    $parts = $range.Trim() -split "-"
    $start = [long]$parts[0]
    $end = [long]$parts[1]

    for ($i = $start; $i -le $end; $i++) {
        $s = $i.ToString()
        $len = $s.Length
        $isInvalid = $false

        for ($patternLen = 1; $patternLen -le ($len / 2); $patternLen++) {
            if ($len % $patternLen -ne 0) { continue }

            $pattern = $s.Substring(0, $patternLen)
            $repetitions = $len / $patternLen

            # Construct repeated string manually or check substrings
            $repeated = ""
            for ($k = 0; $k -lt $repetitions; $k++) {
                $repeated += $pattern
            }

            if ($repeated -eq $s) {
                $isInvalid = $true
                break
            }
        }

        if ($isInvalid) {
            $totalSumPart2 += $i
        }
    }
}

Write-Host "Day 02 Part 2: $totalSumPart2"
