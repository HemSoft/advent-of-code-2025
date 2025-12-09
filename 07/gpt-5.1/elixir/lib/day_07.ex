defmodule Day_07 do
  @moduledoc false

  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.split(["\r\n", "\n"], trim: true)

    part1 = solve_part1(lines)
    IO.puts("Day 07 Part 1: #{part1}")

    part2 = solve_part2(lines)
    IO.puts("Day 07 Part 2: #{part2}")
  end

  def solve_part1([]), do: 0

  def solve_part1(lines) do
    height = length(lines)

    width =
      lines
      |> Enum.map(&String.length/1)
      |> Enum.max()

    grid =
      lines
      |> Enum.map(fn line ->
        line
        |> String.pad_trailing(width, ".")
        |> String.to_charlist()
      end)

    {start_row, start_col} = find_start(grid, height, width)

    if start_row == -1 do
      0
    else
      current = MapSet.new([{start_row, start_col}])
      simulate(height, width, grid, current, 0)
    end
  end

  def solve_part2([]), do: 0

  def solve_part2(lines) do
    height = length(lines)

    width =
      lines
      |> Enum.map(&String.length/1)
      |> Enum.max()

    grid =
      lines
      |> Enum.map(fn line ->
        line
        |> String.pad_trailing(width, ".")
        |> String.to_charlist()
      end)

    {start_row, start_col} = find_start(grid, height, width)

    if start_row == -1 do
      0
    else
      current = %{{start_row, start_col} => 1}
      simulate_part2(height, width, grid, current, 0)
    end
  end

  defp find_start(grid, height, _width) do
    Enum.reduce_while(0..(height - 1), {-1, -1}, fn r, _acc ->
      row = Enum.at(grid, r)

      case Enum.find_index(row, &(&1 == ?S)) do
        nil ->
          {:cont, {-1, -1}}

        c ->
          {:halt, {r, c}}
      end
    end)
  end

  defp simulate(_height, _width, _grid, current, splits) when map_size(current) == 0,
    do: splits

  defp simulate(height, width, grid, current, splits) do
    {next, splits} =
      Enum.reduce(current, {MapSet.new(), splits}, fn {r, c}, {next_acc, acc_splits} ->
        nr = r + 1

        cond do
          nr >= height ->
            {next_acc, acc_splits}

          true ->
            cell =
              grid
              |> Enum.at(nr)
              |> Enum.at(c)

            if cell == ?^ do
              next_acc =
                next_acc
                |> maybe_add_beam({nr, c - 1}, width)
                |> maybe_add_beam({nr, c + 1}, width)

              {next_acc, acc_splits + 1}
            else
              {MapSet.put(next_acc, {nr, c}), acc_splits}
            end
        end
      end)

    simulate(height, width, grid, next, splits)
  end

  defp maybe_add_beam(set, {row, col}, width) when col >= 0 and col < width do
    MapSet.put(set, {row, col})
  end

  defp maybe_add_beam(set, _pos, _width), do: set

  defp simulate_part2(_height, _width, _grid, current, finished)
       when map_size(current) == 0,
       do: finished

  defp simulate_part2(height, width, grid, current, finished) do
    {next, finished} =
      Enum.reduce(current, {%{}, finished}, fn {{r, c}, count}, {next_acc, acc_finished} ->
        nr = r + 1

        cond do
          nr >= height ->
            {next_acc, acc_finished + count}

          true ->
            cell =
              grid
              |> Enum.at(nr)
              |> Enum.at(c)

            if cell == ?^ do
              next_acc =
                next_acc
                |> add_count({nr, c - 1}, width, count)
                |> add_count({nr, c + 1}, width, count)

              {next_acc, acc_finished}
            else
              {add_count(next_acc, {nr, c}, width, count), acc_finished}
            end
        end
      end)

    simulate_part2(height, width, grid, next, finished)
  end

  defp add_count(map, {row, col}, width, count) when col >= 0 and col < width do
    Map.update(map, {row, col}, count, &(&1 + count))
  end

  defp add_count(map, _pos, _width, _count), do: map
end