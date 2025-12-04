# Update prompt files for days 02-12 based on day 01 template

$days = 2..12

foreach ($day in $days) {
    $dayStr = $day.ToString("D2")
    $dayFolder = Join-Path $PSScriptRoot $dayStr
    
    # prompt-part1.md
    $part1Content = @"
# Part 1 Instructions

Read ``CHALLENGE-PART1.md`` for the puzzle description.

## Task

1. Update the solution in all 8 languages in the specified model folder.
2. Each solution must read input from ``input.txt``.
3. Each solution must output: ``Day $dayStr Part 1: {answer}``
4. Test against the example data in the challenge before running with the real input.
5. Run all 8 solutions and record results in ``solution-{model}.md`` (e.g., ``$dayStr/solution-claude-opus-4.5.md``).

## Results Documentation

Create ``solution-{model}.md`` in the day folder with a results table:

``````markdown
# Day $dayStr - {Model Name}

| Language   | Part 1 | Part 2 |
|------------|--------|--------|
| dotnet     |        |        |
| powershell |        |        |
| go         |        |        |
| typescript |        |        |
| rust       |        |        |
| python     |        |        |
| elixir     |        |        |
| rhombus    |        |        |
``````

## Languages

- **dotnet**: Update ``Program.cs``
- **powershell**: Update ``solution.ps1``
- **go**: Update ``main.go``
- **typescript**: Update ``solution.ts``
- **rust**: Update ``src/main.rs``
- **python**: Update ``solution.py``
- **elixir**: Update ``lib/day_XX.ex``
- **rhombus**: Update ``solution.rhm``
"@

    # prompt-part2.md
    $part2Content = @"
# Part 2 Instructions

Read ``CHALLENGE-PART2.md`` for the puzzle description.

## Task

1. Extend the existing solutions in all 8 languages to also solve Part 2.
2. Keep Part 1 output and add Part 2 output.
3. Output format: ``Day $dayStr Part 2: {answer}``
4. Test against the example data in the challenge before running with the real input.
5. Run all 8 solutions and update ``solution-{model}.md`` with Part 2 results.

## Notes

- The input file remains the same (``input.txt``).
- Update each existing solution file, do not create new files.
- Update the Part 2 column in the results table in ``solution-{model}.md``.
"@

    Set-Content -Path (Join-Path $dayFolder "prompt-part1.md") -Value $part1Content -NoNewline
    Set-Content -Path (Join-Path $dayFolder "prompt-part2.md") -Value $part2Content -NoNewline
    
    Write-Host "Updated day $dayStr"
}

Write-Host "Done! Updated prompt files for days 02-12."
