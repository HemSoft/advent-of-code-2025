defmodule Day_01 do
  def run() do
    {part1, _final_position} =
      "input.txt"
      |> File.stream!([], :line)
      |> Enum.reduce({0, 50}, fn line, {zero_count, position} ->
        line = String.trim(line)

        if line == "" do
          {zero_count, position}
        else
          <<dir::binary-size(1), rest::binary>> = line
          distance = String.to_integer(rest)

          position =
            case dir do
              "R" -> rem(position + distance, 100)
              "L" -> rem(position - distance, 100)
            end

          # Ensure non-negative modulo result for left rotations
          position = if position < 0, do: position + 100, else: position

          zero_count = if position == 0, do: zero_count + 1, else: zero_count

          {zero_count, position}
        end
      end)

    # Part 1
    IO.puts("Day 01 Part 1: #{part1}")

    # Part 2
    part2 = 0
    IO.puts("Day 01 Part 2: #{part2}")
  end
end
