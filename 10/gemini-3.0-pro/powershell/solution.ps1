$inputContent = Get-Content "input.txt" -Raw

function Solve-Part1 ($line) {
    if ($line -match '\[([.#]+)\]') {
        $targetStr = $matches[1]
        $L = $targetStr.Length
        $target = [int[]]::new($L)
        for ($i = 0; $i -lt $L; $i++) {
            $target[$i] = if ($targetStr[$i] -eq '#') { 1 } else { 0 }
        }

        $buttons = [System.Collections.Generic.List[int[]]]::new()
        $buttonMatches = [regex]::Matches($line, '\(([\d,]+)\)')
        foreach ($bm in $buttonMatches) {
            $b = [int[]]::new($L)
            $parts = $bm.Groups[1].Value -split ','
            foreach ($p in $parts) {
                if ([int]::TryParse($p, [ref]$null)) {
                    $idx = [int]$p
                    if ($idx -lt $L) { $b[$idx] = 1 }
                }
            }
            $buttons.Add($b)
        }

        $B = $buttons.Count
        $M = New-Object 'int[,]' $L, ($B + 1)
        for ($r = 0; $r -lt $L; $r++) {
            for ($c = 0; $c -lt $B; $c++) {
                $M[$r, $c] = $buttons[$c][$r]
            }
            $M[$r, $B] = $target[$r]
        }

        $pivotRow = 0
        $pivotCols = [System.Collections.Generic.List[int]]::new()
        $colToPivotRow = [int[]]::new($B)
        for ($i = 0; $i -lt $B; $i++) { $colToPivotRow[$i] = -1 }

        for ($c = 0; $c -lt $B -and $pivotRow -lt $L; $c++) {
            $sel = -1
            for ($r = $pivotRow; $r -lt $L; $r++) {
                if ($M[$r, $c] -eq 1) {
                    $sel = $r
                    break
                }
            }

            if ($sel -eq -1) { continue }

            # Swap
            for ($k = 0; $k -le $B; $k++) {
                $temp = $M[$pivotRow, $k]
                $M[$pivotRow, $k] = $M[$sel, $k]
                $M[$sel, $k] = $temp
            }

            # Eliminate
            for ($r = 0; $r -lt $L; $r++) {
                if ($r -ne $pivotRow -and $M[$r, $c] -eq 1) {
                    for ($k = $c; $k -le $B; $k++) {
                        $M[$r, $k] = $M[$r, $k] -bxor $M[$pivotRow, $k]
                    }
                }
            }

            $pivotCols.Add($c)
            $colToPivotRow[$c] = $pivotRow
            $pivotRow++
        }

        # Check consistency
        for ($r = $pivotRow; $r -lt $L; $r++) {
            if ($M[$r, $B] -eq 1) { return 0 }
        }

        $freeCols = [System.Collections.Generic.List[int]]::new()
        for ($c = 0; $c -lt $B; $c++) {
            if (-not $pivotCols.Contains($c)) { $freeCols.Add($c) }
        }

        $minPresses = [long]::MaxValue
        $numFree = $freeCols.Count
        $combinations = [long][Math]::Pow(2, $numFree)

        for ($i = 0; $i -lt $combinations; $i++) {
            $x = [int[]]::new($B)
            $currentPresses = 0

            for ($k = 0; $k -lt $numFree; $k++) {
                if (($i -band ([long]1 -shl $k)) -ne 0) {
                    $x[$freeCols[$k]] = 1
                    $currentPresses++
                }
            }

            foreach ($pCol in $pivotCols) {
                $r = $colToPivotRow[$pCol]
                $val = $M[$r, $B]
                foreach ($fCol in $freeCols) {
                    if ($M[$r, $fCol] -eq 1 -and $x[$fCol] -eq 1) {
                        $val = $val -bxor 1
                    }
                }
                $x[$pCol] = $val
                if ($val -eq 1) { $currentPresses++ }
            }

            if ($currentPresses -lt $minPresses) {
                $minPresses = $currentPresses
            }
        }
        return $minPresses
    }
    return 0
}

function Solve-Part2 ($line) {
    if ($line -match '\{([\d,]+)\}') {
        $targetParts = $matches[1] -split ','
        $L = $targetParts.Count
        $b = [double[]]::new($L)
        for ($i=0; $i -lt $L; $i++) { $b[$i] = [double]$targetParts[$i] }

        $A_cols = [System.Collections.Generic.List[double[]]]::new()
        $buttonMatches = [regex]::Matches($line, '\(([\d,]+)\)')
        foreach ($bm in $buttonMatches) {
            $col = [double[]]::new($L)
            $parts = $bm.Groups[1].Value -split ','
            foreach ($p in $parts) {
                if ([int]::TryParse($p, [ref]$null)) {
                    $idx = [int]$p
                    if ($idx -lt $L) { $col[$idx] = 1.0 }
                }
            }
            $A_cols.Add($col)
        }

        $B_count = $A_cols.Count
        $matrix = New-Object 'double[,]' $L, ($B_count + 1)
        for ($r = 0; $r -lt $L; $r++) {
            for ($c = 0; $c -lt $B_count; $c++) {
                $matrix[$r, $c] = $A_cols[$c][$r]
            }
            $matrix[$r, $B_count] = $b[$r]
        }

        $pivotRow = 0
        $pivotCols = [System.Collections.Generic.List[int]]::new()
        $colToPivotRow = [int[]]::new($B_count)
        for ($i=0; $i -lt $B_count; $i++) { $colToPivotRow[$i] = -1 }

        for ($c = 0; $c -lt $B_count -and $pivotRow -lt $L; $c++) {
            $sel = -1
            for ($r = $pivotRow; $r -lt $L; $r++) {
                if ([Math]::Abs($matrix[$r, $c]) -gt 1e-9) {
                    $sel = $r
                    break
                }
            }

            if ($sel -eq -1) { continue }

            # Swap
            for ($k = $c; $k -le $B_count; $k++) {
                $temp = $matrix[$pivotRow, $k]
                $matrix[$pivotRow, $k] = $matrix[$sel, $k]
                $matrix[$sel, $k] = $temp
            }

            # Normalize
            $pivotVal = $matrix[$pivotRow, $c]
            for ($k = $c; $k -le $B_count; $k++) { $matrix[$pivotRow, $k] /= $pivotVal }

            # Eliminate
            for ($r = 0; $r -lt $L; $r++) {
                if ($r -ne $pivotRow -and [Math]::Abs($matrix[$r, $c]) -gt 1e-9) {
                    $factor = $matrix[$r, $c]
                    for ($k = $c; $k -le $B_count; $k++) { $matrix[$r, $k] -= $factor * $matrix[$pivotRow, $k] }
                }
            }

            $pivotCols.Add($c)
            $colToPivotRow[$c] = $pivotRow
            $pivotRow++
        }

        for ($r = $pivotRow; $r -lt $L; $r++) {
            if ([Math]::Abs($matrix[$r, $B_count]) -gt 1e-9) { return 0 }
        }

        $freeCols = [System.Collections.Generic.List[int]]::new()
        for ($c = 0; $c -lt $B_count; $c++) {
            if (-not $pivotCols.Contains($c)) { $freeCols.Add($c) }
        }

        $UBs = [long[]]::new($B_count)
        for ($c = 0; $c -lt $B_count; $c++) {
            $minUb = [long]::MaxValue
            $bounded = $false
            for ($r = 0; $r -lt $L; $r++) {
                if ($A_cols[$c][$r] -gt 0.5) {
                    $val = [long]($targetParts[$r] / $A_cols[$c][$r])
                    if ($val -lt $minUb) { $minUb = $val }
                    $bounded = $true
                }
            }
            $UBs[$c] = if ($bounded) { $minUb } else { 0 }
        }

        $state = @{ min = [long]::MaxValue; found = $false }

        function Search ($freeIdx, $currentFreeVals) {
            if ($freeIdx -eq $freeCols.Count) {
                $currentPresses = 0
                foreach ($v in $currentFreeVals) { $currentPresses += $v }
                
                $possible = $true
                
                for ($i = 0; $i -lt $pivotCols.Count; $i++) {
                    $pCol = $pivotCols[$i]
                    $r = $colToPivotRow[$pCol]
                    $val = $matrix[$r, $B_count]
                    for ($j = 0; $j -lt $freeCols.Count; $j++) {
                        $fCol = $freeCols[$j]
                        $val -= $matrix[$r, $fCol] * $currentFreeVals[$j]
                    }

                    if ($val -lt -1e-9) { $possible = $false; break }
                    $longVal = [long][Math]::Round($val)
                    if ([Math]::Abs($val - $longVal) -gt 1e-9) { $possible = $false; break }
                    
                    $currentPresses += $longVal
                }

                if ($possible) {
                    if ($currentPresses -lt $state.min) {
                        $state.min = $currentPresses
                        $state.found = $true
                    }
                }
                return
            }

            $fColIdx = $freeCols[$freeIdx]
            $limit = $UBs[$fColIdx]
            
            for ($val = 0; $val -le $limit; $val++) {
                $currentFreeVals[$freeIdx] = $val
                Search ($freeIdx + 1) $currentFreeVals
            }
        }

        Search 0 ([long[]]::new($freeCols.Count))

        if ($state.found) { return $state.min } else { return 0 }
    }
    return 0
}

$totalPressesPart1 = 0
$totalPressesPart2 = 0

foreach ($line in ($inputContent -split "`n")) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $totalPressesPart1 += Solve-Part1 $line
    $totalPressesPart2 += Solve-Part2 $line
}

Write-Host "Day 10 Part 1: $totalPressesPart1"
Write-Host "Day 10 Part 2: $totalPressesPart2"

