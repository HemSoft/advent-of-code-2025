$inputData = Get-Content "input.txt" -Raw

function Parse-Graph {
	param(
		[string]$Text
	)

	$graph = @{}

	foreach ($line in $Text -split "`n") {
		$trimmed = $line.Trim()
		if (-not $trimmed) {
			continue
		}

		$parts = $trimmed.Split(':', 2)
		if ($parts.Length -ne 2) {
			continue
		}

		$from = $parts[0].Trim()
		$targetsPart = $parts[1].Trim()

		$targets = @()
		if ($targetsPart) {
			$targets = $targetsPart.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Trim() }
		}

		$graph[$from] = [System.Collections.Generic.List[string]]::new()
		foreach ($t in $targets) {
			$null = $graph[$from].Add($t)
		}
	}

	return $graph
}

function Count-Paths {
	param(
		[string]$Node,
		[string]$Destination,
		[System.Collections.Hashtable]$Graph,
		[System.Collections.Hashtable]$Memo
	)

	if ($Node -eq $Destination) {
		return 1L
	}

	if ($Memo.ContainsKey($Node)) {
		return [int64]$Memo[$Node]
	}

	[int64]$total = 0

	if ($Graph.ContainsKey($Node)) {
		foreach ($child in $Graph[$Node]) {
			$total += Count-Paths -Node $child -Destination $Destination -Graph $Graph -Memo $Memo
		}
	}

	$Memo[$Node] = $total
	return $total
}

function Count-PathsWithRequiredNodes {
	param(
		[string]$Node,
		[string]$Destination,
		[System.Collections.Hashtable]$Graph,
		[System.Collections.Hashtable]$Memo,
		[int]$Mask
	)

	$updatedMask = $Mask
	if ($Node -eq 'fft') {
		$updatedMask = $updatedMask -bor 1
	} elseif ($Node -eq 'dac') {
		$updatedMask = $updatedMask -bor 2
	}

	if ($Node -eq $Destination) {
		if (($updatedMask -band 3) -eq 3) {
			return 1L
		}
		else {
			return 0L
		}
	}

	$key = "{0}|{1}" -f $Node, $updatedMask
	if ($Memo.ContainsKey($key)) {
		return [int64]$Memo[$key]
	}

	[int64]$total = 0
	if ($Graph.ContainsKey($Node)) {
		foreach ($child in $Graph[$Node]) {
			$total += Count-PathsWithRequiredNodes -Node $child -Destination $Destination -Graph $Graph -Memo $Memo -Mask $updatedMask
		}
	}

	$Memo[$key] = $total
	return $total
}

function Test-Example {
	$example = @'
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
'@

	$graph = Parse-Graph -Text ($example.Trim())
	$memo = @{}
	$paths = Count-Paths -Node 'you' -Destination 'out' -Graph $graph -Memo $memo

	if ($paths -ne 5) {
		Write-Error "Example test failed: expected 5, got $paths"
	}
}

function Test-Part2Example {
	$example = @'
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
'@

	$graph = Parse-Graph -Text ($example.Trim())
	$memo = @{}
	$paths = Count-PathsWithRequiredNodes -Node 'svr' -Destination 'out' -Graph $graph -Memo $memo -Mask 0

	if ($paths -ne 2) {
		Write-Error "Part 2 example test failed: expected 2, got $paths"
	}
}

Test-Example
Test-Part2Example

$graphReal = Parse-Graph -Text ($inputData.Trim())
$memoReal = @{}
$part1 = Count-Paths -Node 'you' -Destination 'out' -Graph $graphReal -Memo $memoReal
Write-Host "Day 11 Part 1: $part1"

$memoPart2 = @{}
$part2 = Count-PathsWithRequiredNodes -Node 'svr' -Destination 'out' -Graph $graphReal -Memo $memoPart2 -Mask 0
Write-Host "Day 11 Part 2: $part2"
