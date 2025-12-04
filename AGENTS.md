# Advent of Code 2025 - Agent Instructions

## What is Advent of Code?

Advent of Code is a yearly programming puzzle competition running December 1-25. Each day releases a new two-part puzzle. Part 2 unlocks after correctly solving Part 1. Each part requires submitting a single numeric answer.

## Repository Structure

```
01/
  CHALLENGE-PART1.md
  CHALLENGE-PART2.md
  input.txt
  prompt-part1.md
  prompt-part2.md
  claude-opus-4.5/
    dotnet/
    powershell/
    go/
    typescript/
    rust/
    python/
    elixir/
    rhombus/
  gemini-3.0-pro/
    (same 8 language folders)
  gpt-5.1/
    (same 8 language folders)
02/
...
12/
```

## Models

Three LLM models implement each puzzle independently:
- `claude-opus-4.5` - Anthropic Claude Opus 4.5
- `gemini-3.0-pro` - Google Gemini 3.0 Pro
- `gpt-5.1` - OpenAI GPT-5.1

## Languages

Each model implements solutions in 8 languages:
- **dotnet** - C# 14 / .NET 10
- **powershell** - PowerShell 7.x
- **go** - Go 1.24+
- **typescript** - TypeScript 5.x (tsx)
- **rust** - Rust 1.91+
- **python** - Python 3.12+
- **elixir** - Elixir 1.18+ (Mix project)
- **rhombus** - Rhombus (Racket-based)

## File Conventions

| Language | Project/Entry File | Run Script |
|----------|-------------------|------------|
| dotnet | `day-XX.csproj`, `Program.cs` | `run.ps1` |
| powershell | `solution.ps1` | `run.ps1` |
| go | `main.go` | `run.ps1` |
| typescript | `solution.ts` | `run.ps1` |
| rust | `Cargo.toml`, `src/main.rs` | `run.ps1` |
| python | `solution.py` | `run.ps1` |
| elixir | `mix.exs`, `lib/day_XX.ex` | `run.ps1` |
| rhombus | `solution.rhm` | `run.ps1` |

Input file location: `input.txt` (same level as prompt files, copied to language folder when running)

## Critical Rules

**You only get ONE chance per submission.** Wrong answers incur time penalties and repeated wrong answers can lock you out temporarily. Therefore:

1. **Test against examples first.** Every puzzle provides sample input/output. Verify your solution matches the expected example output before running against real input.

2. **Read the puzzle carefully.** Edge cases matter. Off-by-one errors are common. Pay attention to exact wording.

3. **Validate assumptions.** If the puzzle says "at least twice," that's different from "exactly twice." If it says "all," don't stop at the first match.

4. **Use the correct input.** The `input.txt` must contain the user's actual puzzle input, not the example data, when submitting.

5. **Check for integer overflow.** Use `long` not `int` when dealing with large numbers or sums.

6. **Verify before answering.** Run the solution, confirm the output looks reasonable, and only then report the answer.

## Workflow

1. User pastes puzzle into `CHALLENGE-PART1.md`
2. User selects a model and asks it to follow `prompt-part1.md` for a specific model folder
3. Model implements all 8 language solutions
4. Repeat for other models
5. After Part 1 is correct, repeat with `prompt-part2.md`

## Output Format

All solutions must output: `Day XX Part N: {answer}`

## Running Solutions

Each language folder contains a `run.ps1` script:

```powershell
cd 01/claude-opus-4.5/dotnet
./run.ps1
```

## Scaffold Scripts

These scripts in the repo root regenerate skeleton projects (skips existing):

- `scaffold-dotnet.ps1`
- `scaffold-go.ps1`
- `scaffold-powershell.ps1`
- `scaffold-python.ps1`
- `scaffold-rust.ps1`
- `scaffold-typescript.ps1`
- `scaffold-elixir.ps1`
- `scaffold-rhombus.ps1`
