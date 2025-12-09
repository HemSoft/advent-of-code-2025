defmodule Day07 do
  def solve do
    case File.read("input.txt") do
      {:ok, content} ->
        lines = String.split(content, "\n", trim: true)
        run(lines)
      {:error, _} ->
        IO.puts("Error reading input.txt")
    end
  end

  def run(lines) do
    width = String.length(Enum.at(lines, 0))

    {start_row, start_col} = find_start(lines)

    if start_row == -1 do
      IO.puts("Start not found")
    else
      total_splits = simulate(lines, start_row + 1, MapSet.new([start_col]), width, 0)
      IO.puts("Day 07 Part 1: #{total_splits}")

      # Part 2
      lines_tuple = List.to_tuple(lines)
      height = length(lines)
      {part2_ans, _} = count_paths(start_row, start_col, %{}, lines_tuple, width, height)
      IO.puts("Day 07 Part 2: #{part2_ans}")
    end
  end

  def find_start(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce_while({-1, -1}, fn {line, r}, _acc ->
      case :binary.match(line, "S") do
        {pos, _len} -> {:halt, {r, pos}}
        :nomatch -> {:cont, {-1, -1}}
      end
    end)
  end

  def count_paths(_r, c, memo, _lines, width, _height) when c < 0 or c >= width do
    {1, memo}
  end

  def count_paths(r, c, memo, lines, width, height) do
    case Map.get(memo, {r, c}) do
      nil ->
        {res, new_memo} = scan_down(r + 1, c, memo, lines, width, height)
        {res, Map.put(new_memo, {r, c}, res)}
      val ->
        {val, memo}
    end
  end

  def scan_down(curr_r, c, memo, lines, width, height) do
    if curr_r >= height do
      {1, memo}
    else
      line = elem(lines, curr_r)
      char = String.at(line, c)
      if char == "^" do
        {left_res, memo1} = count_paths(curr_r, c - 1, memo, lines, width, height)
        {right_res, memo2} = count_paths(curr_r, c + 1, memo1, lines, width, height)
        {left_res + right_res, memo2}
      else
        scan_down(curr_r + 1, c, memo, lines, width, height)
      end
    end
  end

  def simulate(lines, r, active_beams, width, splits) do
    if r >= length(lines) or MapSet.size(active_beams) == 0 do
      splits
    else
      line = Enum.at(lines, r)
      {next_beams, new_splits} = Enum.reduce(active_beams, {MapSet.new(), 0}, fn c, {acc_beams, acc_splits} ->
        if c < 0 or c >= width do
          {acc_beams, acc_splits}
        else
          char = String.at(line, c)
          if char == "^" do
            acc_beams = if c - 1 >= 0, do: MapSet.put(acc_beams, c - 1), else: acc_beams
            acc_beams = if c + 1 < width, do: MapSet.put(acc_beams, c + 1), else: acc_beams
            {acc_beams, acc_splits + 1}
          else
            {MapSet.put(acc_beams, c), acc_splits}
          end
        end
      end)

      simulate(lines, r + 1, next_beams, width, splits + new_splits)
    end
  end
end
