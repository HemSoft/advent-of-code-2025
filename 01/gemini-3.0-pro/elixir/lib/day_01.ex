defmodule Day_01 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)

    # Part 1
    {_final_pos1, count1} =
      Enum.reduce(input, {50, 0}, fn line, {pos, count} ->
        line = String.trim(line)
        if line == "" do
          {pos, count}
        else
          {dir, amount_str} = String.split_at(line, 1)
          amount = String.to_integer(amount_str)

          new_pos =
            case dir do
              "R" -> Integer.mod(pos + amount, 100)
              "L" -> Integer.mod(pos - amount, 100)
            end

          new_count = if new_pos == 0, do: count + 1, else: count
          {new_pos, new_count}
        end
      end)

    IO.puts("Day 01 Part 1: #{count1}")

    # Part 2
    {_final_pos2, count2} =
      Enum.reduce(input, {50, 0}, fn line, {pos, count} ->
        line = String.trim(line)
        if line == "" do
          {pos, count}
        else
          {dir, amount_str} = String.split_at(line, 1)
          amount = String.to_integer(amount_str)

          Enum.reduce(1..amount, {pos, count}, fn _, {curr_pos, curr_count} ->
            next_pos =
              case dir do
                "R" -> Integer.mod(curr_pos + 1, 100)
                "L" -> Integer.mod(curr_pos - 1, 100)
              end

            next_count = if next_pos == 0, do: curr_count + 1, else: curr_count
            {next_pos, next_count}
          end)
        end
      end)

    IO.puts("Day 01 Part 2: #{count2}")
  end
end
