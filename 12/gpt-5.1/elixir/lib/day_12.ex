defmodule Day_12 do
  def run() do
    {shape_sizes, region_lines} = parse_input("input.txt")

    part1 =
      region_lines
      |> Enum.reduce(0, fn line, acc ->
        [size_part, counts_part] = String.split(line, ":", parts: 2)
        size_part = String.trim(size_part)
        counts_part = String.trim(counts_part)

        [w_str, h_str] = String.split(size_part, "x")
        width = String.to_integer(w_str)
        height = String.to_integer(h_str)

        total_cells_needed =
          counts_part
          |> String.split(~r/\s+/, trim: true)
          |> Enum.with_index()
          |> Enum.reduce(0, fn {count_str, idx}, sum ->
            c = String.to_integer(count_str)

            if c == 0 do
              sum
            else
              size = Map.fetch!(shape_sizes, idx)
              sum + c * size
            end
          end)

        grid_area = width * height

        if total_cells_needed <= grid_area do
          acc + 1
        else
          acc
        end
      end)

    IO.puts("Day 12 Part 1: #{part1}")

    # Part 2 placeholder
    part2 = 0
    IO.puts("Day 12 Part 2: #{part2}")
  end

  defp parse_input(path) do
    lines =
      path
      |> File.read!()
      |> String.split(["\n", "\r\n"], trim: false)

    {shape_sizes, region_lines, current_shape_id, current_shape_count} =
      Enum.reduce(lines, {%{}, [], nil, 0}, fn raw_line, {sizes, regions, current_id, count} ->
        line = String.trim_trailing(raw_line, "\r")

        if String.trim(line) == "" do
          {sizes, regions, current_id, count}
        else
          cond do
            String.match?(line, ~r/^\d+:/) and not String.contains?(line, "x") ->
              sizes =
                case current_id do
                  nil ->
                    sizes

                  id ->
                    Map.put(sizes, id, count)
                end

              id_part = line |> String.split(":", parts: 2) |> hd()
              new_id = String.to_integer(id_part)
              {sizes, regions, new_id, 0}

            String.contains?(line, "x") and String.contains?(line, ":") ->
              sizes =
                case current_id do
                  nil ->
                    sizes

                  id ->
                    Map.put(sizes, id, count)
                end

              {sizes, [String.trim(line) | regions], nil, 0}

            current_id != nil and (String.contains?(line, "#") or String.contains?(line, ".")) ->
              new_count = count + (line |> String.codepoints() |> Enum.count(&(&1 == "#")))
              {sizes, regions, current_id, new_count}

            true ->
              {sizes, regions, current_id, count}
          end
        end
      end)

    shape_sizes =
      case current_shape_id do
        nil ->
          shape_sizes

        id ->
          Map.put(shape_sizes, id, current_shape_count)
      end

    {shape_sizes, Enum.reverse(region_lines)}
  end
end
