defmodule Day_05 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.replace("\r\n", "\n")

    [ranges_part, ids_part] = String.split(input, "\n\n")

    ranges =
      ranges_part
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [start_str, end_str] = String.split(line, "-")
        {String.to_integer(start_str), String.to_integer(end_str)}
      end)

    ids =
      ids_part
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    part1 =
      ids
      |> Enum.count(fn id ->
        Enum.any?(ranges, fn {r_start, r_end} -> id >= r_start and id <= r_end end)
      end)

    IO.puts("Day 05 Part 1: #{part1}")

    # Part 2
    sorted_ranges = Enum.sort_by(ranges, fn {start, _} -> start end)

    merged_ranges =
      Enum.reduce(sorted_ranges, [], fn {next_start, next_end}, acc ->
        case acc do
          [] ->
            [{next_start, next_end}]

          [{curr_start, curr_end} | rest] ->
            if next_start <= curr_end + 1 do
              [{curr_start, max(curr_end, next_end)} | rest]
            else
              [{next_start, next_end} | acc]
            end
        end
      end)

    part2 =
      merged_ranges
      |> Enum.map(fn {start, ending} -> ending - start + 1 end)
      |> Enum.sum()

    IO.puts("Day 05 Part 2: #{part2}")
  end
end
