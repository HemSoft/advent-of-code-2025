$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    
    foreach ($model in $models) {
        $pyPath = Join-Path $basePath "$dayStr\$model\python"
        
        # Skip if solution.py already exists
        if (Test-Path (Join-Path $pyPath "solution.py")) {
            Write-Host "Skipping $dayStr/$model/python - already exists" -ForegroundColor Yellow
            continue
        }
        
        # Create directory if needed
        if (-not (Test-Path $pyPath)) {
            New-Item -ItemType Directory -Path $pyPath -Force | Out-Null
        }
        
        # Create solution.py
        $solution = @"
with open("input.txt") as f:
    input_data = f.read().strip()

# Part 1
part1 = 0
print(f"Day $dayStr Part 1: {part1}")

# Part 2
part2 = 0
print(f"Day $dayStr Part 2: {part2}")
"@
        Set-Content -Path (Join-Path $pyPath "solution.py") -Value $solution -NoNewline
        
        # Create run.ps1
        $run = "python solution.py"
        Set-Content -Path (Join-Path $pyPath "run.ps1") -Value $run -NoNewline
        
        Write-Host "Created $dayStr/$model/python" -ForegroundColor Green
    }
}

Write-Host "`nPython scaffolding complete!" -ForegroundColor Cyan
