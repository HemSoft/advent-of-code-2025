defmodule Day_08 do
  def run() do
    input =
      "input.txt"
      |> File.read!()
      |> String.trim()

    points =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.trim()
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Enum.with_index()

    pairs =
      for {p1, i} <- points,
          {p2, j} <- points,
          i < j do
        {x1, y1, z1} = p1
        {x2, y2, z2} = p2
        dist_sq = :math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2) + :math.pow(z1 - z2, 2)
        dist = :math.sqrt(dist_sq)
        {dist, i, j}
      end
      |> Enum.sort_by(fn {dist, _, _} -> dist end)

    limit = min(1000, length(pairs))
    top_pairs = Enum.take(pairs, limit)

    parent = 0..(length(points) - 1) |> Enum.into(%{}, fn i -> {i, i} end)

    final_parent =
      Enum.reduce(top_pairs, parent, fn {_, i, j}, acc ->
        union(acc, i, j)
      end)

    sizes =
      0..(length(points) - 1)
      |> Enum.map(fn i -> find(final_parent, i) |> elem(0) end)
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)

    result =
      case sizes do
        [a, b, c | _] -> a * b * c
        _ -> Enum.product(sizes)
      end

    IO.puts("Day 08 Part 1: #{result}")

    # Part 2
    point_map = Map.new(points, fn {p, i} -> {i, p} end)
    parent = 0..(length(points) - 1) |> Enum.into(%{}, fn i -> {i, i} end)
    num_components = length(points)

    {part2_result, _, _} =
      Enum.reduce_while(pairs, {0, parent, num_components}, fn {_, i, j}, {res, acc_parent, comps} ->
        {root_i, parent1} = find(acc_parent, i)
        {root_j, parent2} = find(parent1, j)

        if root_i != root_j do
          new_parent = Map.put(parent2, root_i, root_j)
          new_comps = comps - 1
          if new_comps == 1 do
            {x1, _, _} = Map.get(point_map, i)
            {x2, _, _} = Map.get(point_map, j)
            {:halt, {x1 * x2, new_parent, new_comps}}
          else
            {:cont, {res, new_parent, new_comps}}
          end
        else
          {:cont, {res, parent2, comps}}
        end
      end)

    IO.puts("Day 08 Part 2: #{part2_result}")
  end

  def find(parent, i) do
    if Map.get(parent, i) == i do
      {i, parent}
    else
      {root, new_parent} = find(parent, Map.get(parent, i))
      {root, Map.put(new_parent, i, root)}
    end
  end

  def union(parent, i, j) do
    {root_i, parent1} = find(parent, i)
    {root_j, parent2} = find(parent1, j)

    if root_i != root_j do
      Map.put(parent2, root_i, root_j)
    else
      parent2
    end
  end
end