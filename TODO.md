# Advent of Code 2025 - Remaining Setup Tasks

## Phase 1 - COMPLETED ✅
- [x] Deleted .sln file
- [x] Deleted old dotnet/ folders from all 12 days
- [x] Created new folder structure: `{day}/{model}/{language}/`
- [x] Models: `claude-opus-4.5`, `gemini-3.0-pro`, `gpt-5.1`
- [x] Languages: `dotnet`, `powershell`, `go`, `typescript`, `rust`, `python`
- [x] Created `prompt-part1.md` and `prompt-part2.md` for all 12 days
- [x] Updated `AGENTS.md` with new structure

## Phase 2 - Create Skeleton Projects ✅

For each of the 6 languages, create template files in ALL 216 folders (12 days × 3 models × 6 languages).

### Language Templates to Create

Each language folder needs:
1. A project/entry file with placeholder code
2. A `run.ps1` script to execute the solution

Input file path from language folder: `../../input.txt`

---

### 1. dotnet (C# 14 / .NET 10)
- [x] Create for all 36 folders (12 days × 3 models)

**Files to create:**
- `day-XX.csproj` (XX = day number like 01, 02, etc.)
- `Program.cs`
- `run.ps1`

**day-XX.csproj:**
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
```

**Program.cs:**
```csharp
using System.Globalization;

var input = File.ReadAllText("../../input.txt").Trim();

// Part 1
long part1 = 0;
Console.WriteLine($"Day XX Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
long part2 = 0;
Console.WriteLine($"Day XX Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");
```

**run.ps1:**
```powershell
dotnet run
```

---

### 2. powershell (PowerShell 7.x)
- [x] Create for all 36 folders

**Files to create:**
- `solution.ps1`
- `run.ps1`

**solution.ps1:**
```powershell
$input = Get-Content "../../input.txt" -Raw

# Part 1
$part1 = 0
Write-Host "Day XX Part 1: $part1"

# Part 2
$part2 = 0
Write-Host "Day XX Part 2: $part2"
```

**run.ps1:**
```powershell
& "$PSScriptRoot/solution.ps1"
```

---

### 3. go (Go 1.24+)
- [x] Create for all 36 folders

**Files to create:**
- `main.go`
- `run.ps1`

**main.go:**
```go
package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	data, _ := os.ReadFile("../../input.txt")
	input := strings.TrimSpace(string(data))
	_ = input

	// Part 1
	var part1 int64 = 0
	fmt.Printf("Day XX Part 1: %d\n", part1)

	// Part 2
	var part2 int64 = 0
	fmt.Printf("Day XX Part 2: %d\n", part2)
}
```

**run.ps1:**
```powershell
go run main.go
```

---

### 4. typescript (TypeScript 5.x with ts-node)
- [x] Create for all 36 folders

**Files to create:**
- `solution.ts`
- `run.ps1`

**solution.ts:**
```typescript
import * as fs from 'fs';

const input = fs.readFileSync('../../input.txt', 'utf-8').trim();

// Part 1
let part1 = 0;
console.log(`Day XX Part 1: ${part1}`);

// Part 2
let part2 = 0;
console.log(`Day XX Part 2: ${part2}`);
```

**run.ps1:**
```powershell
npx ts-node solution.ts
```

---

### 5. rust (Rust 1.91+)
- [x] Create for all 36 folders

**Files to create:**
- `Cargo.toml`
- `src/main.rs`
- `run.ps1`

**Cargo.toml:**
```toml
[package]
name = "day-XX"
version = "0.1.0"
edition = "2021"

[dependencies]
```

**src/main.rs:**
```rust
use std::fs;

fn main() {
    let input = fs::read_to_string("../../input.txt")
        .expect("Failed to read input")
        .trim()
        .to_string();

    // Part 1
    let part1: i64 = 0;
    println!("Day XX Part 1: {}", part1);

    // Part 2
    let part2: i64 = 0;
    println!("Day XX Part 2: {}", part2);
}
```

**run.ps1:**
```powershell
cargo run --release 2>$null
```

---

### 6. python (Python 3.12+)
- [x] Create for all 36 folders

**Files to create:**
- `solution.py`
- `run.ps1`

**solution.py:**
```python
with open("../../input.txt") as f:
    input_data = f.read().strip()

# Part 1
part1 = 0
print(f"Day XX Part 1: {part1}")

# Part 2
part2 = 0
print(f"Day XX Part 2: {part2}")
```

**run.ps1:**
```powershell
python solution.py
```

---

## Implementation Notes

1. Replace `XX` with the actual day number (01, 02, ... 12) in all files
2. Each language folder is at path: `{day}/{model}/{language}/`
3. Models: `claude-opus-4.5`, `gemini-3.0-pro`, `gpt-5.1`
4. Total folders per language: 36 (12 days × 3 models)
5. Total files to create: 216 folders × ~2-3 files each

## After Phase 2

- Create `comparison.ps1` script template for each day root
- This script will run all 18 solutions and compare outputs
