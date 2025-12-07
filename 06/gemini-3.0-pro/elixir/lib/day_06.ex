defmodule Day_06 do
  def run() do
    case File.read("input.txt") do
      {:ok, content} ->
        lines = String.split(content, ~r/\r?\n/)
        # Remove trailing empty line
        lines = if List.last(lines) == "", do: List.delete_at(lines, length(lines) - 1), else: lines

        if lines == [] do
          IO.puts("Day 06 Part 1: 0")
        else
          width = lines |> Enum.map(&String.length/1) |> Enum.max()
          padded_lines = lines |> Enum.map(&String.pad_trailing(&1, width))

          char_lists = Enum.map(padded_lines, &String.to_charlist/1)
          columns =
            char_lists
            |> Enum.zip()
            |> Enum.map(&Tuple.to_list/1)

          blocks = get_blocks(columns, [], [])

          total_sum_p1 = Enum.reduce(blocks, 0, fn block, acc -> acc + process_block_p1(block) end)
          IO.puts("Day 06 Part 1: #{total_sum_p1}")

          total_sum_p2 = Enum.reduce(blocks, 0, fn block, acc -> acc + process_block_p2(block) end)
          IO.puts("Day 06 Part 2: #{total_sum_p2}")
        end
      {:error, _} -> IO.puts("Error reading input.txt")
    end
  end

  defp get_blocks([], current_block, blocks) do
    if current_block != [] do
      Enum.reverse([Enum.reverse(current_block) | blocks])
    else
      Enum.reverse(blocks)
    end
  end

  defp get_blocks([col | rest], current_block, blocks) do
    is_empty = Enum.all?(col, fn c -> c == 32 end)

    if is_empty do
      if current_block != [] do
        get_blocks(rest, [], [Enum.reverse(current_block) | blocks])
      else
        get_blocks(rest, [], blocks)
      end
    else
      get_blocks(rest, [col | current_block], blocks)
    end
  end

  defp process_block_p1(cols) do
    rows =
      cols
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&List.to_string/1)

    {numbers, op} = Enum.reduce(rows, {[], " "}, fn line, {nums, current_op} ->
      segment = String.trim(line)

      cond do
        segment == "" -> {nums, current_op}
        segment in ["+", "*"] -> {nums, segment}
        Regex.match?(~r/^\d+$/, segment) -> {[String.to_integer(segment) | nums], current_op}
        true -> {nums, current_op}
      end
    end)

    case op do
      "+" -> Enum.sum(numbers)
      "*" -> Enum.reduce(numbers, 1, &*/2)
      _ -> 0
    end
  end

  defp process_block_p2(cols) do
    {numbers, op} = Enum.reduce(cols, {[], nil}, fn col, {nums, current_op} ->
      # Filter spaces (32)
      chars = Enum.filter(col, fn c -> c != 32 end)

      if chars == [] do
        {nums, current_op}
      else
        last_char = List.last(chars)
        {new_op, remaining_chars} =
          if last_char in [?+, ?*] do
             {<<last_char::utf8>>, List.delete_at(chars, length(chars) - 1)}
          else
             {current_op, chars}
          end

        if remaining_chars != [] do
           num_str = List.to_string(remaining_chars)
           {[String.to_integer(num_str) | nums], new_op}
        else
           {nums, new_op}
        end
      end
    end)

    case op do
      "+" -> Enum.sum(numbers)
      "*" -> Enum.reduce(numbers, 1, &*/2)
      _ -> 0
    end
  end
end
