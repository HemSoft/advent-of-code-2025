$lines = Get-Content "input.txt" | Where-Object { $_ -match '\S' }

$tiles = @()
foreach ($line in $lines) {
    $parts = $line.Split(',')
    $tiles += @{
        x = [long]$parts[0]
        y = [long]$parts[1]
    }
}

# Part 1
$maxArea = [long]0
for ($i = 0; $i -lt $tiles.Count; $i++) {
    for ($j = $i + 1; $j -lt $tiles.Count; $j++) {
        $width = [Math]::Abs($tiles[$j].x - $tiles[$i].x) + 1
        $height = [Math]::Abs($tiles[$j].y - $tiles[$i].y) + 1
        $area = $width * $height
        if ($area -gt $maxArea) { $maxArea = $area }
    }
}
Write-Host "Day 09 Part 1: $maxArea"

# Part 2
$edges = @()
for ($i = 0; $i -lt $tiles.Count; $i++) {
    $curr = $tiles[$i]
    $next = $tiles[($i + 1) % $tiles.Count]
    $edges += @{ p1 = $curr; p2 = $next }
}

$tilesSet = @{}
foreach ($t in $tiles) { $tilesSet["$($t.x),$($t.y)"] = $true }

function IsOnSegment($px, $py, $x1, $y1, $x2, $y2) {
    if ($x1 -eq $x2) { return $px -eq $x1 -and $py -ge [Math]::Min($y1, $y2) -and $py -le [Math]::Max($y1, $y2) }
    if ($y1 -eq $y2) { return $py -eq $y1 -and $px -ge [Math]::Min($x1, $x2) -and $px -le [Math]::Max($x1, $x2) }
    return $false
}

function IsInsidePolygon($px, $py, $edges) {
    $crossings = 0
    foreach ($e in $edges) {
        $x1 = $e.p1.x; $y1 = $e.p1.y; $x2 = $e.p2.x; $y2 = $e.p2.y
        if (($y1 -le $py -and $y2 -gt $py) -or ($y2 -le $py -and $y1 -gt $py)) {
            $xIntersect = $x1 + ($py - $y1) / ($y2 - $y1) * ($x2 - $x1)
            if ($px -lt $xIntersect) { $crossings++ }
        }
    }
    return ($crossings % 2) -eq 1
}

function IsValidPoint($px, $py, $edges, $tilesSet) {
    if ($tilesSet["$px,$py"]) { return $true }
    foreach ($e in $edges) {
        if (IsOnSegment $px $py $e.p1.x $e.p1.y $e.p2.x $e.p2.y) { return $true }
    }
    return IsInsidePolygon $px $py $edges
}

function Direction($x1, $y1, $x2, $y2, $x3, $y3) {
    return ($x3 - $x1) * ($y2 - $y1) - ($x2 - $x1) * ($y3 - $y1)
}

function SegmentsIntersect($ax1, $ay1, $ax2, $ay2, $bx1, $by1, $bx2, $by2) {
    $d1 = Direction $bx1 $by1 $bx2 $by2 $ax1 $ay1
    $d2 = Direction $bx1 $by1 $bx2 $by2 $ax2 $ay2
    $d3 = Direction $ax1 $ay1 $ax2 $ay2 $bx1 $by1
    $d4 = Direction $ax1 $ay1 $ax2 $ay2 $bx2 $by2
    return (($d1 -gt 0 -and $d2 -lt 0) -or ($d1 -lt 0 -and $d2 -gt 0)) -and (($d3 -gt 0 -and $d4 -lt 0) -or ($d3 -lt 0 -and $d4 -gt 0))
}

function GetIntersection($ax1, $ay1, $ax2, $ay2, $bx1, $by1, $bx2, $by2) {
    $d = ($ax2 - $ax1) * ($by2 - $by1) - ($ay2 - $ay1) * ($bx2 - $bx1)
    if ([Math]::Abs($d) -lt 1e-10) { return $null }
    $t = (($bx1 - $ax1) * ($by2 - $by1) - ($by1 - $ay1) * ($bx2 - $bx1)) / $d
    return @{ x = $ax1 + $t * ($ax2 - $ax1); y = $ay1 + $t * ($ay2 - $ay1) }
}

function EdgeCrossesRectInterior($x1, $y1, $x2, $y2, $minX, $maxX, $minY, $maxY) {
    $p1Inside = $x1 -ge $minX -and $x1 -le $maxX -and $y1 -ge $minY -and $y1 -le $maxY
    $p2Inside = $x2 -ge $minX -and $x2 -le $maxX -and $y2 -ge $minY -and $y2 -le $maxY
    if ($p1Inside -and $p2Inside) { return $false }

    $rectEdges = @(
        @($minX, $minY, $maxX, $minY),
        @($minX, $maxY, $maxX, $maxY),
        @($minX, $minY, $minX, $maxY),
        @($maxX, $minY, $maxX, $maxY)
    )

    for ($i = 0; $i -lt 4; $i++) {
        $re = $rectEdges[$i]
        if (SegmentsIntersect $x1 $y1 $x2 $y2 $re[0] $re[1] $re[2] $re[3]) {
            $intersect = GetIntersection $x1 $y1 $x2 $y2 $re[0] $re[1] $re[2] $re[3]
            if ($null -ne $intersect) {
                if ($i -lt 2) {
                    if ($intersect.x -gt $minX -and $intersect.x -lt $maxX) { return $true }
                } else {
                    if ($intersect.y -gt $minY -and $intersect.y -lt $maxY) { return $true }
                }
            }
        }
    }
    return $false
}

function IsRectangleValid($minX, $maxX, $minY, $maxY, $edges) {
    foreach ($e in $edges) {
        if (EdgeCrossesRectInterior $e.p1.x $e.p1.y $e.p2.x $e.p2.y $minX $maxX $minY $maxY) { return $false }
    }
    return $true
}

$maxArea2 = [long]0
for ($i = 0; $i -lt $tiles.Count; $i++) {
    for ($j = $i + 1; $j -lt $tiles.Count; $j++) {
        $t1 = $tiles[$i]; $t2 = $tiles[$j]
        $minX = [Math]::Min($t1.x, $t2.x); $maxX = [Math]::Max($t1.x, $t2.x)
        $minY = [Math]::Min($t1.y, $t2.y); $maxY = [Math]::Max($t1.y, $t2.y)

        $corners = @(@{x=$minX;y=$minY}, @{x=$minX;y=$maxY}, @{x=$maxX;y=$minY}, @{x=$maxX;y=$maxY})
        $allValid = $true
        foreach ($c in $corners) {
            if (-not (IsValidPoint $c.x $c.y $edges $tilesSet)) { $allValid = $false; break }
        }

        if ($allValid -and (IsRectangleValid $minX $maxX $minY $maxY $edges)) {
            $area = ($maxX - $minX + 1) * ($maxY - $minY + 1)
            if ($area -gt $maxArea2) { $maxArea2 = $area }
        }
    }
}
Write-Host "Day 09 Part 2: $maxArea2"