defmodule Day_02 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    part1 = sum_invalid_ids(input)
    IO.puts("Day 02 Part 1: #{part1}")

    part2 = sum_invalid_ids_part2(input)
    IO.puts("Day 02 Part 2: #{part2}")
  end

  defp digits_count(n) when n < 0, do: digits_count(-n)
  defp digits_count(n), do: do_digits_count(n, 1)

  defp do_digits_count(n, count) when n >= 10,
    do: do_digits_count(div(n, 10), count + 1)

  defp do_digits_count(_n, count), do: count

  defp pow10(exp), do: do_pow10(exp, 1)

  defp do_pow10(0, acc), do: acc
  defp do_pow10(exp, acc), do: do_pow10(exp - 1, acc * 10)

  defp sum_invalid_ids(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.reduce(0, fn range, acc ->
      range = String.trim(range)

      case String.split(range, "-", trim: true) do
        [start_s, end_s] ->
          {start, ""} = Integer.parse(String.trim(start_s))
          {end_, ""} = Integer.parse(String.trim(end_s))
          {start, end_} = if end_ < start, do: {end_, start}, else: {start, end_}

          min_len = digits_count(start)
          max_len = digits_count(end_)

          range_sum =
            Enum.reduce(min_len..max_len, 0, fn len, acc_len ->
              if rem(len, 2) == 1 do
                acc_len
              else
                half = div(len, 2)
                pow10 = pow10(half)
                first = pow10(len - 1)
                last = pow10(len) - 1

                low = max(start, first)
                high = min(end_, last)

                if low > high do
                  acc_len
                else
                  den = pow10 + 1
                  a_start = Integer.floor_div(low + den - 1, den)
                  a_end = Integer.floor_div(high, den)

                  if a_start > a_end do
                    acc_len
                  else
                    count = a_end - a_start + 1
                    terms_sum = (a_start + a_end) * count |> div(2)
                    contrib = terms_sum * den
                    acc_len + contrib
                  end
                end
              end
            end)

          acc + range_sum

        _ ->
          acc
      end
    end)
  end

  defp sum_invalid_ids_part2(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.reduce(0, fn range, acc ->
      range = String.trim(range)

      case String.split(range, "-", trim: true) do
        [start_s, end_s] ->
          {start, ""} = Integer.parse(String.trim(start_s))
          {end_, ""} = Integer.parse(String.trim(end_s))
          {start, end_} = if end_ < start, do: {end_, start}, else: {start, end_}

          min_len = digits_count(start)
          max_len = digits_count(end_)

          range_sum =
            Enum.reduce(min_len..max_len, 0, fn len, acc_len ->
              max_k = :math.sqrt(len) |> floor |> trunc()

              Enum.reduce(2..max_k, acc_len, fn k, acc_k ->
                if rem(len, k) != 0 do
                  acc_k
                else
                  base_len = div(len, k)
                  pow10_base = pow10(base_len)
                  first = pow10(len - 1)
                  last = pow10(len) - 1

                  low = max(start, first)
                  high = min(end_, last)

                  if low > high do
                    acc_k
                  else
                    {geom, _} =
                      Enum.reduce(1..k, {0, 1}, fn _, {g, factor} ->
                        {g + factor, factor * pow10_base}
                      end)

                    a_start = Integer.floor_div(low + geom - 1, geom)
                    a_end = Integer.floor_div(high, geom)

                    if a_start > a_end do
                      acc_k
                    else
                      count = a_end - a_start + 1
                      terms_sum = div((a_start + a_end) * count, 2)
                      contrib = terms_sum * geom
                      acc_k + contrib
                    end
                  end
                end
              end)
            end)

          acc + range_sum

        _ ->
          acc
      end
    end)
  end
end
