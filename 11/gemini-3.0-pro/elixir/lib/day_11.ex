defmodule Day_11 do
  import Bitwise

  def run() do
    case File.read("input.txt") do
      {:ok, content} ->
        graph = parse_input(content)
        paths1 = count_paths_p1("you", graph)
        IO.puts("Day 11 Part 1: #{paths1}")

        paths2 = count_paths_p2("svr", graph)
        IO.puts("Day 11 Part 2: #{paths2}")

      {:error, reason} ->
        IO.puts("Error reading file: #{reason}")
    end
  end

  def parse_input(content) do
    content
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      parts = String.split(String.trim(line), ": ", parts: 2)
      if length(parts) == 2 do
        [source, targets_str] = parts
        targets = String.split(targets_str, " ", trim: true)
        Map.put(acc, source, targets)
      else
        acc
      end
    end)
  end

  def count_paths_p1(start_node, graph) do
    {count, _memo} = count_paths_memo_p1(start_node, graph, %{})
    count
  end

  defp count_paths_memo_p1("out", _graph, memo) do
    {1, memo}
  end

  defp count_paths_memo_p1(current, graph, memo) do
    case Map.get(memo, current) do
      nil ->
        neighbors = Map.get(graph, current, [])
        {total, new_memo} = Enum.reduce(neighbors, {0, memo}, fn neighbor, {acc_total, acc_memo} ->
          {count, updated_memo} = count_paths_memo_p1(neighbor, graph, acc_memo)
          {acc_total + count, updated_memo}
        end)
        {total, Map.put(new_memo, current, total)}

      val ->
        {val, memo}
    end
  end

  def count_paths_p2(start_node, graph) do
    {count, _memo} = count_paths_memo_p2(start_node, 0, graph, %{})
    count
  end

  defp count_paths_memo_p2(current, mask, graph, memo) do
    new_mask =
      cond do
        current == "dac" -> mask ||| 1
        current == "fft" -> mask ||| 2
        true -> mask
      end

    if current == "out" do
      if new_mask == 3, do: {1, memo}, else: {0, memo}
    else
      key = {current, new_mask}
      case Map.get(memo, key) do
        nil ->
          neighbors = Map.get(graph, current, [])
          {total, new_memo} = Enum.reduce(neighbors, {0, memo}, fn neighbor, {acc_total, acc_memo} ->
            {count, updated_memo} = count_paths_memo_p2(neighbor, new_mask, graph, acc_memo)
            {acc_total + count, updated_memo}
          end)
          {total, Map.put(new_memo, key, total)}

        val ->
          {val, memo}
      end
    end
  end
end
