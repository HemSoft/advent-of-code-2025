defmodule Day_01 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)

    {_final_pos, count} =
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

    IO.puts("Day 01 Part 1: #{count}")
  end
end
