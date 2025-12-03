$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    
    foreach ($model in $models) {
        $tsPath = Join-Path $basePath "$dayStr\$model\typescript"
        
        # Skip if solution.ts already exists
        if (Test-Path (Join-Path $tsPath "solution.ts")) {
            Write-Host "Skipping $dayStr/$model/typescript - already exists" -ForegroundColor Yellow
            continue
        }
        
        # Create directory if needed
        if (-not (Test-Path $tsPath)) {
            New-Item -ItemType Directory -Path $tsPath -Force | Out-Null
        }
        
        # Create solution.ts
        $solution = @"
import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();

// Part 1
let part1 = 0;
console.log(`Day $dayStr Part 1: `${part1}`);

// Part 2
let part2 = 0;
console.log(`Day $dayStr Part 2: `${part2}`);
"@
        Set-Content -Path (Join-Path $tsPath "solution.ts") -Value $solution -NoNewline
        
        # Create run.ps1
        $run = "npx tsx solution.ts"
        Set-Content -Path (Join-Path $tsPath "run.ps1") -Value $run -NoNewline
        
        Write-Host "Created $dayStr/$model/typescript" -ForegroundColor Green
    }
}

Write-Host "`nTypeScript scaffolding complete!" -ForegroundColor Cyan
