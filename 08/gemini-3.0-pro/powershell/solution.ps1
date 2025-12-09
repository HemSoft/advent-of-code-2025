$inputData = Get-Content "input.txt"

$points = [System.Collections.Generic.List[psobject]]::new()
foreach ($line in $inputData) {
    if (-not [string]::IsNullOrWhiteSpace($line)) {
        $parts = $line.Split(',')
        if ($parts.Count -eq 3) {
            $points.Add([PSCustomObject]@{
                x = [int]$parts[0]
                y = [int]$parts[1]
                z = [int]$parts[2]
            })
        }
    }
}

$pairs = [System.Collections.Generic.List[psobject]]::new()
$count = $points.Count
for ($i = 0; $i -lt $count; $i++) {
    for ($j = $i + 1; $j -lt $count; $j++) {
        $p1 = $points[$i]
        $p2 = $points[$j]
        $dx = [double]($p1.x - $p2.x)
        $dy = [double]($p1.y - $p2.y)
        $dz = [double]($p1.z - $p2.z)
        $distSq = $dx*$dx + $dy*$dy + $dz*$dz
        $dist = [Math]::Sqrt($distSq)
        $pairs.Add([PSCustomObject]@{
            dist = $dist
            i = $i
            j = $j
        })
    }
}

$pairsArray = $pairs.ToArray()
$pairsArray = $pairsArray | Sort-Object dist

$parent = 0..($count - 1)

function Find($i) {
    if ($parent[$i] -eq $i) {
        return $i
    }
    $parent[$i] = Find $parent[$i]
    return $parent[$i]
}

function Union($i, $j) {
    $rootI = Find $i
    $rootJ = Find $j
    if ($rootI -ne $rootJ) {
        $parent[$rootI] = $rootJ
    }
}

$limit = [Math]::Min(1000, $pairsArray.Length)
for ($k = 0; $k -lt $limit; $k++) {
    Union $pairsArray[$k].i $pairsArray[$k].j
}

$counts = @{}
for ($i = 0; $i -lt $count; $i++) {
    $root = Find $i
    if (-not $counts.ContainsKey($root)) {
        $counts[$root] = 0
    }
    $counts[$root]++
}

$sizes = $counts.Values | Sort-Object -Descending

$result = 0
if ($sizes.Count -ge 3) {
    $result = [long]$sizes[0] * [long]$sizes[1] * [long]$sizes[2]
} elseif ($sizes.Count -gt 0) {
    $result = 1
    foreach ($s in $sizes) {
        $result *= [long]$s
    }
}

Write-Host "Day 08 Part 1: $result"

# Part 2
$parent = 0..($count - 1)
$numComponents = $count
$part2Result = 0

foreach ($pair in $pairsArray) {
    $rootI = Find $pair.i
    $rootJ = Find $pair.j
    if ($rootI -ne $rootJ) {
        $parent[$rootI] = $rootJ
        $numComponents--
        if ($numComponents -eq 1) {
            $part2Result = [long]$points[$pair.i].x * [long]$points[$pair.j].x
            break
        }
    }
}

Write-Host "Day 08 Part 2: $part2Result"