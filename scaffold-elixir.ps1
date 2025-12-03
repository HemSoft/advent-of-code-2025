$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    $dayModule = "Day_" + $dayStr
    $dayModuleLower = ("day_" + $dayStr).ToLower()

    foreach ($model in $models) {
        $exPath = Join-Path $basePath "$dayStr\$model\elixir"
        $libPath = Join-Path $exPath "lib"

        # Skip if main module already exists
        if (Test-Path (Join-Path $libPath "$dayModuleLower.ex")) {
            Write-Host "Skipping $dayStr/$model/elixir - already exists" -ForegroundColor Yellow
            continue
        }

        # Create directories if needed
        if (-not (Test-Path $libPath)) {
            New-Item -ItemType Directory -Path $libPath -Force | Out-Null
        }

        # Create mix.exs
        $mix = @"
defmodule $dayModule.MixProject do
  use Mix.Project

  def project do
    [
      app: :$dayModuleLower,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
"@
        Set-Content -Path (Join-Path $exPath "mix.exs") -Value $mix -NoNewline

        # Create lib/day_xx.ex
        $module = @"
defmodule $dayModule do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    # Part 1
    part1 = 0
    IO.puts("Day $dayStr Part 1: #{part1}")

    # Part 2
    part2 = 0
    IO.puts("Day $dayStr Part 2: #{part2}")
  end
end
"@
        Set-Content -Path (Join-Path $libPath "$dayModuleLower.ex") -Value $module -NoNewline

        # Create run.ps1
        $run = "mix run -e '$dayModule.run()'"
        Set-Content -Path (Join-Path $exPath "run.ps1") -Value $run -NoNewline

        Write-Host "Created $dayStr/$model/elixir" -ForegroundColor Green
    }
}

Write-Host "`nElixir scaffolding complete!" -ForegroundColor Cyan
