namespace AdventOfCode.Day07;

internal static class Program
{
	private static void Main()
	{
		var lines = System.IO.File.ReadAllLines("input.txt");

		var part1 = SolvePart1(lines);
		System.Console.WriteLine($"Day 07 Part 1: {part1}");

		long part2 = SolvePart2(lines);
		System.Console.WriteLine($"Day 07 Part 2: {part2}");
	}

	private static long SolvePart1(string[] rawLines)
	{
		if (rawLines.Length == 0)
		{
			return 0;
		}

		var height = rawLines.Length;
		var width = 0;

		foreach (var line in rawLines)
		{
			if (line.Length > width)
			{
				width = line.Length;
			}
		}

		var grid = new char[height, width];
		for (var r = 0; r < height; r++)
		{
			var line = rawLines[r];
			for (var c = 0; c < width; c++)
			{
				grid[r, c] = c < line.Length ? line[c] : '.';
			}
		}

		var startRow = -1;
		var startCol = -1;

		for (var r = 0; r < height && startRow < 0; r++)
		{
			for (var c = 0; c < width; c++)
			{
				if (grid[r, c] == 'S')
				{
					startRow = r;
					startCol = c;
					break;
				}
			}
		}

		if (startRow < 0)
		{
			return 0;
		}

		var current = new System.Collections.Generic.HashSet<(int Row, int Col)>();
		current.Add((startRow, startCol));

		long splits = 0;

		while (current.Count > 0)
		{
			var next = new System.Collections.Generic.HashSet<(int Row, int Col)>();

			foreach (var beam in current)
			{
				var row = beam.Row;
				var col = beam.Col;

				var nr = row + 1;
				if (nr >= height)
				{
					continue;
				}

				var cell = grid[nr, col];
				if (cell == '^')
				{
					splits++;

					if (col - 1 >= 0)
					{
						next.Add((nr, col - 1));
					}

					if (col + 1 < width)
					{
						next.Add((nr, col + 1));
					}
				}
				else
				{
					next.Add((nr, col));
				}
			}

			current = next;
		}

		return splits;
	}

	private static long SolvePart2(string[] rawLines)
	{
		if (rawLines.Length == 0)
		{
			return 0;
		}

		var height = rawLines.Length;
		var width = 0;

		foreach (var line in rawLines)
		{
			if (line.Length > width)
			{
				width = line.Length;
			}
		}

		var grid = new char[height, width];
		for (var r = 0; r < height; r++)
		{
			var line = rawLines[r];
			for (var c = 0; c < width; c++)
			{
				grid[r, c] = c < line.Length ? line[c] : '.';
			}
		}

		var startRow = -1;
		var startCol = -1;

		for (var r = 0; r < height && startRow < 0; r++)
		{
			for (var c = 0; c < width; c++)
			{
				if (grid[r, c] == 'S')
				{
					startRow = r;
					startCol = c;
					break;
				}
			}
		}

		if (startRow < 0)
		{
			return 0;
		}

		var current = new System.Collections.Generic.Dictionary<(int Row, int Col), long>
		{
			[(startRow, startCol)] = 1L,
		};

		long finished = 0;

		while (current.Count > 0)
		{
			var next = new System.Collections.Generic.Dictionary<(int Row, int Col), long>();

			foreach (var kvp in current)
			{
				var row = kvp.Key.Row;
				var col = kvp.Key.Col;
				var count = kvp.Value;

				var nr = row + 1;
				if (nr >= height)
				{
					finished += count;
					continue;
				}

				var cell = grid[nr, col];
				if (cell == '^')
				{
					if (col - 1 >= 0)
					{
						var key = (nr, col - 1);
						if (next.TryGetValue(key, out var existing))
						{
							next[key] = existing + count;
						}
						else
						{
							next[key] = count;
						}
					}
					if (col + 1 < width)
					{
						var key = (nr, col + 1);
						if (next.TryGetValue(key, out var existing))
						{
							next[key] = existing + count;
						}
						else
						{
							next[key] = count;
						}
					}
				}
				else
				{
					var key = (nr, col);
					if (next.TryGetValue(key, out var existing))
					{
						next[key] = existing + count;
					}
					else
					{
						next[key] = count;
					}
				}
			}

			current = next;
		}

		return finished;
	}
}