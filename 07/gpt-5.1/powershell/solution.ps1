function Solve-Day07Part1 {
	param(
		[string[]]$Lines
	)

	if (-not $Lines -or $Lines.Count -eq 0) {
		return 0
	}

	$height = $Lines.Count
	$width = 0

	foreach ($line in $Lines) {
		if ($line.Length -gt $width) {
			$width = $line.Length
		}
	}

	# Pad lines to equal width
	$grid = @()
	foreach ($line in $Lines) {
		if ($line.Length -lt $width) {
			$grid += $line.PadRight($width, '.')
		}
		else {
			$grid += $line
		}
	}

	$startRow = -1
	$startCol = -1

	for ($r = 0; $r -lt $height -and $startRow -lt 0; $r++) {
		$c = $grid[$r].IndexOf('S')
		if ($c -ge 0) {
			$startRow = $r
			$startCol = $c
		}
	}

	if ($startRow -lt 0) {
		return 0
	}

	$current = [System.Collections.Generic.HashSet[string]]::new()
	[void]$current.Add("$startRow,$startCol")

	[long]$splits = 0

	while ($current.Count -gt 0) {
		$next = [System.Collections.Generic.HashSet[string]]::new()

		foreach ($key in $current) {
			$parts = $key -split ','
			$r = [int]$parts[0]
			$c = [int]$parts[1]

			$nr = $r + 1
			if ($nr -ge $height) {
				continue
			}

			$cell = $grid[$nr][$c]
			if ($cell -eq '^') {
				$splits++

				if ($c - 1 -ge 0) {
					[void]$next.Add("$nr,$($c - 1)")
				}
				if ($c + 1 -lt $width) {
					[void]$next.Add("$nr,$($c + 1)")
				}
			}
			else {
				[void]$next.Add("$nr,$c")
			}
		}

		$current = $next
	}

	return $splits
}

function Solve-Day07Part2 {
	param(
		[string[]]$Lines
	)

	if (-not $Lines -or $Lines.Count -eq 0) {
		return 0
	}

	$height = $Lines.Count
	$width = 0

	foreach ($line in $Lines) {
		if ($line.Length -gt $width) {
			$width = $line.Length
		}
	}

	# Pad lines to equal width
	$grid = @()
	foreach ($line in $Lines) {
		if ($line.Length -lt $width) {
			$grid += $line.PadRight($width, '.')
		}
		else {
			$grid += $line
		}
	}

	$startRow = -1
	$startCol = -1

	for ($r = 0; $r -lt $height -and $startRow -lt 0; $r++) {
		$c = $grid[$r].IndexOf('S')
		if ($c -ge 0) {
			$startRow = $r
			$startCol = $c
		}
	}

	if ($startRow -lt 0) {
		return 0
	}

	$current = @{
		"$startRow,$startCol" = 1L
	}

	[long]$finished = 0

	while ($current.Count -gt 0) {
		$next = @{}

		foreach ($key in $current.Keys) {
			$parts = $key -split ','
			$r = [int]$parts[0]
			$c = [int]$parts[1]
			$count = [long]$current[$key]

			$nr = $r + 1
			if ($nr -ge $height) {
				$finished += $count
				continue
			}

			$cell = $grid[$nr][$c]
			if ($cell -eq '^') {
				if ($c - 1 -ge 0) {
					$k = "$nr,$($c - 1)"
					if ($next.ContainsKey($k)) {
						$next[$k] += $count
					}
					else {
						$next[$k] = $count
					}
				}
				if ($c + 1 -lt $width) {
					$k = "$nr,$($c + 1)"
					if ($next.ContainsKey($k)) {
						$next[$k] += $count
					}
					else {
						$next[$k] = $count
					}
				}
			}
			else {
				$k = "$nr,$c"
				if ($next.ContainsKey($k)) {
					$next[$k] += $count
				}
				else {
					$next[$k] = $count
				}
			}
		}

		$current = $next
	}

	return $finished
}

$lines = Get-Content "input.txt"

# Part 1
$part1 = Solve-Day07Part1 -Lines $lines
Write-Host "Day 07 Part 1: $part1"

# Part 2
$part2 = Solve-Day07Part2 -Lines $lines
Write-Host "Day 07 Part 2: $part2"