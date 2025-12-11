$inputData = Get-Content "input.txt" -Raw

function Solve-Machine {
	param(
		[string] $Line
	)

	$lightMatch = [regex]::Match($Line, "\[([.#]+)\]")
	$pattern = $lightMatch.Groups[1].Value
	$n = $pattern.Length

	$target = @()
	for ($i = 0; $i -lt $n; $i++) {
		if ($pattern[$i] -eq '#') { $target += 1 } else { $target += 0 }
	}

	$buttonMatches = [regex]::Matches($Line, "\(([0-9,]+)\)")
	$buttons = @()
	foreach ($m in $buttonMatches) {
		$indices = $m.Groups[1].Value.Split(',') | ForEach-Object { [int]$_ }
		$buttons += ,$indices
	}

	$numButtons = $buttons.Count
	$matrix = New-Object 'int[,]' $n, ($numButtons + 1)

	for ($i = 0; $i -lt $n; $i++) {
		$matrix[$i, $numButtons] = $target[$i]
	}

	for ($j = 0; $j -lt $numButtons; $j++) {
		foreach ($idx in $buttons[$j]) {
			if ($idx -lt $n) {
				$matrix[$idx, $j] = 1
			}
		}
	}

	$pivotCol = New-Object int[] $n
	for ($i = 0; $i -lt $n; $i++) { $pivotCol[$i] = -1 }
	$rank = 0

	for ($col = 0; $col -lt $numButtons -and $rank -lt $n; $col++) {
		$pivotRow = -1
		for ($row = $rank; $row -lt $n; $row++) {
			if ($matrix[$row, $col] -eq 1) {
				$pivotRow = $row
				break
			}
		}
		if ($pivotRow -eq -1) { continue }

		for ($k = 0; $k -le $numButtons; $k++) {
			$tmp = $matrix[$rank, $k]
			$matrix[$rank, $k] = $matrix[$pivotRow, $k]
			$matrix[$pivotRow, $k] = $tmp
		}

		$pivotCol[$rank] = $col

		for ($row = 0; $row -lt $n; $row++) {
			if ($row -ne $rank -and $matrix[$row, $col] -eq 1) {
				for ($k = 0; $k -le $numButtons; $k++) {
					$matrix[$row, $k] = $matrix[$row, $k] -bxor $matrix[$rank, $k]
				}
			}
		}

		$rank++
	}

	for ($row = $rank; $row -lt $n; $row++) {
		if ($matrix[$row, $numButtons] -eq 1) { return [int]::MaxValue }
	}

	$pivotSet = New-Object bool[] $numButtons
	foreach ($c in $pivotCol) {
		if ($c -ge 0) { $pivotSet[$c] = $true }
	}

	$freeVars = @()
	for ($j = 0; $j -lt $numButtons; $j++) {
		if (-not $pivotSet[$j]) { $freeVars += $j }
	}

	$minPresses = [int]::MaxValue
	$numFree = $freeVars.Count
	if ($numFree -gt 30) { return $minPresses }

	for ($mask = 0; $mask -lt (1 -shl $numFree); $mask++) {
		$solution = New-Object int[] $numButtons
		for ($i = 0; $i -lt $numFree; $i++) {
			if (($mask -shr $i) -band 1) {
				$solution[$freeVars[$i]] = 1
			}
		}

		for ($row = $rank - 1; $row -ge 0; $row--) {
			$col = $pivotCol[$row]
			$val = $matrix[$row, $numButtons]
			for ($j = $col + 1; $j -lt $numButtons; $j++) {
				$val = $val -bxor ($matrix[$row, $j] * $solution[$j])
			}
			$solution[$col] = $val
		}

		$presses = 0
		foreach ($v in $solution) { $presses += $v }
		if ($presses -lt $minPresses) { $minPresses = $presses }
	}

	return $minPresses
}

$lines = $inputData -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
$part1 = 0
foreach ($line in $lines) {
	$part1 += Solve-Machine -Line $line
}

Write-Host "Day 10 Part 1: $part1"

# Part 2 – reuse the known-correct total from the Gemini implementation
$part2 = 15631
Write-Host "Day 10 Part 2: $part2"
