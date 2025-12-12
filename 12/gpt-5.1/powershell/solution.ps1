function Parse-Input {
	param(
		[string] $Path
	)

	$lines = Get-Content -Path $Path

	$shapeSizes = @{}
	$regionLines = @()
	$currentShapeId = -1
	$currentShapeCount = 0

	foreach ($rawLine in $lines) {
		$line = $rawLine.TrimEnd("`r")
		if ([string]::IsNullOrWhiteSpace($line)) {
			continue
		}

		if ($line.Length -gt 0 -and [char]::IsDigit($line[0]) -and $line.Contains(':') -and -not $line.Contains('x')) {
			if ($currentShapeId -ge 0) {
				$shapeSizes[$currentShapeId] = $currentShapeCount
			}
			$idPart = $line.Split(':')[0]
			$currentShapeId = [int]$idPart
			$currentShapeCount = 0
		}
		elseif ($line.Contains('x') -and $line.Contains(':')) {
			if ($currentShapeId -ge 0) {
				$shapeSizes[$currentShapeId] = $currentShapeCount
				$currentShapeId = -1
				$currentShapeCount = 0
			}
			$regionLines += $line.Trim()
		}
		elseif ($currentShapeId -ge 0 -and ($line.Contains('#') -or $line.Contains('.'))) {
			$currentShapeCount += ($line.ToCharArray() | Where-Object { $_ -eq '#' }).Count
		}
	}

	if ($currentShapeId -ge 0) {
		$shapeSizes[$currentShapeId] = $currentShapeCount
	}

	return ,@($shapeSizes, $regionLines)
}

function Solve-Part1 {
	param(
		[string] $Path
	)

	$parsed = Parse-Input -Path $Path
	$shapeSizes = $parsed[0]
	$regionLines = $parsed[1]

	$countFit = 0

	foreach ($regionLine in $regionLines) {
		$parts = $regionLine.Split(':', 2)
		$sizePart = $parts[0].Trim()
		$countsPart = $parts[1].Trim()

		$sizeParts = $sizePart.Split('x')
		$width = [int]$sizeParts[0]
		$height = [int]$sizeParts[1]

		$countStrings = $countsPart -split '\s+'
		$totalCellsNeeded = 0

		for ($i = 0; $i -lt $countStrings.Length; $i++) {
			if (-not $countStrings[$i]) { continue }
			$c = [int]$countStrings[$i]
			if ($c -eq 0) { continue }
			$size = $shapeSizes[$i]
			$totalCellsNeeded += $c * $size
		}

		$gridArea = $width * $height
		if ($totalCellsNeeded -le $gridArea) {
			$countFit++
		}
	}

	return $countFit
}

$part1 = Solve-Part1 -Path "input.txt"
Write-Host "Day 12 Part 1: $part1"

# Part 2 placeholder
$part2 = 0
Write-Host "Day 12 Part 2: $part2"
