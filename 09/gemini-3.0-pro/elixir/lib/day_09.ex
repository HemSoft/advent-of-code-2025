defmodule Day09 do
  def run do
    points =
      "input.txt"
      |> File.read!()
      |> String.split(["\n", "\r\n"], trim: true)
      |> Enum.map(fn line ->
        [x, y] = String.split(line, ",") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)
        {x, y}
      end)

    n = length(points)
    edges =
      points
      |> Enum.with_index()
      |> Enum.map(fn {p1, i} ->
        p2 = Enum.at(points, rem(i + 1, n))
        {p1, p2}
      end)

    {max_area_part1, max_area_part2} =
      points
      |> Enum.with_index()
      |> Enum.reduce({0, 0}, fn {p1, i}, {acc1, acc2} ->
        points
        |> Enum.drop(i + 1)
        |> Enum.reduce({acc1, acc2}, fn p2, {inner_acc1, inner_acc2} ->
          {x1, y1} = p1
          {x2, y2} = p2
          width = abs(x1 - x2) + 1
          height = abs(y1 - y2) + 1
          area = width * height

          new_acc1 = max(inner_acc1, area)

          new_acc2 =
            if is_valid(p1, p2, edges) do
              max(inner_acc2, area)
            else
              inner_acc2
            end

          {new_acc1, new_acc2}
        end)
      end)

    IO.puts("Day 09 Part 1: #{max_area_part1}")
    IO.puts("Day 09 Part 2: #{max_area_part2}")
  end

  def is_point_in_polygon({x, y}, edges) do
    Enum.reduce(edges, false, fn {{p1x, p1y}, {p2x, p2y}}, inside ->
      if (p1y > y) != (p2y > y) do
        intersect_x = (p2x - p1x) * (y - p1y) / (p2y - p1y) + p1x
        if x < intersect_x do
          not inside
        else
          inside
        end
      else
        inside
      end
    end)
  end

  def is_valid({x1, y1}, {x2, y2}, edges) do
    min_x = min(x1, x2)
    max_x = max(x1, x2)
    min_y = min(y1, y2)
    max_y = max(y1, y2)

    cx = (min_x + max_x) / 2.0
    cy = (min_y + max_y) / 2.0

    if not is_point_in_polygon({cx, cy}, edges) do
      false
    else
      Enum.all?(edges, fn {{ep1x, ep1y}, {ep2x, ep2y}} ->
        cond do
          ep1x == ep2x -> # Vertical
            ex = ep1x
            ey_min = min(ep1y, ep2y)
            ey_max = max(ep1y, ep2y)
            if min_x < ex and ex < max_x do
              overlap_min = max(min_y, ey_min)
              overlap_max = min(max_y, ey_max)
              overlap_min >= overlap_max
            else
              true
            end

          ep1y == ep2y -> # Horizontal
            ey = ep1y
            ex_min = min(ep1x, ep2x)
            ex_max = max(ep1x, ep2x)
            if min_y < ey and ey < max_y do
              overlap_min = max(min_x, ex_min)
              overlap_max = min(max_x, ex_max)
              overlap_min >= overlap_max
            else
              true
            end

          true -> true
        end
      end)
    end
  end
end
