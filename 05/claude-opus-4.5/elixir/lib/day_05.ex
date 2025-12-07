defmodule Day_05 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.replace("\r\n", "\n")
      |> String.trim()

    [ranges_section, ingredients_section] = String.split(input, "\n\n")

    ranges =
      ranges_section
      |> String.split("\n")
      |> Enum.map(fn line ->
        [start, end_val] = String.split(String.trim(line), "-")
        {String.to_integer(start), String.to_integer(end_val)}
      end)

    ingredients =
      ingredients_section
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&String.to_integer/1)

    # Part 1
    part1 =
      ingredients
      |> Enum.count(fn id ->
        Enum.any?(ranges, fn {start, end_val} -> id >= start and id <= end_val end)
      end)

    IO.puts("Day 05 Part 1: #{part1}")

    # Part 2: Merge overlapping ranges and count total unique IDs
    sorted = Enum.sort_by(ranges, fn {start, end_val} -> {start, end_val} end)

    merged =
      Enum.reduce(sorted, [], fn {start, end_val}, acc ->
        case acc do
          [] ->
            [{start, end_val}]

          [{last_start, last_end} | rest] ->
            if last_end < start - 1 do
              [{start, end_val} | acc]
            else
              [{last_start, max(last_end, end_val)} | rest]
            end
        end
      end)

    part2 = Enum.reduce(merged, 0, fn {start, end_val}, acc -> acc + (end_val - start + 1) end)
    IO.puts("Day 05 Part 2: #{part2}")
  end
end
