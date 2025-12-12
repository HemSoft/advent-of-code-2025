defmodule Day_11 do
  def run() do
    lines =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n", trim: true)

    graph =
      lines
      |> Enum.reduce(%{}, fn line, acc ->
        [source, dest_str] = String.split(line, ":", parts: 2)
        source = String.trim(source)
        destinations = dest_str |> String.trim() |> String.split(~r/\s+/, trim: true)
        Map.put(acc, source, destinations)
      end)

    # Part 1
    {part1, _} = count_paths_memo("you", "out", graph, %{})
    IO.puts("Day 11 Part 1: #{part1}")

    # Part 2
    {part2, _} = count_paths_with_required_memo("svr", "out", graph, false, false, %{})
    IO.puts("Day 11 Part 2: #{part2}")
  end

  defp count_paths_memo(current, target, _graph, memo) when current == target, do: {1, memo}

  defp count_paths_memo(current, target, graph, memo) do
    if Map.has_key?(memo, current) do
      {Map.get(memo, current), memo}
    else
      case Map.get(graph, current) do
        nil -> {0, memo}
        neighbors ->
          {result, new_memo} =
            Enum.reduce(neighbors, {0, memo}, fn neighbor, {acc, m} ->
              {count, m2} = count_paths_memo(neighbor, target, graph, m)
              {acc + count, m2}
            end)
          {result, Map.put(new_memo, current, result)}
      end
    end
  end

  defp count_paths_with_required_memo(current, target, graph, visited_dac, visited_fft, memo) do
    visited_dac = visited_dac or current == "dac"
    visited_fft = visited_fft or current == "fft"

    if current == target do
      {if(visited_dac and visited_fft, do: 1, else: 0), memo}
    else
      key = {current, visited_dac, visited_fft}
      if Map.has_key?(memo, key) do
        {Map.get(memo, key), memo}
      else
        case Map.get(graph, current) do
          nil -> {0, memo}
          neighbors ->
            {result, new_memo} =
              Enum.reduce(neighbors, {0, memo}, fn neighbor, {acc, m} ->
                {count, m2} = count_paths_with_required_memo(neighbor, target, graph, visited_dac, visited_fft, m)
                {acc + count, m2}
              end)
            {result, Map.put(new_memo, key, result)}
        end
      end
    end
  end
end
