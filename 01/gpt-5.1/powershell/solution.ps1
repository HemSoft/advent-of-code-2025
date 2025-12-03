$lines = Get-Content "input.txt"

$position = 50
$zeroCount = 0

foreach ($raw in $lines) {
	$line = $raw.Trim()
	if ([string]::IsNullOrWhiteSpace($line)) { continue }

	$dir = $line[0]
	$distance = [int]::Parse($line.Substring(1))
	$distance = $distance % 100

	switch ($dir) {
		'R' {
			$position = ($position + $distance) % 100
		}
		'L' {
			$position = ($position - $distance) % 100
			if ($position -lt 0) { $position += 100 }
		}
	}

	if ($position -eq 0) {
		$zeroCount++
	}
}

# Part 1
$part1 = [long]$zeroCount
Write-Host "Day 01 Part 1: $part1"

# Part 2 (not implemented yet)
$part2 = 0
Write-Host "Day 01 Part 2: $part2"
