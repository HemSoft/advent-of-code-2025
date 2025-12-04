$lines = Get-Content "input.txt"

$totalJoltagePart1 = 0
$totalJoltagePart2 = 0

foreach ($line in $lines) {
	if ([string]::IsNullOrWhiteSpace($line)) {
		continue
	}

	$maxJoltagePart1 = 0
	$found = $false

	for ($d1 = 9; $d1 -ge 1 -and -not $found; $d1--) {
		$c1 = [char]([int][char]'0' + $d1)
		$idx1 = $line.IndexOf($c1)
		if ($idx1 -lt 0) {
			continue
		}

		for ($d2 = 9; $d2 -ge 1; $d2--) {
			$c2 = [char]([int][char]'0' + $d2)
			$idx2 = $line.LastIndexOf($c2)
			if ($idx2 -lt 0) {
				continue
			}

			if ($idx1 -lt $idx2) {
				$maxJoltagePart1 = $d1 * 10 + $d2
				$found = $true
				break
			}
		}
	}

	$totalJoltagePart1 += $maxJoltagePart1

	# Part 2: choose exactly 12 digits to form the largest possible number
	$digits = $line
	$targetLength = 12
	$chosen = New-Object System.Collections.Generic.List[char]
	$start = 0

	for ($pos = 0; $pos -lt $targetLength; $pos++) {
		$remainingNeeded = $targetLength - $pos - 1
		$bestDigit = $null
		$bestIndex = -1

		for ($d = 9; $d -ge 0; $d--) {
			$ch = [char]([int][char]'0' + $d)
			$lastIndex = -1
			for ($i = $start; $i -lt $digits.Length; $i++) {
				if ($digits[$i] -eq $ch) {
					$lastIndex = $i
				}
			}
			if ($lastIndex -lt $start) { continue }

			if ($lastIndex -le $digits.Length - 1 - $remainingNeeded) {
				$bestDigit = $ch
				$bestIndex = $lastIndex
				break
			}
		}

		if ($bestIndex -eq -1) {
			$bestDigit = $digits[$start]
			$bestIndex = $start
		}

		$chosen.Add($bestDigit)
		$start = $bestIndex + 1
	}

	$lineJoltagePart2 = 0
	foreach ($ch in $chosen) {
		$lineJoltagePart2 = $lineJoltagePart2 * 10 + ([int][char]$ch - [int][char]'0')
	}

	$totalJoltagePart2 += $lineJoltagePart2
}

Write-Host "Day 03 Part 1: $totalJoltagePart1"
Write-Host "Day 03 Part 2: $totalJoltagePart2"
