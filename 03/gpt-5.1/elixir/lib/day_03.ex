defmodule Day_03 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    {total_part1, total_part2} =
      "input.txt"
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&(&1 == ""))
      |> Enum.reduce({0, 0}, fn line, {acc1, acc2} ->
        max_joltage_part1 =
          Enum.reduce_while(9..1, 0, fn d1, _ ->
            c1 = Integer.to_string(d1)

            case String.index(line, c1) do
              nil ->
                {:cont, 0}

              idx1 ->
                max_for_d1 =
                  Enum.reduce_while(9..1, 0, fn d2, _ ->
                    c2 = Integer.to_string(d2)

                    case String.rindex(line, c2) do
                      nil ->
                        {:cont, 0}

                      idx2 when idx1 < idx2 ->
                        {:halt, d1 * 10 + d2}

                      _ ->
                        {:cont, 0}
                    end
                  end)

                if max_for_d1 > 0 do
                  {:halt, max_for_d1}
                else
                  {:cont, 0}
                end
            end
          end)

        # Part 2: choose exactly 12 digits to form the largest possible number
        digits = line
        target_length = 12

        chosen =
          0..(target_length - 1)
          |> Enum.reduce({[], 0}, fn pos, {acc_chars, start} ->
            remaining_needed = target_length - pos - 1

            {best_digit, best_index} =
              Enum.reduce_while(9..0, {nil, -1}, fn d, _ ->
                ch = Integer.to_string(d)

                last_index =
                  start..(String.length(digits) - 1)
                  |> Enum.reduce(-1, fn i, last ->
                    if String.at(digits, i) == ch, do: i, else: last
                  end)

                if last_index < start do
                  {:cont, {nil, -1}}
                else
                  if last_index <= String.length(digits) - 1 - remaining_needed do
                    {:halt, {ch, last_index}}
                  else
                    {:cont, {nil, -1}}
                  end
                end
              end)

            {best_digit, best_index} =
              case {best_digit, best_index} do
                {nil, -1} -> {String.at(digits, start), start}
                other -> other
              end

            {[best_digit | acc_chars], best_index + 1}
          end)

        chosen_digits = chosen |> elem(0) |> Enum.reverse() |> Enum.join()
        line_joltage_part2 = String.to_integer(chosen_digits)

        {acc1 + max_joltage_part1, acc2 + line_joltage_part2}
      end)

    IO.puts("Day 03 Part 1: #{total_part1}")
    IO.puts("Day 03 Part 2: #{total_part2}")
  end
end
