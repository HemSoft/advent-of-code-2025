$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    
    foreach ($model in $models) {
        $goPath = Join-Path $basePath "$dayStr\$model\go"
        
        # Skip if main.go already exists
        if (Test-Path (Join-Path $goPath "main.go")) {
            Write-Host "Skipping $dayStr/$model/go - already exists" -ForegroundColor Yellow
            continue
        }
        
        # Create directory if needed
        if (-not (Test-Path $goPath)) {
            New-Item -ItemType Directory -Path $goPath -Force | Out-Null
        }
        
        # Create main.go
        $main = @"
package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, _ := os.ReadFile("input.txt")
	input := strings.TrimSpace(string(data))
	_ = input

	// Part 1
	var part1 int64 = 0
	fmt.Printf("Day $dayStr Part 1: %d\n", part1)

	// Part 2
	var part2 int64 = 0
	fmt.Printf("Day $dayStr Part 2: %d\n", part2)
}
"@
        Set-Content -Path (Join-Path $goPath "main.go") -Value $main -NoNewline
        
        # Create run.ps1
        $run = "go run main.go"
        Set-Content -Path (Join-Path $goPath "run.ps1") -Value $run -NoNewline
        
        Write-Host "Created $dayStr/$model/go" -ForegroundColor Green
    }
}

Write-Host "`nGo scaffolding complete!" -ForegroundColor Cyan
