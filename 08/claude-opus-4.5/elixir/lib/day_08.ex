defmodule Day_08 do
  def run() do
    points =
      "input.txt"
      |> File.read!()
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [x, y, z] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
        {x, y, z}
      end)

    n = length(points)
    indexed_points = Enum.with_index(points)

    # Calculate all pairwise distances
    pairs =
      for {{x1, y1, z1}, i} <- indexed_points,
          {{x2, y2, z2}, j} <- indexed_points,
          i < j do
        dx = x1 - x2
        dy = y1 - y2
        dz = z1 - z2
        dist_sq = dx * dx + dy * dy + dz * dz
        {dist_sq, i, j}
      end
      |> Enum.sort()

    # Union-Find using a map
    parent = Enum.into(0..(n - 1), %{}, fn i -> {i, i} end)
    rank = Enum.into(0..(n - 1), %{}, fn i -> {i, 0} end)

    # Connect the 1000 shortest pairs for Part 1
    connections = min(1000, length(pairs))
    pairs_to_connect = Enum.take(pairs, connections)

    {final_parent, _final_rank} =
      Enum.reduce(pairs_to_connect, {parent, rank}, fn {_dist, i, j}, {p, r} ->
        unite(i, j, p, r)
      end)

    # Count circuit sizes
    circuit_sizes =
      0..(n - 1)
      |> Enum.map(fn i -> find(i, final_parent) end)
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)
      |> Enum.take(3)

    part1 = Enum.reduce(circuit_sizes, 1, &(&1 * &2))

    IO.puts("Day 08 Part 1: #{part1}")

    # Part 2: Reset and find the last connection that unifies all into one circuit
    parent2 = Enum.into(0..(n - 1), %{}, fn i -> {i, i} end)
    rank2 = Enum.into(0..(n - 1), %{}, fn i -> {i, 0} end)

    {_final_parent2, _final_rank2, last_i, last_j, _num_circuits} =
      Enum.reduce_while(pairs, {parent2, rank2, -1, -1, n}, fn {_dist, i, j}, {p, r, li, lj, nc} ->
        if nc <= 1 do
          {:halt, {p, r, li, lj, nc}}
        else
          pi = find(i, p)
          pj = find(j, p)

          if pi == pj do
            {:cont, {p, r, li, lj, nc}}
          else
            {new_p, new_r} = unite(i, j, p, r)
            {:cont, {new_p, new_r, i, j, nc - 1}}
          end
        end
      end)

    # Get X coordinates of the last two connected points
    {x1, _, _} = Enum.at(points, last_i)
    {x2, _, _} = Enum.at(points, last_j)
    part2 = x1 * x2

    IO.puts("Day 08 Part 2: #{part2}")
  end

  defp find(x, parent) do
    case Map.get(parent, x) do
      ^x -> x
      px -> find(px, parent)
    end
  end

  defp unite(x, y, parent, rank) do
    px = find(x, parent)
    py = find(y, parent)

    if px == py do
      {parent, rank}
    else
      rx = Map.get(rank, px)
      ry = Map.get(rank, py)

      {new_parent, new_rank} =
        cond do
          rx < ry ->
            {Map.put(parent, px, py), rank}

          rx > ry ->
            {Map.put(parent, py, px), rank}

          true ->
            {Map.put(parent, py, px), Map.put(rank, px, rx + 1)}
        end

      {new_parent, new_rank}
    end
  end
end
