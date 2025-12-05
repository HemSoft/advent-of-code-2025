$lines = Get-Content "input.txt" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

function Get-AccessibleRollCount {
	param (
		[string[]] $Grid
	)

	$height = $Grid.Count
	if ($height -eq 0) {
		return 0
	}

	$width = $Grid[0].Length
	$accessible = 0

	$dirs = @(
		@(-1, -1), @(-1, 0), @(-1, 1),
		@(0, -1),              @(0, 1),
		@(1, -1),  @(1, 0),  @(1, 1)
	)

	for ($r = 0; $r -lt $height; $r++) {
		$row = $Grid[$r]

		for ($c = 0; $c -lt $width; $c++) {
			if ($row[$c] -ne [char]'@') {
				continue
			}

			$neighbors = 0

			foreach ($d in $dirs) {
				$nr = $r + $d[0]
				$nc = $c + $d[1]

				if ($nr -lt 0 -or $nr -ge $height -or $nc -lt 0 -or $nc -ge $width) {
					continue
				}

				if ($Grid[$nr][$nc] -eq [char]'@') {
					$neighbors++
				}
			}

			if ($neighbors -lt 4) {
				$accessible++
			}
		}
	}

	return $accessible
}

function Get-TotalRemovableRolls {
	param (
		[string[]] $Grid
	)

	$height = $Grid.Count
	if ($height -eq 0) {
		return 0
	}

	$width = $Grid[0].Length

	# Create mutable board as array of char arrays
	$board = @()
	foreach ($row in $Grid) {
		$board += ,($row.ToCharArray())
	}

	$dirs = @(
		@(-1, -1), @(-1, 0), @(-1, 1),
		@(0, -1),              @(0, 1),
		@(1, -1),  @(1, 0),  @(1, 1)
	)

	$totalRemoved = 0

	while ($true) {
		$toRemove = @()

		for ($r = 0; $r -lt $height; $r++) {
			for ($c = 0; $c -lt $width; $c++) {
				if ($board[$r][$c] -ne [char]'@') {
					continue
				}

				$neighbors = 0

				foreach ($d in $dirs) {
					$nr = $r + $d[0]
					$nc = $c + $d[1]

					if ($nr -lt 0 -or $nr -ge $height -or $nc -lt 0 -or $nc -ge $width) {
						continue
					}

					if ($board[$nr][$nc] -eq [char]'@') {
						$neighbors++
					}
				}

				if ($neighbors -lt 4) {
					$toRemove += ,@($r, $c)
				}
			}
		}

		if ($toRemove.Count -eq 0) {
			break
		}

		foreach ($pos in $toRemove) {
			$r = $pos[0]
			$c = $pos[1]
			$board[$r][$c] = [char]'.'
		}

		$totalRemoved += $toRemove.Count
	}

	return $totalRemoved
}

# Part 1
$part1 = Get-AccessibleRollCount -Grid $lines
Write-Host "Day 04 Part 1: $part1"

# Part 2
$part2 = Get-TotalRemovableRolls -Grid $lines
Write-Host "Day 04 Part 2: $part2"
