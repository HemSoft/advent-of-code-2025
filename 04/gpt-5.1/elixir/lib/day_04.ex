defmodule Day_04 do
  @deltas for dr <- -1..1,
               dc <- -1..1,
               not (dr == 0 and dc == 0),
               do: {dr, dc}

  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.split(["\r\n", "\n"], trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(String.length(&1) > 0))

    # Part 1
    part1 = count_accessible_rolls(lines)
    IO.puts("Day 04 Part 1: #{part1}")

    # Part 2
    part2 = count_total_removed(lines)
    IO.puts("Day 04 Part 2: #{part2}")
  end

  defp count_accessible_rolls([]), do: 0

  defp count_accessible_rolls(lines) do
    height = length(lines)
    width = lines |> hd() |> String.length()

    Enum.with_index(lines)
    |> Enum.reduce(0, fn {row, r}, acc ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {ch, c}, inner_acc ->
        if ch != "@" do
          inner_acc
        else
          neighbors = neighbor_count(lines, height, width, r, c)

          if neighbors < 4 do
            inner_acc + 1
          else
            inner_acc
          end
        end
      end)
    end)
  end

  defp neighbor_count(lines, height, width, r, c) do
    deltas =
      for dr <- -1..1,
          dc <- -1..1,
          not (dr == 0 and dc == 0) do
        {dr, dc}
      end

    Enum.reduce(deltas, 0, fn {dr, dc}, acc ->
      nr = r + dr
      nc = c + dc

      cond do
        nr < 0 or nr >= height or nc < 0 or nc >= width ->
          acc

        true ->
          row = Enum.at(lines, nr)
          ch = String.at(row, nc)

          if ch == "@" do
            acc + 1
          else
            acc
          end
      end
    end)
  end

  defp count_total_removed([]), do: 0

  defp count_total_removed(lines) do
    height = length(lines)
    width = lines |> hd() |> String.length()

    rolls =
      lines
      |> Enum.with_index()
      |> Enum.reduce(MapSet.new(), fn {row, r}, acc ->
        row
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {ch, c}, inner_acc ->
          if ch == "@" do
            MapSet.put(inner_acc, {r, c})
          else
            inner_acc
          end
        end)
      end)

    simulate_removals(rolls, height, width, 0)
  end

  defp simulate_removals(rolls, height, width, total_removed) do
    accessible =
      rolls
      |> Enum.filter(fn {r, c} ->
        neighbors =
          Enum.reduce(@deltas, 0, fn {dr, dc}, acc ->
            nr = r + dr
            nc = c + dc

            cond do
              nr < 0 or nr >= height or nc < 0 or nc >= width ->
                acc

              MapSet.member?(rolls, {nr, nc}) ->
                acc + 1

              true ->
                acc
            end
          end)

        neighbors < 4
      end)

    if accessible == [] do
      total_removed
    else
      remaining =
        Enum.reduce(accessible, rolls, fn pos, acc ->
          MapSet.delete(acc, pos)
        end)

      simulate_removals(remaining, height, width, total_removed + length(accessible))
    end
  end
end
