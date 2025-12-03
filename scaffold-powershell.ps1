$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    
    foreach ($model in $models) {
        $psPath = Join-Path $basePath "$dayStr\$model\powershell"
        
        # Skip if solution.ps1 already exists
        if (Test-Path (Join-Path $psPath "solution.ps1")) {
            Write-Host "Skipping $dayStr/$model/powershell - already exists" -ForegroundColor Yellow
            continue
        }
        
        # Create directory if needed
        if (-not (Test-Path $psPath)) {
            New-Item -ItemType Directory -Path $psPath -Force | Out-Null
        }
        
        # Create solution.ps1
        $solution = @"
`$inputData = Get-Content "input.txt" -Raw

# Part 1
`$part1 = 0
Write-Host "Day $dayStr Part 1: `$part1"

# Part 2
`$part2 = 0
Write-Host "Day $dayStr Part 2: `$part2"
"@
        Set-Content -Path (Join-Path $psPath "solution.ps1") -Value $solution -NoNewline
        
        # Create run.ps1
        $run = '& "$PSScriptRoot/solution.ps1"'
        Set-Content -Path (Join-Path $psPath "run.ps1") -Value $run -NoNewline
        
        Write-Host "Created $dayStr/$model/powershell" -ForegroundColor Green
    }
}

Write-Host "`nPowerShell scaffolding complete!" -ForegroundColor Cyan
