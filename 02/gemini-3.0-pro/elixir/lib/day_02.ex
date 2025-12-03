defmodule Day_02 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    ranges = String.split(input, ",")

    total_sum =
      ranges
      |> Enum.map(&parse_range/1)
      |> Enum.map(&sum_invalid_ids/1)
      |> Enum.sum()

    IO.puts("Day 02 Part 1: #{total_sum}")

    total_sum_part2 =
      ranges
      |> Enum.map(&parse_range/1)
      |> Enum.map(&sum_invalid_ids_part2/1)
      |> Enum.sum()

    IO.puts("Day 02 Part 2: #{total_sum_part2}")
  end

  defp parse_range(range_str) do
    [start_str, end_str] =
      range_str
      |> String.trim()
      |> String.split("-")

    {String.to_integer(start_str), String.to_integer(end_str)}
  end

  defp sum_invalid_ids({start_num, end_num}) do
    start_num..end_num
    |> Enum.filter(&is_invalid_id?/1)
    |> Enum.sum()
  end

  defp sum_invalid_ids_part2({start_num, end_num}) do
    start_num..end_num
    |> Enum.filter(&is_invalid_id_part2?/1)
    |> Enum.sum()
  end

  defp is_invalid_id?(id) do
    s = Integer.to_string(id)
    len = String.length(s)

    if rem(len, 2) != 0 do
      false
    else
      half_len = div(len, 2)
      {first_half, second_half} = String.split_at(s, half_len)
      first_half == second_half
    end
  end

  defp is_invalid_id_part2?(id) do
    s = Integer.to_string(id)
    len = String.length(s)
    max_pattern_len = div(len, 2)

    if max_pattern_len < 1 do
      false
    else
      Enum.any?(1..max_pattern_len, fn pattern_len ->
        rem(len, pattern_len) == 0 and
          (
            pattern = String.slice(s, 0, pattern_len)
            repetitions = div(len, pattern_len)
            String.duplicate(pattern, repetitions) == s
          )
      end)
    end
  end
end
