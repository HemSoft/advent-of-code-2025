defmodule Day_10 do
  import Bitwise

  def run do
    case File.read("input.txt") do
      {:ok, content} ->
        lines = String.split(content, "\n", trim: true)
        
        total_presses_part1 =
          lines
          |> Enum.map(&solve_machine/1)
          |> Enum.sum()

        IO.puts("Day 10 Part 1: #{total_presses_part1}")

        total_presses_part2 =
          lines
          |> Enum.map(&solve_part2/1)
          |> Enum.sum()

        IO.puts("Day 10 Part 2: #{total_presses_part2}")

      {:error, _} ->
        IO.puts("Error reading input.txt")
    end
  end

  def solve_machine(line) do
    case Regex.run(~r/\[([.#]+)\]/, line) do
      [_, target_str] ->
        l = String.length(target_str)
        target =
          target_str
          |> String.graphemes()
          |> Enum.map(fn c -> if c == "#", do: 1, else: 0 end)

        buttons =
          Regex.scan(~r/\(([\d,]+)\)/, line)
          |> Enum.map(fn [_, parts] ->
            b = List.duplicate(0, l)
            parts
            |> String.split(",")
            |> Enum.reduce(b, fn p, acc ->
              case Integer.parse(p) do
                {idx, ""} when idx < l -> List.replace_at(acc, idx, 1)
                _ -> acc
              end
            end)
          end)

        b_count = length(buttons)
        
        m =
          for r <- 0..(l - 1) do
            row =
              for c <- 0..(b_count - 1) do
                Enum.at(Enum.at(buttons, c), r)
              end
            row ++ [Enum.at(target, r)]
          end

        {m_rref, pivot_cols, col_to_pivot_row} = gaussian_elimination(m, l, b_count)
        
        # Check consistency
        consistent = 
          Enum.all?(0..(l-1), fn r ->
             # If row is all zeros except last column, it's inconsistent
             # But here we just check if pivot rows cover all non-zero rows?
             # Actually, standard check: if row is all zeros in A part but non-zero in b part.
             # My gaussian elimination returns RREF.
             # Let's check rows that are not pivot rows.
             pivot_row_indices = Map.values(col_to_pivot_row)
             if r not in pivot_row_indices do
                Enum.at(Enum.at(m_rref, r), b_count) == 0
             else
                true
             end
          end)

        if not consistent do
            0
        else
            free_cols = Enum.filter(0..(b_count - 1), fn c -> c not in pivot_cols end)
            num_free = length(free_cols)
            combinations = Integer.pow(2, num_free)
            
            0..(combinations - 1)
            |> Enum.map(fn i ->
              x = List.duplicate(0, b_count)
              
              {x, current_presses} =
                Enum.with_index(free_cols)
                |> Enum.reduce({x, 0}, fn {f_col, k}, {acc_x, acc_p} ->
                  if (i &&& (1 <<< k)) != 0 do
                    {List.replace_at(acc_x, f_col, 1), acc_p + 1}
                  else
                    {acc_x, acc_p}
                  end
                end)
                
              {x, current_presses} =
                Enum.reduce(pivot_cols, {x, current_presses}, fn p_col, {acc_x, acc_p} ->
                  r = Map.get(col_to_pivot_row, p_col)
                  row = Enum.at(m_rref, r)
                  val = Enum.at(row, b_count)
                  
                  val =
                    Enum.reduce(free_cols, val, fn f_col, acc_val ->
                      if Enum.at(row, f_col) == 1 and Enum.at(acc_x, f_col) == 1 do
                        bxor(acc_val, 1)
                      else
                        acc_val
                      end
                    end)
                    
                  acc_x = List.replace_at(acc_x, p_col, val)
                  acc_p = if val == 1, do: acc_p + 1, else: acc_p
                  {acc_x, acc_p}
                end)
                
              current_presses
            end)
            |> Enum.min(fn -> 0 end) # Default to 0 if empty, though shouldn't be if consistent
        end

      _ ->
        0
    end
  end

  def gaussian_elimination(m, l, b_count) do
    do_gaussian(m, l, b_count, 0, 0, [], %{})
  end

  defp do_gaussian(m, l, b_count, r, c, pivot_cols, col_to_pivot_row) when r >= l or c >= b_count do
    {m, pivot_cols, col_to_pivot_row}
  end

  defp do_gaussian(m, l, b_count, r, c, pivot_cols, col_to_pivot_row) do
    sel =
      Enum.find_index(Enum.slice(m, r, l - r), fn row -> Enum.at(row, c) == 1 end)
      
    case sel do
      nil ->
        do_gaussian(m, l, b_count, r, c + 1, pivot_cols, col_to_pivot_row)
        
      idx ->
        sel_row_idx = r + idx
        
        m = swap_rows(m, r, sel_row_idx)
        pivot_row_val = Enum.at(m, r)
        
        m =
          Enum.with_index(m)
          |> Enum.map(fn {row, idx} ->
            if idx != r and Enum.at(row, c) == 1 do
              Enum.zip(row, pivot_row_val)
              |> Enum.map(fn {v1, v2} -> bxor(v1, v2) end)
            else
              row
            end
          end)
          
        do_gaussian(m, l, b_count, r + 1, c + 1, pivot_cols ++ [c], Map.put(col_to_pivot_row, c, r))
    end
  end
  
  defp swap_rows(m, r1, r2) do
    row1 = Enum.at(m, r1)
    row2 = Enum.at(m, r2)
    m
    |> List.replace_at(r1, row2)
    |> List.replace_at(r2, row1)
  end

  def solve_part2(line) do
    case Regex.run(~r/\{([\d,]+)\}/, line) do
      [_, target_str] ->
        target_parts = String.split(target_str, ",") |> Enum.map(&String.to_integer/1)
        l = length(target_parts)
        b_vec = target_parts

        buttons =
          Regex.scan(~r/\(([\d,]+)\)/, line)
          |> Enum.map(fn [_, parts] ->
            col = List.duplicate(0, l)
            parts
            |> String.split(",")
            |> Enum.reduce(col, fn p, acc ->
              case Integer.parse(p) do
                {idx, ""} when idx < l -> List.replace_at(acc, idx, 1)
                _ -> acc
              end
            end)
          end)

        b_count = length(buttons)
        
        matrix =
          for r <- 0..(l - 1) do
            row =
              for c <- 0..(b_count - 1) do
                Enum.at(Enum.at(buttons, c), r) * 1.0
              end
            row ++ [Enum.at(b_vec, r) * 1.0]
          end

        {matrix_rref, pivot_cols, col_to_pivot_row} = gaussian_elimination_float(matrix, l, b_count)

        consistent = 
          Enum.all?(0..(l-1), fn r ->
             pivot_row_indices = Map.values(col_to_pivot_row)
             if r not in pivot_row_indices do
                abs(Enum.at(Enum.at(matrix_rref, r), b_count)) < 1.0e-9
             else
                true
             end
          end)

        if not consistent do
            0
        else
            free_cols = Enum.filter(0..(b_count - 1), fn c -> c not in pivot_cols end)
            
            ubs = 
                Enum.map(0..(b_count - 1), fn c ->
                    min_ub = 
                        Enum.reduce(0..(l-1), :infinity, fn r, acc ->
                            val = Enum.at(Enum.at(buttons, c), r)
                            if val > 0 do
                                ub = floor(Enum.at(b_vec, r) / val)
                                if acc == :infinity or ub < acc, do: ub, else: acc
                            else
                                acc
                            end
                        end)
                    if min_ub == :infinity, do: 0, else: min_ub
                end)

            {found, min_presses} = search(0, free_cols, List.duplicate(0, length(free_cols)), ubs, pivot_cols, col_to_pivot_row, matrix_rref, b_count, :infinity, false)
            
            if found, do: min_presses, else: 0
        end

      _ -> 0
    end
  end

  def gaussian_elimination_float(m, l, b_count) do
    do_gaussian_float(m, l, b_count, 0, 0, [], %{})
  end

  defp do_gaussian_float(m, l, b_count, r, c, pivot_cols, col_to_pivot_row) when r >= l or c >= b_count do
    {m, pivot_cols, col_to_pivot_row}
  end

  defp do_gaussian_float(m, l, b_count, r, c, pivot_cols, col_to_pivot_row) do
    sel =
      Enum.find_index(Enum.slice(m, r, l - r), fn row -> abs(Enum.at(row, c)) > 1.0e-9 end)
      
    case sel do
      nil ->
        do_gaussian_float(m, l, b_count, r, c + 1, pivot_cols, col_to_pivot_row)
        
      idx ->
        sel_row_idx = r + idx
        
        m = swap_rows(m, r, sel_row_idx)
        
        pivot_val = Enum.at(Enum.at(m, r), c)
        
        # Normalize pivot row
        pivot_row = Enum.at(m, r) |> Enum.map(fn x -> x / pivot_val end)
        m = List.replace_at(m, r, pivot_row)
        
        # Eliminate
        m =
          Enum.with_index(m)
          |> Enum.map(fn {row, idx} ->
            if idx != r and abs(Enum.at(row, c)) > 1.0e-9 do
              factor = Enum.at(row, c)
              Enum.zip(row, pivot_row)
              |> Enum.map(fn {v1, v2} -> v1 - factor * v2 end)
            else
              row
            end
          end)
          
        do_gaussian_float(m, l, b_count, r + 1, c + 1, pivot_cols ++ [c], Map.put(col_to_pivot_row, c, r))
    end
  end

  defp search(free_idx, free_cols, current_free_vals, ubs, pivot_cols, col_to_pivot_row, matrix, b_count, min_total_presses, found) do
    if free_idx == length(free_cols) do
        current_presses = Enum.sum(current_free_vals)
        
        possible = 
            Enum.reduce_while(pivot_cols, true, fn p_col, _ ->
                r = Map.get(col_to_pivot_row, p_col)
                row = Enum.at(matrix, r)
                val = Enum.at(row, b_count)
                
                val = 
                    Enum.with_index(free_cols)
                    |> Enum.reduce(val, fn {f_col, j}, acc ->
                        acc - Enum.at(row, f_col) * Enum.at(current_free_vals, j)
                    end)
                
                if val < -1.0e-9 do
                    {:halt, false}
                else
                    long_val = round(val)
                    if abs(val - long_val) > 1.0e-9 do
                        {:halt, false}
                    else
                        {:cont, true}
                    end
                end
            end)
            
        if possible do
            # Calculate total presses including pivot variables
             total_p = 
                Enum.reduce(pivot_cols, current_presses, fn p_col, acc ->
                    r = Map.get(col_to_pivot_row, p_col)
                    row = Enum.at(matrix, r)
                    val = Enum.at(row, b_count)
                    val = 
                        Enum.with_index(free_cols)
                        |> Enum.reduce(val, fn {f_col, j}, acc_val ->
                            acc_val - Enum.at(row, f_col) * Enum.at(current_free_vals, j)
                        end)
                    acc + round(val)
                end)

            if min_total_presses == :infinity or total_p < min_total_presses do
                {true, total_p}
            else
                {found, min_total_presses}
            end
        else
            {found, min_total_presses}
        end
    else
        f_col_idx = Enum.at(free_cols, free_idx)
        limit = Enum.at(ubs, f_col_idx)
        
        Enum.reduce(0..limit, {found, min_total_presses}, fn val, {acc_found, acc_min} ->
            new_free_vals = List.replace_at(current_free_vals, free_idx, val)
            search(free_idx + 1, free_cols, new_free_vals, ubs, pivot_cols, col_to_pivot_row, matrix, b_count, acc_min, acc_found)
        end)
    end
  end
end

