defmodule Day_03 do
  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 != ""))

    # Part 1
    part1 = lines |> Enum.map(&max_joltage/1) |> Enum.sum()
    IO.puts("Day 03 Part 1: #{part1}")

    # Part 2
    part2 = lines |> Enum.map(&max_joltage_part2(&1, 12)) |> Enum.sum()
    IO.puts("Day 03 Part 2: #{part2}")
  end

  defp max_joltage(line) do
    chars = String.graphemes(line)
    n = length(chars)

    if n < 2 do
      0
    else
      digits = Enum.map(chars, &String.to_integer/1)

      # Precompute suffix maximum
      suffix_max =
        digits
        |> Enum.reverse()
        |> Enum.scan(0, &max/2)
        |> Enum.reverse()
        |> tl()
        |> Kernel.++([0])

      # Find max joltage
      digits
      |> Enum.zip(suffix_max)
      |> Enum.take(n - 1)
      |> Enum.map(fn {tens, units} -> tens * 10 + units end)
      |> Enum.max()
    end
  end

  defp max_joltage_part2(line, k) do
    chars = String.graphemes(line)
    n = length(chars)

    cond do
      n < k -> 0
      n == k -> String.to_integer(line)
      true -> greedy_select(chars, n, k, 0, [])
    end
  end

  defp greedy_select(_chars, _n, k, _start_idx, result) when length(result) == k do
    result
    |> Enum.reverse()
    |> Enum.join()
    |> String.to_integer()
  end

  defp greedy_select(chars, n, k, start_idx, result) do
    i = length(result)
    remaining = k - i
    end_idx = n - remaining

    # Find max digit in range [start_idx, end_idx]
    {max_digit, max_pos} =
      start_idx..end_idx
      |> Enum.map(fn j -> {Enum.at(chars, j), j} end)
      |> Enum.max_by(fn {digit, _pos} -> digit end)

    greedy_select(chars, n, k, max_pos + 1, [max_digit | result])
  end
end
