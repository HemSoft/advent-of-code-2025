$lines = Get-Content "input.txt"
$rows = $lines.Count
$cols = if ($rows -gt 0) { $lines[0].Length } else { 0 }

$grid = New-Object 'char[][]' $rows, $cols
for ($i = 0; $i -lt $rows; $i++) {
    $grid[$i] = $lines[$i].ToCharArray()
}

$totalRemoved = 0
$iteration = 0

while ($true) {
    $iteration++
    $toRemove = @()

    for ($r = 0; $r -lt $rows; $r++) {
        for ($c = 0; $c -lt $cols; $c++) {
            if ($grid[$r][$c] -eq '@') {
                $neighborCount = 0
                for ($dr = -1; $dr -le 1; $dr++) {
                    for ($dc = -1; $dc -le 1; $dc++) {
                        if ($dr -eq 0 -and $dc -eq 0) { continue }

                        $nr = $r + $dr
                        $nc = $c + $dc

                        if ($nr -ge 0 -and $nr -lt $rows -and $nc -ge 0 -and $nc -lt $cols) {
                            if ($grid[$nr][$nc] -eq '@') {
                                $neighborCount++
                            }
                        }
                    }
                }

                if ($neighborCount -lt 4) {
                    $toRemove += ,@($r, $c)
                }
            }
        }
    }

    if ($toRemove.Count -eq 0) {
        break
    }

    if ($iteration -eq 1) {
        Write-Host "Day 04 Part 1: $($toRemove.Count)"
    }

    $totalRemoved += $toRemove.Count

    foreach ($coords in $toRemove) {
        $grid[$coords[0]][$coords[1]] = '.'
    }
}

Write-Host "Day 04 Part 2: $totalRemoved"
