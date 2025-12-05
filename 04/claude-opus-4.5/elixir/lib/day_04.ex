defmodule Day_04 do
  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n")
      |> Enum.filter(&(String.length(&1) > 0))

    grid = lines |> Enum.map(&String.graphemes/1)
    rows = length(grid)
    cols = length(Enum.at(grid, 0))

    # Part 1: Count rolls with fewer than 4 adjacent rolls
    directions = [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

    part1 =
      for r <- 0..(rows - 1),
          c <- 0..(cols - 1),
          get_cell(grid, r, c) == "@",
          reduce: 0 do
        acc ->
          adjacent_rolls =
            directions
            |> Enum.count(fn {dr, dc} ->
              nr = r + dr
              nc = c + dc
              nr >= 0 and nr < rows and nc >= 0 and nc < cols and get_cell(grid, nr, nc) == "@"
            end)

          if adjacent_rolls < 4, do: acc + 1, else: acc
      end

    IO.puts("Day 04 Part 1: #{part1}")

    # Part 2: Iteratively remove accessible rolls until none remain
    part2 = remove_accessible_rolls(grid, rows, cols, directions, 0)
    IO.puts("Day 04 Part 2: #{part2}")
  end

  defp remove_accessible_rolls(grid, rows, cols, directions, total) do
    to_remove =
      for r <- 0..(rows - 1),
          c <- 0..(cols - 1),
          get_cell(grid, r, c) == "@",
          adjacent_rolls =
            directions
            |> Enum.count(fn {dr, dc} ->
              nr = r + dr
              nc = c + dc
              nr >= 0 and nr < rows and nc >= 0 and nc < cols and get_cell(grid, nr, nc) == "@"
            end),
          adjacent_rolls < 4,
          do: {r, c}

    if Enum.empty?(to_remove) do
      total
    else
      new_grid =
        grid
        |> Enum.with_index()
        |> Enum.map(fn {row, r} ->
          row
          |> Enum.with_index()
          |> Enum.map(fn {cell, c} ->
            if Enum.member?(to_remove, {r, c}), do: ".", else: cell
          end)
        end)

      remove_accessible_rolls(new_grid, rows, cols, directions, total + length(to_remove))
    end
  end

  defp get_cell(grid, r, c) do
    grid |> Enum.at(r) |> Enum.at(c)
  end
end
