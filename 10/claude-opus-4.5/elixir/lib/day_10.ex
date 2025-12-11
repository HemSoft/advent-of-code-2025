defmodule Day_10 do
  @max_int 999_999_999

  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    lines = String.split(input, "\n", trim: true)
    part1 = Enum.sum(Enum.map(lines, &solve_machine/1))
    IO.puts("Day 10 Part 1: #{part1}")

    # Part 2
    part2 = 0
    IO.puts("Day 10 Part 2: #{part2}")
  end

  defp solve_machine(line) do
    # Parse indicator lights pattern
    [[_, pattern]] = Regex.scan(~r/\[([.#]+)\]/, line)
    n = String.length(pattern)

    # Target: 1 where '#', 0 where '.'
    target =
      pattern
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.into(%{}, fn {c, i} -> {i, if(c == "#", do: 1, else: 0)} end)

    # Parse buttons
    buttons =
      Regex.scan(~r/\(([0-9,]+)\)/, line)
      |> Enum.map(fn [_, indices_str] ->
        indices_str
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    num_buttons = length(buttons)

    # Build augmented matrix [A | target]
    matrix =
      for i <- 0..(n - 1), into: %{} do
        row =
          for j <- 0..num_buttons, into: %{} do
            if j == num_buttons do
              {j, target[i]}
            else
              btn = Enum.at(buttons, j)
              {j, if(i in btn and i < n, do: 1, else: 0)}
            end
          end

        {i, row}
      end

    # Gaussian elimination over GF(2)
    {matrix, pivot_col, rank} = gaussian_elimination(matrix, n, num_buttons)

    # Check for inconsistency
    inconsistent =
      if rank >= n do
        false
      else
        Enum.any?(rank..(n - 1), fn row ->
          matrix[row][num_buttons] == 1
        end)
      end

    if inconsistent do
      @max_int
    else
      # Find free variables
      pivot_cols =
        if rank > 0 do
          MapSet.new(for i <- 0..(rank - 1), pivot_col[i] != nil and pivot_col[i] >= 0, do: pivot_col[i])
        else
          MapSet.new()
        end

      free_vars =
        if num_buttons > 0 do
          for j <- 0..(num_buttons - 1), not MapSet.member?(pivot_cols, j), do: j
        else
          []
        end

      num_free = length(free_vars)
      num_combinations = trunc(:math.pow(2, num_free))

      if num_combinations == 0 do
        0
      else
        0..(num_combinations - 1)
        |> Enum.map(fn mask ->
          solution =
            Enum.reduce(Enum.with_index(free_vars), %{}, fn {fv, i}, acc ->
              Map.put(acc, fv, Bitwise.band(Bitwise.bsr(mask, i), 1))
            end)

          # Back-substitute
          solution =
            if rank > 0 do
              Enum.reduce((rank - 1)..0//-1, solution, fn row, sol ->
                col = pivot_col[row]

                val =
                  if col + 1 <= num_buttons - 1 do
                    Enum.reduce((col + 1)..(num_buttons - 1), matrix[row][num_buttons], fn j, v ->
                      Bitwise.bxor(v, matrix[row][j] * Map.get(sol, j, 0))
                    end)
                  else
                    matrix[row][num_buttons]
                  end

                Map.put(sol, col, val)
              end)
            else
              solution
            end

          if num_buttons > 0 do
            Enum.sum(for j <- 0..(num_buttons - 1), do: Map.get(solution, j, 0))
          else
            0
          end
        end)
        |> Enum.min()
      end
    end
  end

  defp gaussian_elimination(matrix, n, num_buttons) do
    if num_buttons == 0 do
      {matrix, %{}, 0}
    else
      {matrix, pivot_col, rank, _} =
        Enum.reduce(0..(num_buttons - 1), {matrix, %{}, 0, true}, fn col,
                                                                     {mat, pc, rank, continue} ->
          if not continue or rank >= n do
            {mat, pc, rank, false}
          else
            # Find pivot
            pivot_row =
              Enum.find(rank..(n - 1), fn row ->
                mat[row][col] == 1
              end)

            if pivot_row == nil do
              {mat, pc, rank, true}
            else
              # Swap rows
              mat =
                mat
                |> Map.put(rank, mat[pivot_row])
                |> Map.put(pivot_row, mat[rank])

              pc = Map.put(pc, rank, col)

              # Eliminate
              mat =
                Enum.reduce(0..(n - 1), mat, fn row, m ->
                  if row != rank and m[row][col] == 1 do
                    new_row =
                      for k <- 0..num_buttons, into: %{} do
                        {k, Bitwise.bxor(m[row][k], m[rank][k])}
                      end

                    Map.put(m, row, new_row)
                  else
                    m
                  end
                end)

              {mat, pc, rank + 1, true}
            end
          end
        end)

      {matrix, pivot_col, rank}
    end
  end
end