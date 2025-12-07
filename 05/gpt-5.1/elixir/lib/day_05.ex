defmodule Day_05 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.split(["\r", "\n"], trim: true)

    {ranges, ids} = parse_input(input)
    merged = merge_ranges(ranges)

    part1 = count_fresh_available(ids, merged)
    IO.puts("Day 05 Part 1: #{part1}")

    part2 = count_all_fresh(merged)
    IO.puts("Day 05 Part 2: #{part2}")
  end

  defp parse_input(lines) do
    {range_lines, id_lines} =
      Enum.split_while(lines, fn line -> String.contains?(line, "-") end)

    ranges =
      Enum.flat_map(range_lines, fn line ->
        case String.split(line, "-", parts: 2) do
          [left, right] ->
            {start, ""} = Integer.parse(String.trim(left))
            {finish, ""} = Integer.parse(String.trim(right))

            if finish < start do
              [{finish, start}]
            else
              [{start, finish}]
            end

          _ ->
            []
        end
      end)

    ids =
      Enum.flat_map(id_lines, fn line ->
        line = String.trim(line)

        case Integer.parse(line) do
          {value, ""} -> [value]
          _ -> []
        end
      end)

    {ranges, ids}
  end

  defp merge_ranges(ranges) do
    ranges
    |> Enum.sort_by(fn {start, finish} -> {start, finish} end)
    |> Enum.reduce([], fn {start, finish}, acc ->
      case acc do
        [] ->
          [{start, finish}]

        [{last_start, last_finish} | rest] ->
          if start <= last_finish + 1 do
            new_finish = max(finish, last_finish)
            [{last_start, new_finish} | rest]
          else
            [{start, finish} | acc]
          end
      end
    end)
    |> Enum.reverse()
  end

  defp count_fresh_available(ids, ranges) do
    Enum.reduce(ids, 0, fn id, acc ->
      if fresh?(id, ranges) do
        acc + 1
      else
        acc
      end
    end)
  end

  defp fresh?(id, ranges) do
    Enum.any?(ranges, fn {start, finish} ->
      cond do
        id < start ->
          false

        id <= finish ->
          true

        true ->
          false
      end
    end)
  end

  defp count_all_fresh(ranges) do
    Enum.reduce(ranges, 0, fn {start, finish}, acc ->
      acc + (finish - start + 1)
    end)
  end
end