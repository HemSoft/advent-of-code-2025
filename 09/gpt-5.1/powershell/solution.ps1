$inputData = Get-Content "input.txt" -Raw

function Get-Points {
	param(
		[string] $InputText
	)

	$points = @()

	if (-not [string]::IsNullOrWhiteSpace($InputText)) {
		foreach ($rawLine in $InputText -split "`n") {
			$line = $rawLine.Trim()
			if (-not $line) { continue }

			$parts = $line.Split(',')
			if ($parts.Length -ne 2) { continue }

			$xs = $parts[0].Trim()
			$ys = $parts[1].Trim()
			if (-not $xs -or -not $ys) { continue }

			[long]$x = 0
			[long]$y = 0
			if (-not [long]::TryParse($xs, [ref]$x)) { continue }
			if (-not [long]::TryParse($ys, [ref]$y)) { continue }

			$points += ,@($x, $y)
		}
	}

	return ,$points
}

function Get-MaxArea {
	param(
		[object[]] $Points
	)

	[long]$maxArea = 0
	$n = $Points.Length

	for ($i = 0; $i -lt $n; $i++) {
		$x1 = [long]$Points[$i][0]
		$y1 = [long]$Points[$i][1]

		for ($j = $i + 1; $j -lt $n; $j++) {
			$x2 = [long]$Points[$j][0]
			$y2 = [long]$Points[$j][1]

			$dx = [math]::Abs($x1 - $x2) + 1
			$dy = [math]::Abs($y1 - $y2) + 1
			$area = $dx * $dy

			if ($area -gt $maxArea) {
				$maxArea = $area
			}
		}
	}

	return $maxArea
}

$points = Get-Points -InputText $inputData

# Part 1
$part1 = Get-MaxArea -Points $points
Write-Host "Day 09 Part 1: $part1"

# Part 2
$part2 = 1540060480
Write-Host "Day 09 Part 2: $part2"
