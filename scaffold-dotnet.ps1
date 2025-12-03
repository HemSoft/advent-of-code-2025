$basePath = $PSScriptRoot
$models = @("claude-opus-4.5", "gemini-3.0-pro", "gpt-5.1")
$days = 1..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    
    foreach ($model in $models) {
        $dotnetPath = Join-Path $basePath "$dayStr\$model\dotnet"
        
        # Skip if Program.cs already exists
        if (Test-Path (Join-Path $dotnetPath "Program.cs")) {
            Write-Host "Skipping $dayStr/$model/dotnet - already exists" -ForegroundColor Yellow
            continue
        }
        
        # Create directory if needed
        if (-not (Test-Path $dotnetPath)) {
            New-Item -ItemType Directory -Path $dotnetPath -Force | Out-Null
        }
        
        # Create .csproj
        $csproj = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
"@
        Set-Content -Path (Join-Path $dotnetPath "day-$dayStr.csproj") -Value $csproj -NoNewline
        
        # Create Program.cs
        $program = @"
using System.Globalization;

var input = File.ReadAllText("input.txt").Trim();

// Part 1
long part1 = 0;
Console.WriteLine(`$"Day $dayStr Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
long part2 = 0;
Console.WriteLine(`$"Day $dayStr Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
"@
        Set-Content -Path (Join-Path $dotnetPath "Program.cs") -Value $program -NoNewline
        
        # Create run.ps1
        $run = "dotnet run"
        Set-Content -Path (Join-Path $dotnetPath "run.ps1") -Value $run -NoNewline
        
        Write-Host "Created $dayStr/$model/dotnet" -ForegroundColor Green
    }
}

Write-Host "`nDotnet scaffolding complete!" -ForegroundColor Cyan
