defmodule Day_07 do
  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n")

    rows = length(lines)
    cols = if rows > 0, do: String.length(Enum.at(lines, 0)), else: 0

    # Find starting position S
    {start_row, start_col} = find_start(lines, rows)

    # Part 1: Count total splits
    initial_beams = MapSet.new([start_col])
    split_count = simulate(lines, start_row + 1, rows, cols, initial_beams, 0)

    IO.puts("Day 07 Part 1: #{split_count}")

    # Part 2: Count timelines (each particle takes both paths at each splitter)
    initial_counts = %{start_col => 1}
    final_counts = simulate_part2(lines, start_row + 1, rows, cols, initial_counts)
    part2 = Enum.reduce(final_counts, 0, fn {_col, count}, acc -> acc + count end)
    IO.puts("Day 07 Part 2: #{part2}")
  end

  defp find_start(lines, rows) do
    Enum.reduce_while(0..(rows - 1), {0, 0}, fn r, acc ->
      line = Enum.at(lines, r)
      case :binary.match(line, "S") do
        {c, _} -> {:halt, {r, c}}
        :nomatch -> {:cont, acc}
      end
    end)
  end

  defp simulate(_lines, row, rows, _cols, beams, count) when row >= rows do
    count
  end

  defp simulate(lines, row, rows, cols, current_beams, count) do
    if MapSet.size(current_beams) == 0 do
      count
    else
      line = Enum.at(lines, row)
      {next_beams, new_splits} = process_beams(line, current_beams, cols)
      simulate(lines, row + 1, rows, cols, next_beams, count + new_splits)
    end
  end

  defp process_beams(line, beams, cols) do
    Enum.reduce(beams, {MapSet.new(), 0}, fn col, {next_beams, splits} ->
      if col < 0 or col >= cols do
        {next_beams, splits}
      else
        cell = String.at(line, col)
        if cell == "^" do
          new_beams = next_beams
          new_beams = if col - 1 >= 0, do: MapSet.put(new_beams, col - 1), else: new_beams
          new_beams = if col + 1 < cols, do: MapSet.put(new_beams, col + 1), else: new_beams
          {new_beams, splits + 1}
        else
          {MapSet.put(next_beams, col), splits}
        end
      end
    end)
  end

  defp simulate_part2(_lines, row, rows, _cols, counts) when row >= rows do
    counts
  end

  defp simulate_part2(lines, row, rows, cols, particle_counts) do
    if map_size(particle_counts) == 0 do
      particle_counts
    else
      line = Enum.at(lines, row)
      next_counts = process_particles(line, particle_counts, cols)
      simulate_part2(lines, row + 1, rows, cols, next_counts)
    end
  end

  defp process_particles(line, counts, cols) do
    Enum.reduce(counts, %{}, fn {col, count}, next_counts ->
      if col < 0 or col >= cols do
        next_counts
      else
        cell = String.at(line, col)
        if cell == "^" do
          next_counts
          |> then(fn nc -> if col - 1 >= 0, do: Map.update(nc, col - 1, count, &(&1 + count)), else: nc end)
          |> then(fn nc -> if col + 1 < cols, do: Map.update(nc, col + 1, count, &(&1 + count)), else: nc end)
        else
          Map.update(next_counts, col, count, &(&1 + count))
        end
      end
    end)
  end
end
