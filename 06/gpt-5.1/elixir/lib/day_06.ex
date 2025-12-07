defmodule Day_06 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)

    # Part 1
    part1 = solve(input)
    IO.puts("Day 06 Part 1: #{part1}")

    # Part 2
    part2 = solve_part2(input)
    IO.puts("Day 06 Part 2: #{part2}")
  end

  defp solve([]), do: 0

  defp solve(lines) do
    height = length(lines)
    width =
      lines
      |> Enum.map(&String.length/1)
      |> Enum.max(fn -> 0 end)

    # Pad lines to equal width
    grid =
      lines
      |> Enum.map(fn line -> String.pad_trailing(String.trim_trailing(line, "\r"), width, " ") end)

    # Identify column ranges for problems
    indices = 0..(width - 1)

    {ranges, in_block, start_col} =
      Enum.reduce(indices, {[], false, 0}, fn x, {ranges, in_block, start_col} ->
        all_space =
          Enum.all?(0..(height - 1), fn y ->
            grid
            |> Enum.at(y)
            |> String.at(x) == " "
          end)

        cond do
          all_space and in_block ->
            {ranges ++ [{start_col, x - 1}], false, start_col}

          (not all_space) and (not in_block) ->
            {ranges, true, x}

          true ->
            {ranges, in_block, start_col}
        end
      end)

    ranges =
      if in_block do
        ranges ++ [{start_col, width - 1}]
      else
        ranges
      end

    Enum.reduce(ranges, 0, fn {start_col, end_col}, acc ->
      # Find operator in bottom row
      op =
        start_col..end_col
        |> Enum.find_value(fn x ->
          c = grid |> Enum.at(height - 1) |> String.at(x)
          if c in ["+", "*"], do: c, else: nil
        end)

      if is_nil(op) do
        acc
      else
        nums =
          0..(height - 2)
          |> Enum.reduce([], fn y, nums ->
            segment =
              grid
              |> Enum.at(y)
              |> String.slice(start_col..end_col)
              |> String.trim()

            if segment == "" do
              nums
            else
              {value, _} = Integer.parse(segment)
              nums ++ [value]
            end
          end)

        if nums == [] do
          acc
        else
          value =
            case op do
              "+" -> Enum.sum(nums)
              "*" -> Enum.reduce(nums, 1, &*/2)
            end

          acc + value
        end
      end
    end)
  end

  defp solve_part2([]), do: 0

  defp solve_part2(lines) do
    height = length(lines)

    width =
      lines
      |> Enum.map(&String.length/1)
      |> Enum.max(fn -> 0 end)

    grid =
      lines
      |> Enum.map(fn line -> String.pad_trailing(String.trim_trailing(line, "\r"), width, " ") end)

    indices = 0..(width - 1)

    {ranges, in_block, start_col} =
      Enum.reduce(indices, {[], false, 0}, fn x, {ranges, in_block, start_col} ->
        all_space =
          Enum.all?(0..(height - 1), fn y ->
            grid
            |> Enum.at(y)
            |> String.at(x) == " "
          end)

        cond do
          all_space and in_block ->
            {ranges ++ [{start_col, x - 1}], false, start_col}

          (not all_space) and (not in_block) ->
            {ranges, true, x}

          true ->
            {ranges, in_block, start_col}
        end
      end)

    ranges =
      if in_block do
        ranges ++ [{start_col, width - 1}]
      else
        ranges
      end

    Enum.reduce(ranges, 0, fn {start_col, end_col}, acc ->
      op =
        start_col..end_col
        |> Enum.find_value(fn x ->
          c = grid |> Enum.at(height - 1) |> String.at(x)
          if c in ["+", "*"], do: c, else: nil
        end)

      if is_nil(op) do
        acc
      else
        nums =
          end_col..start_col
          |> Enum.reduce([], fn x, nums ->
            digits =
              0..(height - 2)
              |> Enum.reduce("", fn y, acc_d ->
                c = grid |> Enum.at(y) |> String.at(x)

                if c >= "0" and c <= "9" do
                  acc_d <> c
                else
                  acc_d
                end
              end)

            if digits == "" do
              nums
            else
              {value, _} = Integer.parse(digits)
              nums ++ [value]
            end
          end)

        if nums == [] do
          acc
        else
          value =
            case op do
              "+" -> Enum.sum(nums)
              "*" -> Enum.reduce(nums, 1, &*/2)
            end

          acc + value
        end
      end
    end)
  end
end
