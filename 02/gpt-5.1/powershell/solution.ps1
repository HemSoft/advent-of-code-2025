$inputData = (Get-Content "input.txt" -Raw).Trim()

function Get-DigitsCount {
	param(
		[long]$n
	)

	$n = [math]::Abs($n)
	$count = 1
	while ($n -ge 10) {
		$n = [math]::Floor($n / 10)
		$count++
	}
	return $count
}

function Get-Pow10 {
	param(
		[int]$exp
	)

	$result = 1L
	for ($i = 0; $i -lt $exp; $i++) {
		$result *= 10L
	}
	return $result
}

function Get-SumInvalidIds {
	param(
		[string]$input
	)

	$sum = 0L
	$ranges = $input.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries)

	foreach ($range in $ranges) {
		$range = $range.Trim()
		if (-not $range) { continue }

		$parts = $range.Split('-',[System.StringSplitOptions]::RemoveEmptyEntries)
		if ($parts.Count -ne 2) { continue }

		[long]$start = 0
		[long]$end = 0
		if (-not [long]::TryParse($parts[0].Trim(), [ref]$start)) { continue }
		if (-not [long]::TryParse($parts[1].Trim(), [ref]$end)) { continue }

		if ($end -lt $start) {
			$tmp = $start; $start = $end; $end = $tmp
		}

		$minLen = Get-DigitsCount -n $start
		$maxLen = Get-DigitsCount -n $end

		for ($len = $minLen; $len -le $maxLen; $len++) {
			if ($len % 2 -ne 0) { continue }

			$half = [int]($len / 2)
			$pow10 = Get-Pow10 -exp $half
			$first = Get-Pow10 -exp ($len - 1)
			$last = (Get-Pow10 -exp $len) - 1

			$low = [math]::Max($start, $first)
			$high = [math]::Min($end, $last)
			if ($low -gt $high) { continue }

			$den = [double]($pow10 + 1)
			$aStart = [long][math]::Ceiling($low / $den)
			$aEnd = [long]([math]::Floor($high / $den))
			if ($aStart -gt $aEnd) { continue }

			$count = $aEnd - $aStart + 1
			$termsSum = ($aStart + $aEnd) * $count / 2
			$contrib = [long]($termsSum * ($pow10 + 1))
			$sum += $contrib
		}
	}

	return $sum
}

$part1 = Get-SumInvalidIds -input $inputData
Write-Host "Day 02 Part 1: $part1"

function Get-SumInvalidIdsPart2 {
	param(
		[string]$input
	)

	$sum = 0L
	$ranges = $input.Split(',', [System.StringSplitOptions]::RemoveEmptyEntries)

	foreach ($rangeRaw in $ranges) {
		$range = $rangeRaw.Trim()
		if (-not $range) { continue }

		$parts = $range.Split('-', [System.StringSplitOptions]::RemoveEmptyEntries)
		if ($parts.Count -ne 2) { continue }

		[long]$start = 0
		[long]$end = 0
		if (-not [long]::TryParse($parts[0].Trim(), [ref]$start)) { continue }
		if (-not [long]::TryParse($parts[1].Trim(), [ref]$end)) { continue }

		if ($end -lt $start) {
			$tmp = $start; $start = $end; $end = $tmp
		}

		$minLen = Get-DigitsCount -n $start
		$maxLen = Get-DigitsCount -n $end

		for ($len = $minLen; $len -le $maxLen; $len++) {
			for ($k = 2; $k * $k -le $len; $k++) {
				if ($len % $k -ne 0) { continue }

				$baseLen = [int]($len / $k)
				$pow10Base = Get-Pow10 -exp $baseLen
				$first = Get-Pow10 -exp ($len - 1)
				$last = (Get-Pow10 -exp $len) - 1

				$low = [math]::Max($start, $first)
				$high = [math]::Min($end, $last)
				if ($low -gt $high) { continue }

				$geom = 0L
				$factor = 1L
				for ($i = 0; $i -lt $k; $i++) {
					$geom += $factor
					$factor *= $pow10Base
				}

				$aStart = [long][math]::Ceiling($low / [double]$geom)
				$aEnd = [long]([math]::Floor($high / [double]$geom))
				if ($aStart -gt $aEnd) { continue }

				$count = $aEnd - $aStart + 1
				$termsSum = ($aStart + $aEnd) * $count / 2
				$contrib = [long]($termsSum * $geom)
				$sum += $contrib
			}
		}
	}

	return $sum
}

$part2 = Get-SumInvalidIdsPart2 -input $inputData
Write-Host "Day 02 Part 2: $part2"
