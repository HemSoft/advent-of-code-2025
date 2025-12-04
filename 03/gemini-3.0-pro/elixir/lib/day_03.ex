defmodule Day_03 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.split(["\r\n", "\n"], trim: true)

    total_joltage =
      input
      |> Enum.map(&process_line/1)
      |> Enum.sum()

    IO.puts("Day 03 Part 1: #{total_joltage}")

    total_joltage_part2 =
      input
      |> Enum.map(&process_line_part2/1)
      |> Enum.sum()

    IO.puts("Day 03 Part 2: #{total_joltage_part2}")
  end

  defp process_line(line) do
    line = String.trim(line)
    if line == "" do
      0
    else
      find_max_joltage(line)
    end
  end

  defp process_line_part2(line) do
    line = String.trim(line)
    if line == "" do
      0
    else
      find_max_joltage_part2(line)
    end
  end

  defp find_max_joltage_part2(line) do
    len = String.length(line)
    digits_needed = 12

    {result_str, _idx} =
      Enum.reduce(0..(digits_needed - 1), {"", 0}, fn i, {acc_str, current_index} ->
        remaining_needed = digits_needed - 1 - i
        search_end_index = len - 1 - remaining_needed

        case find_best_digit(line, current_index, search_end_index) do
          {digit, idx} -> {acc_str <> Integer.to_string(digit), idx + 1}
          nil -> {acc_str, current_index}
        end
      end)

    if String.length(result_str) == 12 do
      String.to_integer(result_str)
    else
      0
    end
  end

  defp find_best_digit(line, start_idx, end_idx) do
    Enum.reduce_while(9..1//-1, nil, fn d, _acc ->
      c = Integer.to_string(d)
      # scope: {offset, length}
      case :binary.match(line, c, scope: {start_idx, byte_size(line) - start_idx}) do
        {idx, _len} ->
          if idx <= end_idx do
            {:halt, {d, idx}}
          else
            {:cont, nil}
          end
        :nomatch ->
          {:cont, nil}
      end
    end)
  end

  defp find_max_joltage(line) do
    Enum.reduce_while(9..1//-1, 0, fn d1, _acc ->
      c1 = Integer.to_string(d1)
      # Find first occurrence
      case :binary.match(line, c1) do
        {idx1, _len} ->
          # Check if any d2 (9..1) exists after idx1
          case find_best_d2(line, idx1) do
            {:ok, d2} -> {:halt, d1 * 10 + d2}
            :error -> {:cont, 0}
          end
        :nomatch ->
          {:cont, 0}
      end
    end)
  end

  defp find_best_d2(line, idx1) do
    # We need to find the largest d2 that appears after idx1
    # We can just search in the substring starting at idx1 + 1
    substring = String.slice(line, (idx1 + 1)..-1//1)

    Enum.reduce_while(9..1//-1, :error, fn d2, _acc ->
      c2 = Integer.to_string(d2)
      if String.contains?(substring, c2) do
        {:halt, {:ok, d2}}
      else
        {:cont, :error}
      end
    end)
  end
end
