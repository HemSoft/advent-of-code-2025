defmodule Day_01 do
  def run() do
    rotations =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_rotation/1)

    # Part 1
    part1 = count_zeros_at_end(rotations, 50)
    IO.puts("Day 01 Part 1: #{part1}")

    # Part 2
    part2 = count_zeros_during_rotation(rotations, 50)
    IO.puts("Day 01 Part 2: #{part2}")
  end

  defp parse_rotation(line) do
    line = String.trim(line)
    {direction, distance} = String.split_at(line, 1)
    {direction, String.to_integer(distance)}
  end

  defp count_zeros_at_end(rotations, start_position) do
    {_final_pos, count} =
      Enum.reduce(rotations, {start_position, 0}, fn {dir, dist}, {pos, count} ->
        new_pos = apply_rotation(pos, dir, dist)
        new_count = if new_pos == 0, do: count + 1, else: count
        {new_pos, new_count}
      end)

    count
  end

  defp count_zeros_during_rotation(rotations, start_position) do
    {_final_pos, count} =
      Enum.reduce(rotations, {start_position, 0}, fn {dir, dist}, {pos, count} ->
        new_pos = apply_rotation(pos, dir, dist)

        first_hit =
          case dir do
            "L" -> if pos == 0, do: 100, else: pos
            "R" -> if pos == 0, do: 100, else: 100 - pos
          end

        zeros_hit = if first_hit <= dist, do: 1 + div(dist - first_hit, 100), else: 0

        {new_pos, count + zeros_hit}
      end)

    count
  end

  defp apply_rotation(pos, "L", dist), do: Integer.mod(pos - dist, 100)
  defp apply_rotation(pos, "R", dist), do: Integer.mod(pos + dist, 100)
end