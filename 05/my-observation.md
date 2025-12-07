Claude Opus 4.5 - No issues. Didn't use Context7 for Rhombus today but looked at previous Rhombus solutions to quickly find the correct syntax.

Gemini 3.0 Pro - Struggling again hard on Rhombus not using search or tools to aid in its understanding of the Rhombus langauge.
               - For some strange reason Gemini 3 decided to check in the files. This is actually against the rules so I had to undo that and adjust my prompts.

GPT 5.1 - This time GPT 5.1 actually abandoned Rhombus altogether and didn't update the result for Rhombus into the solution markdown file. When I asked it to, it struggled just like Gemini and failed to use search or tools and actually did worse than Gemini in that it gave up and cheated by copying the correct result into the Rhombus slot while the solution still isn't working. For part 2 it simply stopped without actually doing the Rhombus part nor tested any of the solutions so I had to inform GPT 5.1 that it didn't finish.

Today I added this to the prompts going forward:

## Tools

If you're unsure about language syntax, library APIs, or implementation patterns, use documentation lookup tools (Context7), fetch official docs from the web, or search GitHub for examples.

## DO NOT

Check in or commit or push any code to the repository.
