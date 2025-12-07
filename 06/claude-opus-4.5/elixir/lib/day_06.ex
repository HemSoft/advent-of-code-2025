defmodule Day_06 do
  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.trim_trailing("\n")
      |> String.split("\n")

    # Find max width and pad lines
    max_width = Enum.max_by(lines, &String.length/1) |> String.length()
    grid = Enum.map(lines, fn line -> String.pad_trailing(line, max_width) end)
    rows = length(grid)
    cols = max_width
    operator_row = Enum.at(grid, rows - 1)

    # Parse problems
    problems = parse_problems(grid, operator_row, rows, cols, 0, [])

    # Calculate grand total
    part1 =
      Enum.reduce(problems, 0, fn {numbers, op}, acc ->
        result = calculate_result(numbers, op)
        acc + result
      end)

    IO.puts("Day 06 Part 1: #{part1}")

    # Part 2: Read columns right-to-left, digits top-to-bottom form numbers
    part2 = solve_part2(grid, operator_row, rows, cols)
    IO.puts("Day 06 Part 2: #{part2}")
  end

  defp solve_part2(grid, operator_row, rows, cols) do
    parse_problems_part2(grid, operator_row, rows, cols, 0, 0)
  end

  defp parse_problems_part2(_grid, _operator_row, _rows, cols, col_start, acc) when col_start >= cols do
    acc
  end

  defp parse_problems_part2(grid, operator_row, rows, cols, col_start, acc) do
    # Skip separator columns
    col_start = skip_separators(grid, rows, cols, col_start)

    if col_start >= cols do
      acc
    else
      # Find end of this problem
      col_end = find_problem_end(grid, rows, cols, col_start)

      # Get operator
      op_segment = String.slice(operator_row, col_start, col_end - col_start) |> String.trim()
      op = if String.length(op_segment) > 0, do: String.first(op_segment), else: " "

      # Read columns right-to-left within this problem block
      numbers2 =
        for c <- (col_end - 1)..col_start//-1 do
          digits =
            for r <- 0..(rows - 2) do
              line = Enum.at(grid, r)
              ch = String.at(line, c)
              if ch != nil and ch =~ ~r/\d/, do: ch, else: nil
            end
            |> Enum.filter(&(&1 != nil))

          if length(digits) > 0 do
            Enum.join(digits, "") |> String.to_integer()
          else
            nil
          end
        end
        |> Enum.filter(&(&1 != nil))

      new_acc =
        if length(numbers2) > 0 and op in ["+", "*"] do
          result = calculate_result(numbers2, op)
          acc + result
        else
          acc
        end

      parse_problems_part2(grid, operator_row, rows, cols, col_end, new_acc)
    end
  end

  defp parse_problems(_grid, _operator_row, _rows, cols, col_start, acc) when col_start >= cols do
    Enum.reverse(acc)
  end

  defp parse_problems(grid, operator_row, rows, cols, col_start, acc) do
    # Skip separator columns
    col_start = skip_separators(grid, rows, cols, col_start)

    if col_start >= cols do
      Enum.reverse(acc)
    else
      # Find end of this problem
      col_end = find_problem_end(grid, rows, cols, col_start)

      # Extract numbers and operator
      numbers =
        for r <- 0..(rows - 2) do
          line = Enum.at(grid, r)
          segment = String.slice(line, col_start, col_end - col_start) |> String.trim()

          case Integer.parse(segment) do
            {num, ""} -> num
            _ -> nil
          end
        end
        |> Enum.filter(&(&1 != nil))

      # Get operator
      op_segment = String.slice(operator_row, col_start, col_end - col_start) |> String.trim()
      op = if String.length(op_segment) > 0, do: String.first(op_segment), else: " "

      new_acc =
        if length(numbers) > 0 and op in ["+", "*"] do
          [{numbers, op} | acc]
        else
          acc
        end

      parse_problems(grid, operator_row, rows, cols, col_end, new_acc)
    end
  end

  defp skip_separators(_grid, _rows, cols, col) when col >= cols, do: col

  defp skip_separators(grid, rows, cols, col) do
    if is_separator_column(grid, rows, col) do
      skip_separators(grid, rows, cols, col + 1)
    else
      col
    end
  end

  defp find_problem_end(_grid, _rows, cols, col) when col >= cols, do: col

  defp find_problem_end(grid, rows, cols, col) do
    if is_separator_column(grid, rows, col) do
      col
    else
      find_problem_end(grid, rows, cols, col + 1)
    end
  end

  defp is_separator_column(grid, rows, col) do
    Enum.all?(0..(rows - 2), fn r ->
      line = Enum.at(grid, r)
      col >= String.length(line) or String.at(line, col) == " "
    end)
  end

  defp calculate_result(numbers, "+") do
    Enum.sum(numbers)
  end

  defp calculate_result(numbers, "*") do
    Enum.reduce(numbers, 1, &(&1 * &2))
  end
end
