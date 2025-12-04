$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")

    foreach ($model in $models) {
        $rhmPath = Join-Path $basePath "$dayStr\$model\rhombus"

        # Skip if solution already exists
        if (Test-Path (Join-Path $rhmPath "solution.rhm")) {
            Write-Host "Skipping $dayStr/$model/rhombus - already exists" -ForegroundColor Yellow
            continue
        }

        # Create directory if needed
        if (-not (Test-Path $rhmPath)) {
            New-Item -ItemType Directory -Path $rhmPath -Force | Out-Null
        }

        # Create solution.rhm
        $solution = @"
#lang rhombus/static

fun main():
  def input = filesystem.read_file("input.txt").trim()

  // Part 1
  def part1 = 0
  println("Day $dayStr Part 1: " ++ to_string(part1))

  // Part 2
  def part2 = 0
  println("Day $dayStr Part 2: " ++ to_string(part2))

main()
"@
        Set-Content -Path (Join-Path $rhmPath "solution.rhm") -Value $solution -NoNewline

        # Create run.ps1
        $run = 'racket solution.rhm'
        Set-Content -Path (Join-Path $rhmPath "run.ps1") -Value $run -NoNewline

        Write-Host "Created $dayStr/$model/rhombus" -ForegroundColor Green
    }
}

Write-Host "`nRhombus scaffolding complete!" -ForegroundColor Cyan
