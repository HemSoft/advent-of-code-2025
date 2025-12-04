# Day 03 – Algorithm Analysis Report

## Overview

This report compares the Day 3 Part 2 implementations for the three model folders:

- `03/claude-opus-4.5/dotnet/Program.cs`
- `03/gemini-3.0-pro/dotnet/Program.cs`
- `03/gpt-5.1/dotnet/Program.cs`

Goal: determine which implementation matches the puzzle specification for Part 2 and therefore which final answer is correct.

Known reported totals for Part 2:

- Claude Opus 4.5: **166345822896410**
- Gemini 3.0 Pro: **166345822896410**
- GPT-5.1: **152220099083633**

You confirmed that **166345822896410** is the accepted correct answer.

## Puzzle Requirements (Part 2)

From the Part 2 description:

- Input consists of banks, each a line of digits.
- For **each bank** you must:
  - Turn on **exactly 12** batteries.
  - The joltage output for the bank is the 12-digit number formed by the chosen batteries in original left-to-right order.
  - You want the **largest possible 12-digit number** for that line.
- The final answer is the **sum** of these per-bank 12-digit joltages.

This is precisely the classic problem:

> Given a digit string `s` of length `n` and a target length `k = 12`, choose a **subsequence** of length `k` (preserving order) that is lexicographically maximal.

Equivalently:

- Remove exactly `n - 12` digits while preserving order, maximizing the resulting 12-digit integer.
- Standard greedy solution uses a monotonic stack or an equivalent left-to-right greedy selection.

## Claude Opus 4.5 Implementation

File: `03/claude-opus-4.5/dotnet/Program.cs`

Relevant Part 2 function:

```csharp
static long MaxJoltagePart2(string line, int k = 12)
{
    int n = line.Length;
    if (n < k)
        return 0;
    if (n == k)
    {
        return long.Parse(line);
    }

    // Greedy: pick k digits to form largest number
    // For each position, pick largest digit while ensuring enough remain
    char[] result = new char[k];
    int startIdx = 0;

    for (int i = 0; i < k; i++)
    {
        int remaining = k - i;
        int endIdx = n - remaining; // Last valid index to pick from

        char maxDigit = '0';
        int maxPos = startIdx;

        for (int j = startIdx; j <= endIdx; j++)
        {
            if (line[j] > maxDigit)
            {
                maxDigit = line[j];
                maxPos = j;
            }
        }

        result[i] = maxDigit;
        startIdx = maxPos + 1;
    }

    return long.Parse(new string(result));
}
```

Key properties:

- Enforces **exactly 12 digits** via `k = 12` and fixed-size `result`.
- For each digit position:
  - Computes the last index `endIdx` from which you can still complete a length-`k` subsequence.
  - Scans `[startIdx..endIdx]` and picks the **maximum** digit.
  - Advances `startIdx` to just after the chosen position.
- This is a canonical greedy algorithm for the maximal subsequence of length `k`.

Conclusion for Claude:

- Correctly matches the Part 2 specification.
- Its reported total, **166345822896410**, is consistent with a correct implementation.

## Gemini 3.0 Pro Implementation

File: `03/gemini-3.0-pro/dotnet/Program.cs`

Relevant Part 2 loop:

```csharp
long totalJoltagePart2 = 0;

foreach (var line in lines)
{
    if (string.IsNullOrWhiteSpace(line))
        continue;

    StringBuilder result = new StringBuilder();
    int currentIndex = 0;
    int digitsNeeded = 12;

    for (int i = 0; i < digitsNeeded; i++)
    {
        int remainingNeeded = digitsNeeded - 1 - i;
        // The last index we can pick is such that we have enough chars left
        // Last valid index = Length - 1 - remainingNeeded
        int searchEndIndex = line.Length - 1 - remainingNeeded;

        int bestDigit = -1;
        int bestDigitIndex = -1;

        // Search for the largest digit in the valid range [currentIndex, searchEndIndex]
        for (int d = 9; d >= 1; d--)
        {
            char c = (char)('0' + d);
            int idx = line.IndexOf(c, currentIndex);

            if (idx != -1 && idx <= searchEndIndex)
            {
                bestDigit = d;
                bestDigitIndex = idx;
                break; // Found the largest possible digit
            }
        }

        if (bestDigit != -1)
        {
            result.Append(bestDigit);
            currentIndex = bestDigitIndex + 1;
        }
        else
        {
            // Should not happen given problem constraints if input is valid
            break;
        }
    }

    if (result.Length == 12)
    {
        totalJoltagePart2 += long.Parse(result.ToString());
    }
}
```

Key properties:

- Enforces **exactly 12 digits** with `digitsNeeded = 12` and `if (result.Length == 12)`.
- For each output digit:
  - Computes `searchEndIndex` so that enough characters remain.
  - For digits `9` down to `1`, searches from `currentIndex` for the **earliest** occurrence within `[currentIndex..searchEndIndex]`.
  - Chooses the first digit that fits; this is the largest digit that can still lead to a valid 12-digit subsequence.
- This is functionally equivalent to Claude’s approach: greedy maximal subsequence of length 12.

Conclusion for Gemini:

- Also correctly matches the Part 2 specification.
- Produces the same total as Claude: **166345822896410**.

## GPT-5.1 Implementation

File: `03/gpt-5.1/dotnet/Program.cs`

Relevant Part 2 section:

```csharp
var digits = line.Trim();
const int targetLength = 12;
var chosen = new char[targetLength];
var start = 0;

for (var pos = 0; pos < targetLength; pos++)
{
    // We must leave (targetLength - pos - 1) characters after the chosen index.
    var remainingNeeded = targetLength - pos - 1;
    var bestDigit = '\0';
    var bestIndex = -1;

    for (var d = 9; d >= 0; d--)
    {
        var ch = (char)('0' + d);
        var lastIndex = digits.LastIndexOf(ch, digits.Length - 1, digits.Length - start);
        if (lastIndex < start)
        {
            continue;
        }

        if (lastIndex <= digits.Length - 1 - remainingNeeded)
        {
            bestDigit = ch;
            bestIndex = lastIndex;
            break;
        }
    }

    if (bestIndex == -1)
    {
        // Fallback: should not happen with valid inputs.
        bestDigit = digits[start];
        bestIndex = start;
    }

    chosen[pos] = bestDigit;
    start = bestIndex + 1;
}

long lineJoltagePart2 = 0;
foreach (var ch in chosen)
{
    lineJoltagePart2 = lineJoltagePart2 * 10 + (ch - '0');
}

totalJoltagePart2 += lineJoltagePart2;
```

Key properties:

- Also enforces a fixed length of 12 via `targetLength` and `chosen`.
- However, the digit selection strategy differs:
  - For each position, for digits `9` down to `0`, it calls:

    ```csharp
    var lastIndex = digits.LastIndexOf(ch, digits.Length - 1, digits.Length - start);
    ```

    This searches **backwards from the end** of the string down to `start`, returning the **rightmost occurrence** of `ch` in `[start..end]`.

  - It then checks whether `lastIndex <= digits.Length - 1 - remainingNeeded` to ensure enough characters remain.
  - The first digit `d` that passes this check is chosen, and its **rightmost** valid occurrence is used.

Effectively, GPT-5.1’s algorithm:

- Still picks digits in descending value order.
- Ensures that a full length-12 subsequence remains possible.
- But for the chosen digit, it picks the **rightmost** valid occurrence, not the **leftmost** (or any position that maximizes remaining flexibility).

This is not equivalent to the standard maximal subsequence algorithm. In general, choosing the rightmost valid occurrence of a digit can block access to better digits later and produce a lexicographically smaller 12-digit number.

Conclusion for GPT-5.1:

- The implementation is self-consistent and respects order and fixed length, but the greedy choice is subtly wrong.
- It does **not** always compute the lexicographically maximum subsequence of length 12.
- This explains the different final total: **152220099083633**, which is lower than the correct result.

## Final Determination

Based on direct code inspection and alignment with the puzzle specification:

- **Claude Opus 4.5** and **Gemini 3.0 Pro** both implement a correct greedy algorithm for selecting the maximum 12-digit subsequence per line.
- **GPT-5.1** implements a variant that selects rightmost occurrences for each chosen digit, which is not guaranteed to yield the maximum subsequence and thus produces a different, incorrect sum.

Therefore, the correct Day 3 Part 2 answer is:

> **166345822896410**

The GPT-5.1 answer:

> **152220099083633**

is incorrect due to the rightmost-occurrence selection bug described above.
