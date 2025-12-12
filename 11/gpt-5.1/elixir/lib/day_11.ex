defmodule Day_11 do
  use Bitwise
  @spec parse_graph(String.t()) :: %{String.t() => [String.t()]}
  def parse_graph(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      line = String.trim(line)
      if line == "" do
        acc
      else
        case String.split(line, ":", parts: 2) do
          [from, rest] ->
            from = String.trim(from)
            targets_part = String.trim(rest)

            targets =
              if targets_part == "" do
                []
              else
                targets_part
                |> String.split(~r/\s+/, trim: true)
              end

            Map.put(acc, from, targets)

          _ ->
            acc
        end
      end
    end)
  end

  @spec count_paths(String.t(), String.t(), %{String.t() => [String.t()]}, map()) :: integer()
  def count_paths(node, destination, graph, memo) do
    cond do
      node == destination ->
        1

      Map.has_key?(memo, node) ->
        memo[node]

      true ->
        children = Map.get(graph, node, [])

        {total, memo} =
          Enum.reduce(children, {0, memo}, fn child, {acc, memo_acc} ->
            value = count_paths(child, destination, graph, memo_acc)
            {acc + value, Map.put(memo_acc, child, Map.get(memo_acc, child, value))}
          end)

        Map.get(memo, node, total)
    end
  end

  @spec count_paths_with_required_nodes(String.t(), String.t(), %{String.t() => [String.t()]}, map(), integer()) :: integer()
  def count_paths_with_required_nodes(node, destination, graph, memo, mask) do
    updated_mask =
      cond do
        node == "fft" -> mask ||| 1
        node == "dac" -> mask ||| 2
        true -> mask
      end

    cond do
      node == destination ->
        if (updated_mask &&& 0b11) == 0b11, do: 1, else: 0

      Map.has_key?(memo, {node, updated_mask}) ->
        memo[{node, updated_mask}]

      true ->
        children = Map.get(graph, node, [])

        {total, memo} =
          Enum.reduce(children, {0, memo}, fn child, {acc, memo_acc} ->
            value = count_paths_with_required_nodes(child, destination, graph, memo_acc, updated_mask)
            {acc + value, memo_acc}
          end)

        memo = Map.put(memo, {node, updated_mask}, total)
        memo[{node, updated_mask}]
    end
  end

  defp run_example_test() do
    example = """
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
""" |> String.trim()

    graph = parse_graph(example)
    paths = count_paths("you", "out", graph, %{})

    if paths != 5 do
      IO.puts("Example test failed: expected 5, got #{paths}")
    end
  end

  defp run_part2_example_test() do
    example = """
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
""" |> String.trim()

    graph = parse_graph(example)
    paths = count_paths_with_required_nodes("svr", "out", graph, %{}, 0)

    if paths != 2 do
      IO.puts("Part 2 example test failed: expected 2, got #{paths}")
    end
  end

  def run() do
    run_example_test()
    run_part2_example_test()

    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    graph_real = parse_graph(input)
    part1 = count_paths("you", "out", graph_real, %{})
    IO.puts("Day 11 Part 1: #{part1}")

    part2 = count_paths_with_required_nodes("svr", "out", graph_real, %{}, 0)
    IO.puts("Day 11 Part 2: #{part2}")
  end
end
