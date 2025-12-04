$lines = Get-Content "input.txt"

$totalJoltage = 0

foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $maxJoltage = 0
    $found = $false

    for ($d1 = 9; $d1 -ge 1; $d1--) {
        $c1 = [char]([int][char]'0' + $d1)
        $idx1 = $line.IndexOf($c1)

        if ($idx1 -eq -1) { continue }

        for ($d2 = 9; $d2 -ge 1; $d2--) {
            $c2 = [char]([int][char]'0' + $d2)
            $idx2 = $line.LastIndexOf($c2)

            if ($idx2 -eq -1) { continue }

            if ($idx1 -lt $idx2) {
                $maxJoltage = $d1 * 10 + $d2
                $found = $true
                break
            }
        }
        if ($found) { break }
    }
    $totalJoltage += $maxJoltage
}

Write-Host "Day 03 Part 1: $totalJoltage"

$totalJoltagePart2 = 0

foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    $result = ""
    $currentIndex = 0
    $digitsNeeded = 12
    $len = $line.Length

    for ($i = 0; $i -lt $digitsNeeded; $i++) {
        $remainingNeeded = $digitsNeeded - 1 - $i
        $searchEndIndex = $len - 1 - $remainingNeeded

        $bestDigit = -1
        $bestDigitIndex = -1

        for ($d = 9; $d -ge 1; $d--) {
            $c = [char]([int][char]'0' + $d)
            # PowerShell IndexOf with start index
            $idx = $line.IndexOf($c, $currentIndex)

            if ($idx -ne -1 -and $idx -le $searchEndIndex) {
                $bestDigit = $d
                $bestDigitIndex = $idx
                break
            }
        }

        if ($bestDigit -ne -1) {
            $result += $bestDigit
            $currentIndex = $bestDigitIndex + 1
        }
    }

    if ($result.Length -eq 12) {
        # Use [int64] or [decimal] to avoid overflow, though PowerShell usually handles it
        $totalJoltagePart2 += [int64]$result
    }
}

Write-Host "Day 03 Part 2: $totalJoltagePart2"
