$inputData = Get-Content "input.txt" -Raw
$lines = $inputData -split "`r`n" | Where-Object { $_ -ne '' }

# Parse fresh ranges and available IDs
$ranges = @()
$availableIds = @()

$index = 0
while ($index -lt $lines.Count -and $lines[$index] -like '*-*') {
	$line = $lines[$index].Trim()
	if (-not [string]::IsNullOrWhiteSpace($line)) {
		$parts = $line.Split('-', 2, [System.StringSplitOptions]::TrimEntries)
		if ($parts.Count -eq 2) {
			[long]$start = 0
			[long]$end = 0
			if ([long]::TryParse($parts[0], [ref]$start) -and [long]::TryParse($parts[1], [ref]$end)) {
				if ($end -lt $start) {
					$tmp = $start
					$start = $end
					$end = $tmp
				}
				$ranges += [pscustomobject]@{ Start = $start; End = $end }
			}
		}
	}
	$index++
}

for (; $index -lt $lines.Count; $index++) {
	$line = $lines[$index].Trim()
	if (-not [string]::IsNullOrWhiteSpace($line)) {
		[long]$id = 0
		if ([long]::TryParse($line, [ref]$id)) {
			$availableIds += $id
		}
	}
}

# Merge overlapping/adjacent ranges
$sortedRanges = $ranges | Sort-Object Start, End
$merged = @()
foreach ($r in $sortedRanges) {
	$start = [long]$r.Start
	$end = [long]$r.End
	if ($merged.Count -eq 0) {
		$merged += [pscustomobject]@{ Start = $start; End = $end }
		continue
	}

	$last = $merged[-1]
	$lastStart = [long]$last.Start
	$lastEnd = [long]$last.End
	if ($start -le ($lastEnd + 1)) {
		$newEnd = [math]::Max($end, $lastEnd)
		$merged[-1] = [pscustomobject]@{ Start = $lastStart; End = $newEnd }
	}
	else {
		$merged += [pscustomobject]@{ Start = $start; End = $end }
	}
}

# Part 1: count available IDs that fall within any merged range
[long]$part1 = 0
foreach ($id in $availableIds) {
	foreach ($range in $merged) {
		$start = [long]$range.Start
		$end = [long]$range.End
		if ($id -lt $start) {
			break
		}
		if ($id -le $end) {
			$part1++
			break
		}
	}
}

Write-Host "Day 05 Part 1: $part1"

# Part 2: count all unique IDs covered by any merged range
[long]$part2 = 0
foreach ($range in $merged) {
	$start = [long]$range.Start
	$end = [long]$range.End
	$part2 += ($end - $start + 1)
}

Write-Host "Day 05 Part 2: $part2"