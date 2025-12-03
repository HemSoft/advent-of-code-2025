# new-day.ps1 - Creates a new Advent of Code challenge folder

$existingDays = Get-ChildItem -Directory -Path $PSScriptRoot |
    Where-Object { $_.Name -match '^\d{2}$' -and $_.Name -ne '00' } |
    ForEach-Object { [int]$_.Name }

$nextDay = if ($existingDays.Count -eq 0) { 1 } else { ($existingDays | Measure-Object -Maximum).Maximum + 1 }
$dayFolder = $nextDay.ToString().PadLeft(2, '0')

$sourcePath = Join-Path $PSScriptRoot "00"
$destPath = Join-Path $PSScriptRoot $dayFolder

if (Test-Path $destPath) {
    Write-Error "Day $dayFolder already exists!"
    exit 1
}

Copy-Item -Path $sourcePath -Destination $destPath -Recurse

# Rename csproj to day-specific name
$oldCsproj = Join-Path $destPath "dotnet\advent-of-code-2025.csproj"
$newCsproj = Join-Path $destPath "dotnet\day-$dayFolder.csproj"
if (Test-Path $oldCsproj) {
    Rename-Item -Path $oldCsproj -NewName "day-$dayFolder.csproj"
}

# Update day number in Program.cs (now in dotnet subfolder)
$programPath = Join-Path $destPath "dotnet\Program.cs"
$content = Get-Content $programPath -Raw
$content = $content -replace 'Day XX', "Day $dayFolder"
Set-Content -Path $programPath -Value $content -NoNewline

Write-Host "Created Day $dayFolder in $destPath" -ForegroundColor Green
