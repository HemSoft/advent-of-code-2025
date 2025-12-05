defmodule Day_04 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    lines = String.split(input, "\n", trim: true)
    grid = Enum.map(lines, &String.to_charlist/1)

    rows = length(grid)
    cols = if rows > 0, do: length(hd(grid)), else: 0

    grid_map =
      for {row, r} <- Enum.with_index(grid),
          {char, c} <- Enum.with_index(row),
          into: %{},
          do: {{r, c}, char}

    {total_removed, _final_grid} = process_removals(grid_map, rows, cols, 0, 0)

    IO.puts("Day 04 Part 2: #{total_removed}")
  end

  defp process_removals(grid_map, rows, cols, total_removed, iteration) do
    iteration = iteration + 1

    to_remove =
      for r <- 0..(rows - 1), c <- 0..(cols - 1), reduce: [] do
        acc ->
          if Map.get(grid_map, {r, c}) == ?@ do
            neighbor_count =
              for dr <- -1..1, dc <- -1..1, {dr, dc} != {0, 0} do
                {r + dr, c + dc}
              end
              |> Enum.count(fn {nr, nc} ->
                Map.get(grid_map, {nr, nc}) == ?@
              end)

            if neighbor_count < 4, do: [{r, c} | acc], else: acc
          else
            acc
          end
      end

    if to_remove == [] do
      {total_removed, grid_map}
    else
      if iteration == 1 do
        IO.puts("Day 04 Part 1: #{length(to_remove)}")
      end

      new_grid_map =
        Enum.reduce(to_remove, grid_map, fn {r, c}, acc_map ->
          Map.put(acc_map, {r, c}, ?.)
        end)

      process_removals(new_grid_map, rows, cols, total_removed + length(to_remove), iteration)
    end
  end
end
