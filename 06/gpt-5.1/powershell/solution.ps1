
function Solve {
	param(
		[string[]] $Lines
	)

	if (-not $Lines -or $Lines.Count -eq 0) {
		return 0
	}

	$height = $Lines.Count
	$width = ($Lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

	# Pad lines to equal width
	$grid = @()
	foreach ($line in $Lines) {
		$trimmed = $line.TrimEnd("`r", "`n")
		if ($trimmed.Length -lt $width) {
			$trimmed = $trimmed.PadRight($width, ' ')
		}
		$grid += $trimmed
	}

	$ranges = @()
	$inBlock = $false
	$startCol = 0

	for ($x = 0; $x -lt $width; $x++) {
		$allSpace = $true
		for ($y = 0; $y -lt $height; $y++) {
			if ($grid[$y][$x] -ne ' ') {
				$allSpace = $false
				break
			}
		}

		if ($allSpace) {
			if ($inBlock) {
				$ranges += [pscustomobject]@{ Start = $startCol; End = $x - 1 }
				$inBlock = $false
			}
		}
		elseif (-not $inBlock) {
			$inBlock = $true
			$startCol = $x
		}
	}

	if ($inBlock) {
		$ranges += [pscustomobject]@{ Start = $startCol; End = $width - 1 }
	}

	$total = 0L

	foreach ($range in $ranges) {
		$start = $range.Start
		$end = $range.End

		# Find operator in bottom row
		$op = $null
		for ($x = $start; $x -le $end; $x++) {
			$c = $grid[$height - 1][$x]
			if ($c -eq '+' -or $c -eq '*') {
				$op = $c
				break
			}
		}

		if (-not $op) { continue }

		$nums = @()
		for ($y = 0; $y -lt $height - 1; $y++) {
			$segment = $grid[$y].Substring($start, $end - $start + 1)
			$s = $segment.Trim()
			if (-not $s) { continue }
			$nums += [int64]$s
		}

		if ($nums.Count -eq 0) { continue }

		if ($op -eq '+') {
			$value = 0L
			foreach ($n in $nums) { $value += $n }
		}
		else {
			$value = 1L
			foreach ($n in $nums) { $value *= $n }
		}

		$total += $value
	}

	return $total
}

function SolvePart2 {
	param(
		[string[]] $Lines
	)

	if (-not $Lines -or $Lines.Count -eq 0) {
		return 0
	}

	$height = $Lines.Count
	$width = ($Lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

	$grid = @()
	foreach ($line in $Lines) {
		$trimmed = $line.TrimEnd("`r", "`n")
		if ($trimmed.Length -lt $width) {
			$trimmed = $trimmed.PadRight($width, ' ')
		}
		$grid += $trimmed
	}

	$ranges = @()
	$inBlock = $false
	$startCol = 0

	for ($x = 0; $x -lt $width; $x++) {
		$allSpace = $true
		for ($y = 0; $y -lt $height; $y++) {
			if ($grid[$y][$x] -ne ' ') {
				$allSpace = $false
				break
			}
		}

		if ($allSpace) {
			if ($inBlock) {
				$ranges += [pscustomobject]@{ Start = $startCol; End = $x - 1 }
				$inBlock = $false
			}
		}
		elseif (-not $inBlock) {
			$inBlock = $true
			$startCol = $x
		}
	}

	if ($inBlock) {
		$ranges += [pscustomobject]@{ Start = $startCol; End = $width - 1 }
	}

	$total = 0L

	foreach ($range in $ranges) {
		$start = $range.Start
		$end = $range.End

		$op = $null
		for ($x = $start; $x -le $end; $x++) {
			$c = $grid[$height - 1][$x]
			if ($c -eq '+' -or $c -eq '*') {
				$op = $c
				break
			}
		}

		if (-not $op) { continue }

		$nums = @()

		for ($x = $end; $x -ge $start; $x--) {
			$digits = ""
			for ($y = 0; $y -lt $height - 1; $y++) {
				$c = $grid[$y][$x]
				if ($c -ge '0' -and $c -le '9') {
					$digits += $c
				}
			}

			if ($digits.Length -gt 0) {
				$nums += [int64]$digits
			}
		}

		if ($nums.Count -eq 0) { continue }

		if ($op -eq '+') {
			$value = 0L
			foreach ($n in $nums) { $value += $n }
		}
		else {
			$value = 1L
			foreach ($n in $nums) { $value *= $n }
		}

		$total += $value
	}

	return $total
}

$lines = Get-Content "input.txt"

# Part 1
$part1 = Solve -Lines $lines
Write-Host "Day 06 Part 1: $part1"

# Part 2
$part2 = SolvePart2 -Lines $lines
Write-Host "Day 06 Part 2: $part2"
