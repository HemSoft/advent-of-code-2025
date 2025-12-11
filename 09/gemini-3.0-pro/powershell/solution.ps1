$content = Get-Content -Path "input.txt"
$points = [System.Collections.Generic.List[psobject]]::new()

foreach ($line in $content) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line.Split(',')
    $points.Add([PSCustomObject]@{
        x = [long]$parts[0]
        y = [long]$parts[1]
    })
}

$edges = [System.Collections.Generic.List[psobject]]::new()
$n = $points.Count
for ($i = 0; $i -lt $n; $i++) {
    $edges.Add([PSCustomObject]@{
        p1 = $points[$i]
        p2 = $points[($i + 1) % $n]
    })
}

function Test-PointInPolygon {
    param ($x, $y)
    $inside = $false
    foreach ($edge in $edges) {
        $p1 = $edge.p1
        $p2 = $edge.p2
        if (($p1.y -gt $y) -ne ($p2.y -gt $y)) {
            $intersectX = ($p2.x - $p1.x) * ($y - $p1.y) / ($p2.y - $p1.y) + $p1.x
            if ($x -lt $intersectX) {
                $inside = -not $inside
            }
        }
    }
    return $inside
}

function Test-IsValid {
    param ($p1, $p2)
    $x1 = [Math]::Min($p1.x, $p2.x)
    $x2 = [Math]::Max($p1.x, $p2.x)
    $y1 = [Math]::Min($p1.y, $p2.y)
    $y2 = [Math]::Max($p1.y, $p2.y)

    $cx = ($x1 + $x2) / 2.0
    $cy = ($y1 + $y2) / 2.0

    if (-not (Test-PointInPolygon $cx $cy)) {
        return $false
    }

    foreach ($edge in $edges) {
        $ep1 = $edge.p1
        $ep2 = $edge.p2

        if ($ep1.x -eq $ep2.x) { # Vertical
            $ex = $ep1.x
            $eyMin = [Math]::Min($ep1.y, $ep2.y)
            $eyMax = [Math]::Max($ep1.y, $ep2.y)
            if ($x1 -lt $ex -and $ex -lt $x2) {
                $overlapMin = [Math]::Max($y1, $eyMin)
                $overlapMax = [Math]::Min($y2, $eyMax)
                if ($overlapMin -lt $overlapMax) {
                    return $false
                }
            }
        } elseif ($ep1.y -eq $ep2.y) { # Horizontal
            $ey = $ep1.y
            $exMin = [Math]::Min($ep1.x, $ep2.x)
            $exMax = [Math]::Max($ep1.x, $ep2.x)
            if ($y1 -lt $ey -and $ey -lt $y2) {
                $overlapMin = [Math]::Max($x1, $exMin)
                $overlapMax = [Math]::Min($x2, $exMax)
                if ($overlapMin -lt $overlapMax) {
                    return $false
                }
            }
        }
    }
    return $true
}

$maxAreaPart1 = [long]0
$maxAreaPart2 = [long]0

for ($i = 0; $i -lt $points.Count; $i++) {
    for ($j = $i + 1; $j -lt $points.Count; $j++) {
        $p1 = $points[$i]
        $p2 = $points[$j]

        $width = [Math]::Abs($p1.x - $p2.x) + 1
        $height = [Math]::Abs($p1.y - $p2.y) + 1
        $area = $width * $height

        if ($area -gt $maxAreaPart1) {
            $maxAreaPart1 = $area
        }

        if (Test-IsValid $p1 $p2) {
            if ($area -gt $maxAreaPart2) {
                $maxAreaPart2 = $area
            }
        }
    }
}

Write-Host "Day 09 Part 1: $maxAreaPart1"
Write-Host "Day 09 Part 2: $maxAreaPart2"
