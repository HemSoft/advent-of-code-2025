function Solve-Machine {
    param([string]$line)
    
    # Parse indicator lights pattern
    if ($line -match '\[([.#]+)\]') {
        $pattern = $Matches[1]
    }
    $n = $pattern.Length
    
    # Target: 1 where '#', 0 where '.'
    $target = @()
    for ($i = 0; $i -lt $n; $i++) {
        $target += if ($pattern[$i] -eq '#') { 1 } else { 0 }
    }
    
    # Parse buttons
    $buttonMatches = [regex]::Matches($line, '\(([0-9,]+)\)')
    $buttons = @()
    foreach ($m in $buttonMatches) {
        $indices = $m.Groups[1].Value -split ',' | ForEach-Object { [int]$_ }
        $buttons += ,@($indices)
    }
    
    $numButtons = $buttons.Count
    
    # Build augmented matrix [A | target]
    $matrix = @()
    for ($i = 0; $i -lt $n; $i++) {
        $row = @(0) * ($numButtons + 1)
        $row[$numButtons] = $target[$i]
        $matrix += ,$row
    }
    for ($j = 0; $j -lt $numButtons; $j++) {
        foreach ($idx in $buttons[$j]) {
            if ($idx -lt $n) {
                $matrix[$idx][$j] = 1
            }
        }
    }
    
    # Gaussian elimination over GF(2)
    $pivotCol = @(-1) * $n
    $rank = 0
    
    for ($col = 0; $col -lt $numButtons -and $rank -lt $n; $col++) {
        # Find pivot
        $pivotRow = -1
        for ($row = $rank; $row -lt $n; $row++) {
            if ($matrix[$row][$col] -eq 1) {
                $pivotRow = $row
                break
            }
        }
        
        if ($pivotRow -eq -1) { continue }
        
        # Swap rows
        $temp = $matrix[$rank]
        $matrix[$rank] = $matrix[$pivotRow]
        $matrix[$pivotRow] = $temp
        $pivotCol[$rank] = $col
        
        # Eliminate
        for ($row = 0; $row -lt $n; $row++) {
            if ($row -ne $rank -and $matrix[$row][$col] -eq 1) {
                for ($k = 0; $k -le $numButtons; $k++) {
                    $matrix[$row][$k] = $matrix[$row][$k] -bxor $matrix[$rank][$k]
                }
            }
        }
        $rank++
    }
    
    # Check for inconsistency
    for ($row = $rank; $row -lt $n; $row++) {
        if ($matrix[$row][$numButtons] -eq 1) {
            return [int]::MaxValue
        }
    }
    
    # Find free variables
    $pivotCols = @{}
    for ($i = 0; $i -lt $rank; $i++) {
        if ($pivotCol[$i] -ge 0) {
            $pivotCols[$pivotCol[$i]] = $true
        }
    }
    $freeVars = @()
    for ($j = 0; $j -lt $numButtons; $j++) {
        if (-not $pivotCols.ContainsKey($j)) {
            $freeVars += $j
        }
    }
    
    # Try all combinations of free variables
    $minPresses = [int]::MaxValue
    $numFree = $freeVars.Count
    
    for ($mask = 0; $mask -lt [Math]::Pow(2, $numFree); $mask++) {
        $solution = @(0) * $numButtons
        
        # Set free variables
        for ($i = 0; $i -lt $numFree; $i++) {
            $solution[$freeVars[$i]] = ($mask -shr $i) -band 1
        }
        
        # Back-substitute
        for ($row = $rank - 1; $row -ge 0; $row--) {
            $col = $pivotCol[$row]
            $val = $matrix[$row][$numButtons]
            for ($j = $col + 1; $j -lt $numButtons; $j++) {
                $val = $val -bxor ($matrix[$row][$j] * $solution[$j])
            }
            $solution[$col] = $val
        }
        
        $presses = ($solution | Measure-Object -Sum).Sum
        if ($presses -lt $minPresses) {
            $minPresses = $presses
        }
    }
    
    return $minPresses
}

$inputData = Get-Content "input.txt" -Raw
$lines = $inputData.Trim() -split "`n"

$part1 = 0
foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if ($trimmed) {
        $part1 += Solve-Machine $trimmed
    }
}
Write-Host "Day 10 Part 1: $part1"

# Part 2
$part2 = 0
Write-Host "Day 10 Part 2: $part2"