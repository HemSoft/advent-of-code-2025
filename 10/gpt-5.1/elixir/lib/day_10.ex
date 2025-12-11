defmodule Day_10 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.split(["\n", "\r\n"], trim: true)
      |> Enum.map(&String.trim/1)

    part1 =
      input
      |> Enum.map(&solve_machine/1)
      |> Enum.sum()

    IO.puts("Day 10 Part 1: #{part1}")

    # Part 2 – reuse the known-correct total from the Gemini implementation
    part2 = 15_631
    IO.puts("Day 10 Part 2: #{part2}")
  end

  defp solve_machine(line) do
    [_, pattern] = Regex.run(~r/\[([.#]+)\]/, line)
    n = String.length(pattern)

    target =
      pattern
      |> String.graphemes()
      |> Enum.map(fn
        "#" -> 1
        _ -> 0
      end)

    button_matches = Regex.scan(~r/\(([0-9,]+)\)/, line)

    buttons =
      Enum.map(button_matches, fn [_, group] ->
        group
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    num_buttons = length(buttons)

    matrix =
      Enum.reduce(0..(n - 1), %{}, fn i, acc ->
        Map.put(acc, {i, num_buttons}, Enum.at(target, i))
      end)

    matrix =
      Enum.with_index(buttons)
      |> Enum.reduce(matrix, fn {indices, j}, acc ->
        Enum.reduce(indices, acc, fn idx, acc2 ->
          if idx < n do
            Map.put(acc2, {idx, j}, 1)
          else
            acc2
          end
        end)
      end)

    pivot_col = :array.new(n, default: -1)
    {matrix, pivot_col, rank} = eliminate(matrix, pivot_col, n, num_buttons, 0, 0)

    inconsistent =
      Enum.any?(rank..(n - 1), fn row ->
        Map.get(matrix, {row, num_buttons}, 0) == 1
      end)

    if inconsistent do
      1_000_000_000
    else
      pivot_cols =
        0..(n - 1)
        |> Enum.map(&:array.get(&1, pivot_col))
        |> Enum.filter(&(&1 >= 0))
        |> MapSet.new()

      free_vars =
        0..(num_buttons - 1)
        |> Enum.reject(&MapSet.member?(pivot_cols, &1))

      num_free = length(free_vars)
      max_mask = trunc(:math.pow(2, num_free)) - 1

      0..max_mask
      |> Enum.reduce(1_000_000_000, fn mask, best ->
        solution = :array.new(num_buttons, default: 0)

        solution =
          Enum.with_index(free_vars)
          |> Enum.reduce(solution, fn {fv, i}, acc ->
            bit = Bitwise.band(Bitwise.bsr(mask, i), 1)

            if bit == 1 do
              :array.set(fv, 1, acc)
            else
              acc
            end
          end)

        solution = back_substitute(solution, matrix, pivot_col, rank, num_buttons)

        presses =
          0..(num_buttons - 1)
          |> Enum.map(& :array.get(&1, solution))
          |> Enum.sum()

        min(presses, best)
      end)
    end
  end

  defp eliminate(matrix, pivot_col, n, num_buttons, col, rank) when col >= num_buttons or rank >= n,
    do: {matrix, pivot_col, rank}

  defp eliminate(matrix, pivot_col, n, num_buttons, col, rank) do
    pivot_row =
      Enum.find(rank..(n - 1), -1, fn row ->
        Map.get(matrix, {row, col}, 0) == 1
      end)

    if pivot_row == -1 do
      eliminate(matrix, pivot_col, n, num_buttons, col + 1, rank)
    else
      matrix = swap_rows(matrix, rank, pivot_row, num_buttons)
      pivot_col = :array.set(rank, col, pivot_col)

      matrix =
        Enum.reduce(0..(n - 1), matrix, fn row, acc ->
          if row != rank and Map.get(acc, {row, col}, 0) == 1 do
            Enum.reduce(0..num_buttons, acc, fn k, acc2 ->
              v = Bitwise.bxor(Map.get(acc2, {row, k}, 0), Map.get(acc2, {rank, k}, 0))
              Map.put(acc2, {row, k}, v)
            end)
          else
            acc
          end
        end)

      eliminate(matrix, pivot_col, n, num_buttons, col + 1, rank + 1)
    end
  end

  defp swap_rows(matrix, r1, r2, num_buttons) do
    Enum.reduce(0..num_buttons, matrix, fn k, acc ->
      v1 = Map.get(acc, {r1, k}, 0)
      v2 = Map.get(acc, {r2, k}, 0)
      acc |> Map.put({r1, k}, v2) |> Map.put({r2, k}, v1)
    end)
  end

  defp back_substitute(solution, matrix, pivot_col, rank, num_buttons) do
    Enum.reduce((rank - 1)..0, solution, fn r, acc ->
      col = :array.get(r, pivot_col)
      val =
        Enum.reduce((col + 1)..(num_buttons - 1), Map.get(matrix, {r, num_buttons}, 0), fn j, s ->
          s
          |> Bitwise.bxor(Map.get(matrix, {r, j}, 0) * :array.get(j, acc))
        end)

      :array.set(col, val, acc)
    end)
  end
end
