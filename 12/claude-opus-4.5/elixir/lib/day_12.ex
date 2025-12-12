defmodule Day_12 do
  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(&String.trim_trailing/1)
      |> Enum.filter(&(&1 != ""))

    {shapes, region_lines} = parse_input(lines)

    part1 =
      region_lines
      |> Enum.count(fn line -> region_fits?(line, shapes) end)

    IO.puts("Day 12 Part 1: #{part1}")
    IO.puts("Day 12 Part 2: 0")
  end

  defp parse_input(lines) do
    parse_input(lines, %{}, [], -1, 0)
  end

  defp parse_input([], shapes, region_lines, current_shape_id, current_cell_count) do
    shapes =
      if current_shape_id >= 0 do
        Map.put(shapes, current_shape_id, current_cell_count)
      else
        shapes
      end

    {shapes, Enum.reverse(region_lines)}
  end

  defp parse_input([line | rest], shapes, region_lines, current_shape_id, current_cell_count) do
    cond do
      Regex.match?(~r/^\d+:/, line) and not String.contains?(line, "x") ->
        shapes =
          if current_shape_id >= 0 do
            Map.put(shapes, current_shape_id, current_cell_count)
          else
            shapes
          end

        [id_str | _] = String.split(line, ":")
        new_shape_id = String.to_integer(id_str)
        parse_input(rest, shapes, region_lines, new_shape_id, 0)

      String.contains?(line, "x") and String.contains?(line, ":") ->
        shapes =
          if current_shape_id >= 0 do
            Map.put(shapes, current_shape_id, current_cell_count)
          else
            shapes
          end

        parse_input(rest, shapes, [line | region_lines], -1, 0)

      current_shape_id >= 0 and (String.contains?(line, "#") or String.contains?(line, ".")) ->
        hash_count = line |> String.graphemes() |> Enum.count(&(&1 == "#"))
        parse_input(rest, shapes, region_lines, current_shape_id, current_cell_count + hash_count)

      true ->
        parse_input(rest, shapes, region_lines, current_shape_id, current_cell_count)
    end
  end

  defp region_fits?(line, shapes) do
    [size_part, counts_part] = String.split(line, ":", parts: 2)
    [width_str, height_str] = String.split(size_part, "x")
    width = String.to_integer(width_str)
    height = String.to_integer(height_str)

    counts =
      counts_part
      |> String.trim()
      |> String.split(~r/\s+/)
      |> Enum.map(&String.to_integer/1)

    total_cells_needed =
      counts
      |> Enum.with_index()
      |> Enum.reduce(0, fn {count, i}, acc ->
        acc + count * Map.get(shapes, i, 0)
      end)

    grid_area = width * height
    total_cells_needed <= grid_area
  end
end
