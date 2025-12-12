
class Point {
    [int]$r
    [int]$c
    Point([int]$r, [int]$c) {
        $this.r = $r
        $this.c = $c
    }
}

class AnchoredShape {
    [Point[]]$points
}

class RegionTask {
    [int]$w
    [int]$h
    [int[]]$counts
}

class SolverContext {
    [int]$w
    [int]$h
    [System.Collections.Generic.Dictionary[int, int]]$counts
    [int[]]$types
    [System.Collections.Generic.Dictionary[int, AnchoredShape[]]]$anchoredShapes
}

$inputFile = "input.txt"
if ($args.Count -gt 0) {
    $inputFile = $args[0]
}

if (-not (Test-Path $inputFile)) {
    Write-Host "Input file $inputFile not found."
    exit
}

$content = Get-Content $inputFile -Raw
$content = $content -replace "\r\n", "`n"
$parts = $content -split "`n`n"

$shapes = [System.Collections.Generic.Dictionary[int, Point[][]]]::new()
$regions = [System.Collections.Generic.List[RegionTask]]::new()

function Parse-Shape {
    param($lines, $shapes)
    $header = $lines[0].Trim().TrimEnd(":")
    $id = [int]$header
    
    $points = [System.Collections.Generic.HashSet[string]]::new()
    for ($r = 1; $r -lt $lines.Count; $r++) {
        for ($c = 0; $c -lt $lines[$r].Length; $c++) {
            if ($lines[$r][$c] -eq '#') {
                $p = [Point]::new($r - 1, $c)
                [void]$points.Add("$($p.r),$($p.c)")
            }
        }
    }
    
    $shapes[$id] = Generate-Variations $points
}

function Parse-Region {
    param($line, $regions)
    $p = $line -split ":"
    $dims = $p[0] -split "x"
    $w = [int]$dims[0]
    $h = [int]$dims[1]
    
    $countStrs = $p[1].Trim() -split "\s+"
    $counts = @()
    foreach ($s in $countStrs) {
        $counts += [int]$s
    }
    
    $task = [RegionTask]::new()
    $task.w = $w
    $task.h = $h
    $task.counts = $counts
    [void]$regions.Add($task)
}

function Generate-Variations {
    param($originalSet) # HashSet<string> of "r,c"
    
    $variations = [System.Collections.Generic.List[Point[]]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    
    # Convert back to Point objects for manipulation
    $current = [System.Collections.Generic.List[Point]]::new()
    foreach ($s in $originalSet) {
        $parts = $s -split ","
        $current.Add([Point]::new([int]$parts[0], [int]$parts[1]))
    }
    
    for ($i = 0; $i -lt 2; $i++) { # Flip
        for ($j = 0; $j -lt 4; $j++) { # Rotate
            $normalized = Normalize $current
            $key = Points-ToString $normalized
            if (-not $seen.Contains($key)) {
                [void]$variations.Add($normalized)
                [void]$seen.Add($key)
            }
            $current = Rotate $current
        }
        $current = Flip $originalSet
    }
    return $variations.ToArray()
}

function Rotate {
    param($points)
    $newPoints = [System.Collections.Generic.List[Point]]::new()
    foreach ($p in $points) {
        $newPoints.Add([Point]::new($p.c, -$p.r))
    }
    return $newPoints
}

function Flip {
    param($originalSet)
    $newPoints = [System.Collections.Generic.List[Point]]::new()
    foreach ($s in $originalSet) {
        $parts = $s -split ","
        $r = [int]$parts[0]
        $c = [int]$parts[1]
        $newPoints.Add([Point]::new($r, -$c))
    }
    return $newPoints
}

function Normalize {
    param($points)
    if ($points.Count -eq 0) { return @() }
    
    $minR = 1000000
    $minC = 1000000
    foreach ($p in $points) {
        if ($p.r -lt $minR) { $minR = $p.r }
        if ($p.c -lt $minC) { $minC = $p.c }
    }
    
    $res = [System.Collections.Generic.List[Point]]::new()
    foreach ($p in $points) {
        $res.Add([Point]::new($p.r - $minR, $p.c - $minC))
    }
    
    # Sort
    $res.Sort({
        if ($args[0].r -ne $args[1].r) { return $args[0].r - $args[1].r }
        return $args[0].c - $args[1].c
    })
    
    return $res.ToArray()
}

function Points-ToString {
    param($points)
    $sb = [System.Text.StringBuilder]::new()
    foreach ($p in $points) {
        [void]$sb.Append("$($p.r),$($p.c);")
    }
    return $sb.ToString()
}

function Solve-Region {
    param($region, $shapes)
    
    $presents = [System.Collections.Generic.List[int]]::new()
    $totalArea = 0
    for ($i = 0; $i -lt $region.counts.Length; $i++) {
        $count = $region.counts[$i]
        for ($j = 0; $j -lt $count; $j++) {
            [void]$presents.Add($i)
            $totalArea += $shapes[$i][0].Length
        }
    }
    
    if ($totalArea -gt ($region.w * $region.h)) {
        return $false
    }
    
    $maxSkips = ($region.w * $region.h) - $totalArea
    $grid = [bool[]]::new($region.w * $region.h)
    
    $presentTypesMap = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($p in $presents) { [void]$presentTypesMap.Add($p) }
    
    $presentTypes = [System.Linq.Enumerable]::ToArray($presentTypesMap)
    
    # Sort types by size descending
    [Array]::Sort($presentTypes, [System.Collections.Generic.Comparer[int]]::Create({
        param($x, $y)
        return $shapes[$y][0].Length - $shapes[$x][0].Length
    }))
    
    $counts = [System.Collections.Generic.Dictionary[int, int]]::new()
    foreach ($p in $presents) {
        if (-not $counts.ContainsKey($p)) { $counts[$p] = 0 }
        $counts[$p]++
    }
    
    $anchoredShapes = [System.Collections.Generic.Dictionary[int, AnchoredShape[]]]::new()
    foreach ($typeID in $presentTypes) {
        $list = [System.Collections.Generic.List[AnchoredShape]]::new()
        foreach ($v in $shapes[$typeID]) {
            $anchor = $v[0]
            $points = [System.Collections.Generic.List[Point]]::new()
            foreach ($p in $v) {
                $points.Add([Point]::new($p.r - $anchor.r, $p.c - $anchor.c))
            }
            $as = [AnchoredShape]::new()
            $as.points = $points.ToArray()
            [void]$list.Add($as)
        }
        $anchoredShapes[$typeID] = $list.ToArray()
    }
    
    $ctx = [SolverContext]::new()
    $ctx.w = $region.w
    $ctx.h = $region.h
    $ctx.counts = $counts
    $ctx.types = $presentTypes
    $ctx.anchoredShapes = $anchoredShapes
    
    return Backtrack 0 $grid $ctx $maxSkips
}

function Backtrack {
    param($idx, $grid, $ctx, $skipsLeft)
    
    while ($idx -lt $grid.Length -and $grid[$idx]) {
        $idx++
    }
    
    if ($idx -eq $grid.Length) {
        foreach ($kvp in $ctx.counts) {
            if ($kvp.Value -gt 0) { return $false }
        }
        return $true
    }
    
    $r = [Math]::Floor($idx / $ctx.w)
    $c = $idx % $ctx.w
    
    foreach ($typeID in $ctx.types) {
        if ($ctx.counts[$typeID] -gt 0) {
            $variations = $ctx.anchoredShapes[$typeID]
            foreach ($shape in $variations) {
                $fits = $true
                foreach ($pt in $shape.points) {
                    $pr = $r + $pt.r
                    $pc = $c + $pt.c
                    if ($pr -lt 0 -or $pr -ge $ctx.h -or $pc -lt 0 -or $pc -ge $ctx.w) {
                        $fits = $false
                        break
                    }
                    if ($grid[$pr * $ctx.w + $pc]) {
                        $fits = $false
                        break
                    }
                }
                
                if ($fits) {
                    foreach ($pt in $shape.points) {
                        $grid[($r + $pt.r) * $ctx.w + ($c + $pt.c)] = $true
                    }
                    $ctx.counts[$typeID]--
                    
                    if (Backtrack ($idx + 1) $grid $ctx $skipsLeft) {
                        return $true
                    }
                    
                    $ctx.counts[$typeID]++
                    foreach ($pt in $shape.points) {
                        $grid[($r + $pt.r) * $ctx.w + ($c + $pt.c)] = $false
                    }
                }
            }
        }
    }
    
    if ($skipsLeft -gt 0) {
        $grid[$idx] = $true
        if (Backtrack ($idx + 1) $grid $ctx ($skipsLeft - 1)) {
            return $true
        }
        $grid[$idx] = $false
    }
    
    return $false
}

foreach ($part in $parts) {
    $lines = $part.Trim() -split "`n"
    if ($lines.Count -eq 0) { continue }
    
    if ($lines[0] -match ":") {
        if ($lines[0] -match "x") { # Region
            foreach ($line in $lines) {
                if ($line.Trim() -ne "") {
                    Parse-Region $line $regions
                }
            }
        } else { # Shape
            Parse-Shape $lines $shapes
        }
    }
}

$solvedCount = 0
foreach ($region in $regions) {
    if (Solve-Region $region $shapes) {
        $solvedCount++
    }
}

Write-Host "Day 12 Part 1: $solvedCount"
# Write-Host "Day 12 Part 2: 0"

