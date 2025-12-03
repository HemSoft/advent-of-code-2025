$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    
    foreach ($model in $models) {
        $rustPath = Join-Path $basePath "$dayStr\$model\rust"
        $srcPath = Join-Path $rustPath "src"
        
        # Skip if src/main.rs already exists
        if (Test-Path (Join-Path $srcPath "main.rs")) {
            Write-Host "Skipping $dayStr/$model/rust - already exists" -ForegroundColor Yellow
            continue
        }
        
        # Create directories if needed
        if (-not (Test-Path $srcPath)) {
            New-Item -ItemType Directory -Path $srcPath -Force | Out-Null
        }
        
        # Create Cargo.toml
        $cargo = @"
[package]
name = "day-$dayStr"
version = "0.1.0"
edition = "2021"

[dependencies]
"@
        Set-Content -Path (Join-Path $rustPath "Cargo.toml") -Value $cargo -NoNewline
        
        # Create src/main.rs
        $main = @"
use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    // Part 1
    let part1: i64 = 0;
    println!("Day $dayStr Part 1: {}", part1);

    // Part 2
    let part2: i64 = 0;
    println!("Day $dayStr Part 2: {}", part2);
}
"@
        Set-Content -Path (Join-Path $srcPath "main.rs") -Value $main -NoNewline
        
        # Create run.ps1
        $run = 'cargo run --release 2>$null'
        Set-Content -Path (Join-Path $rustPath "run.ps1") -Value $run -NoNewline
        
        Write-Host "Created $dayStr/$model/rust" -ForegroundColor Green
    }
}

Write-Host "`nRust scaffolding complete!" -ForegroundColor Cyan
