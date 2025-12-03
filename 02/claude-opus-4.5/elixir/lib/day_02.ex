defmodule Day_02 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    ranges = parse_ranges(input)

    # Part 1
    part1 = calculate_sum(ranges, &invalid_id_part1?/1)
    IO.puts("Day 02 Part 1: #{part1}")

    # Part 2
    part2 = calculate_sum(ranges, &invalid_id_part2?/1)
    IO.puts("Day 02 Part 2: #{part2}")
  end

  defp parse_ranges(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(fn range_str ->
      [start_str, end_str] = String.split(range_str, "-")
      {String.to_integer(start_str), String.to_integer(end_str)}
    end)
  end

  defp calculate_sum(ranges, invalid_fn) do
    ranges
    |> Enum.flat_map(fn {start_val, end_val} -> start_val..end_val end)
    |> Enum.filter(invalid_fn)
    |> Enum.sum()
  end

  defp invalid_id_part1?(num) do
    s = Integer.to_string(num)
    len = String.length(s)
    rem(len, 2) == 0 and String.slice(s, 0, div(len, 2)) == String.slice(s, div(len, 2), div(len, 2))
  end

  defp invalid_id_part2?(num) do
    s = Integer.to_string(num)
    len = String.length(s)
    max_pattern = div(len, 2)
    # Need at least 2 digits for a repeated pattern
    if max_pattern < 1 do
      false
    else
      1..max_pattern
      |> Enum.any?(fn pattern_len ->
        rem(len, pattern_len) == 0 and check_pattern(s, pattern_len, len)
      end)
    end
  end

  defp check_pattern(s, pattern_len, len) do
    pattern = String.slice(s, 0, pattern_len)
    repetitions = div(len, pattern_len)
    repetitions >= 2 and String.duplicate(pattern, repetitions) == s
  end
end
