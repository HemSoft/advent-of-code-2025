defmodule Day_09 do
  def run() do
    tiles =
      "input.txt"
      |> File.read!()
      |> String.replace("\r", "")
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [x, y] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
        {x, y}
      end)

    # Part 1
    part1 = find_max_area(tiles)
    IO.puts("Day 09 Part 1: #{part1}")

    # Part 2
    edges = build_edges(tiles)
    tiles_set = MapSet.new(tiles)
    part2 = find_max_valid_area(tiles, edges, tiles_set)
    IO.puts("Day 09 Part 2: #{part2}")
  end

  defp find_max_area(tiles) do
    tiles
    |> pairs()
    |> Enum.map(fn {{x1, y1}, {x2, y2}} ->
      width = abs(x2 - x1) + 1
      height = abs(y2 - y1) + 1
      width * height
    end)
    |> Enum.max(fn -> 0 end)
  end

  defp build_edges(tiles) do
    n = length(tiles)
    Enum.map(0..(n - 1), fn i ->
      {Enum.at(tiles, i), Enum.at(tiles, rem(i + 1, n))}
    end)
  end

  defp find_max_valid_area(tiles, edges, tiles_set) do
    tiles
    |> pairs()
    |> Enum.reduce(0, fn {{x1, y1}, {x2, y2}}, max_area ->
      min_x = min(x1, x2)
      max_x = max(x1, x2)
      min_y = min(y1, y2)
      max_y = max(y1, y2)

      corners = [{min_x, min_y}, {min_x, max_y}, {max_x, min_y}, {max_x, max_y}]

      if Enum.all?(corners, fn {cx, cy} -> valid_point?(cx, cy, edges, tiles_set) end) and
           rectangle_valid?(min_x, max_x, min_y, max_y, edges) do
        area = (max_x - min_x + 1) * (max_y - min_y + 1)
        max(area, max_area)
      else
        max_area
      end
    end)
  end

  defp valid_point?(px, py, edges, tiles_set) do
    cond do
      MapSet.member?(tiles_set, {px, py}) -> true
      Enum.any?(edges, fn {{x1, y1}, {x2, y2}} -> on_segment?(px, py, x1, y1, x2, y2) end) -> true
      true -> inside_polygon?(px, py, edges)
    end
  end

  defp on_segment?(px, py, x1, y1, x2, y2) do
    cond do
      x1 == x2 -> px == x1 and py >= min(y1, y2) and py <= max(y1, y2)
      y1 == y2 -> py == y1 and px >= min(x1, x2) and px <= max(x1, x2)
      true -> false
    end
  end

  defp inside_polygon?(px, py, edges) do
    crossings =
      Enum.count(edges, fn {{x1, y1}, {x2, y2}} ->
        if (y1 <= py and y2 > py) or (y2 <= py and y1 > py) do
          x_intersect = x1 + (py - y1) / (y2 - y1) * (x2 - x1)
          px < x_intersect
        else
          false
        end
      end)

    rem(crossings, 2) == 1
  end

  defp rectangle_valid?(min_x, max_x, min_y, max_y, edges) do
    not Enum.any?(edges, fn {{x1, y1}, {x2, y2}} ->
      edge_crosses_rect_interior?(x1, y1, x2, y2, min_x, max_x, min_y, max_y)
    end)
  end

  defp edge_crosses_rect_interior?(x1, y1, x2, y2, min_x, max_x, min_y, max_y) do
    p1_inside = x1 >= min_x and x1 <= max_x and y1 >= min_y and y1 <= max_y
    p2_inside = x2 >= min_x and x2 <= max_x and y2 >= min_y and y2 <= max_y

    if p1_inside and p2_inside do
      false
    else
      rect_edges = [
        {min_x, min_y, max_x, min_y},
        {min_x, max_y, max_x, max_y},
        {min_x, min_y, min_x, max_y},
        {max_x, min_y, max_x, max_y}
      ]

      Enum.any?(Enum.with_index(rect_edges), fn {{rx1, ry1, rx2, ry2}, i} ->
        if segments_intersect?(x1, y1, x2, y2, rx1, ry1, rx2, ry2) do
          case get_intersection(x1, y1, x2, y2, rx1, ry1, rx2, ry2) do
            nil -> false
            {ix, iy} ->
              if i < 2 do
                ix > min_x and ix < max_x
              else
                iy > min_y and iy < max_y
              end
          end
        else
          false
        end
      end)
    end
  end

  defp direction(x1, y1, x2, y2, x3, y3) do
    (x3 - x1) * (y2 - y1) - (x2 - x1) * (y3 - y1)
  end

  defp segments_intersect?(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2) do
    d1 = direction(bx1, by1, bx2, by2, ax1, ay1)
    d2 = direction(bx1, by1, bx2, by2, ax2, ay2)
    d3 = direction(ax1, ay1, ax2, ay2, bx1, by1)
    d4 = direction(ax1, ay1, ax2, ay2, bx2, by2)
    ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and
      ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0))
  end

  defp get_intersection(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2) do
    d = (ax2 - ax1) * (by2 - by1) - (ay2 - ay1) * (bx2 - bx1)

    if abs(d) < 1.0e-10 do
      nil
    else
      t = ((bx1 - ax1) * (by2 - by1) - (by1 - ay1) * (bx2 - bx1)) / d
      {ax1 + t * (ax2 - ax1), ay1 + t * (ay2 - ay1)}
    end
  end

  defp pairs(list) do
    for {a, i} <- Enum.with_index(list),
        {b, j} <- Enum.with_index(list),
        i < j,
        do: {a, b}
  end
end