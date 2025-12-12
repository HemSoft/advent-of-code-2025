defmodule Day_12 do
  def run() do
    input_file =
      if length(System.argv()) > 0 do
        hd(System.argv())
      else
        "input.txt"
      end

    content = File.read!(input_file)
    parts = String.split(String.replace(content, "\r\n", "\n"), "\n\n", trim: true)

    {shapes, regions} = parse_input(parts)

    solved_count =
      Enum.count(regions, fn region ->
        solve_region(region, shapes)
      end)

    IO.puts("Day 12 Part 1: #{solved_count}")
    # IO.puts("Day 12 Part 2: 0")
  end

  def parse_input(parts) do
    Enum.reduce(parts, {%{}, []}, fn part, {shapes, regions} ->
      lines = String.split(String.trim(part), "\n", trim: true)
      if lines == [] do
        {shapes, regions}
      else
        first_line = hd(lines)
        if String.contains?(first_line, ":") do
          if String.contains?(first_line, "x") do
            # Region
            new_regions =
              Enum.reduce(lines, regions, fn line, acc ->
                if String.trim(line) != "" do
                  acc ++ [parse_region(line)]
                else
                  acc
                end
              end)
            {shapes, new_regions}
          else
            # Shape
            {id, variations} = parse_shape(lines)
            {Map.put(shapes, id, variations), regions}
          end
        else
          {shapes, regions}
        end
      end
    end)
  end

  def parse_shape(lines) do
    header = String.trim_trailing(String.trim(hd(lines)), ":")
    id = String.to_integer(header)

    points =
      lines
      |> Enum.drop(1)
      |> Enum.with_index()
      |> Enum.reduce(MapSet.new(), fn {line, r}, acc ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, c}, inner_acc ->
          if char == "#" do
            MapSet.put(inner_acc, {r, c})
          else
            inner_acc
          end
        end)
      end)

    {id, generate_variations(points)}
  end

  def parse_region(line) do
    [dims_part, counts_part] = String.split(line, ":")
    [w_str, h_str] = String.split(dims_part, "x")
    w = String.to_integer(w_str)
    h = String.to_integer(h_str)

    counts =
      counts_part
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    %{w: w, h: h, counts: counts}
  end

  def generate_variations(original) do
    {variations, _} =
      Enum.reduce(0..1, {[], original}, fn _, {vars, current_flip} ->
        {new_vars, _} =
          Enum.reduce(0..3, {vars, current_flip}, fn _, {v, current_rot} ->
            normalized = normalize(current_rot)
            if Enum.member?(v, normalized) do
              {v, rotate(current_rot)}
            else
              {[normalized | v], rotate(current_rot)}
            end
          end)
        {new_vars, flip(original)}
      end)
    variations
  end

  def rotate(points) do
    Enum.reduce(points, MapSet.new(), fn {r, c}, acc ->
      MapSet.put(acc, {c, -r})
    end)
  end

  def flip(points) do
    Enum.reduce(points, MapSet.new(), fn {r, c}, acc ->
      MapSet.put(acc, {r, -c})
    end)
  end

  def normalize(points) do
    if MapSet.size(points) == 0 do
      []
    else
      {min_r, min_c} =
        Enum.reduce(points, {1_000_000, 1_000_000}, fn {r, c}, {mr, mc} ->
          {min(r, mr), min(c, mc)}
        end)

      points
      |> Enum.map(fn {r, c} -> {r - min_r, c - min_c} end)
      |> Enum.sort()
    end
  end

  def solve_region(region, shapes) do
    presents =
      region.counts
      |> Enum.with_index()
      |> Enum.flat_map(fn {count, id} -> List.duplicate(id, count) end)

    total_area =
      Enum.reduce(presents, 0, fn id, acc ->
        acc + length(hd(shapes[id]))
      end)

    if total_area > region.w * region.h do
      false
    else
      max_skips = region.w * region.h - total_area
      grid = MapSet.new() # Using MapSet for occupied cells

      present_types =
        presents
        |> Enum.uniq()
        |> Enum.sort_by(fn id -> length(hd(shapes[id])) end, :desc)

      counts =
        Enum.reduce(presents, %{}, fn id, acc ->
          Map.update(acc, id, 1, &(&1 + 1))
        end)

      anchored_shapes =
        Enum.reduce(present_types, %{}, fn id, acc ->
          variations =
            Enum.map(shapes[id], fn v ->
              anchor = hd(v)
              Enum.map(v, fn {r, c} -> {r - elem(anchor, 0), c - elem(anchor, 1)} end)
            end)
          Map.put(acc, id, variations)
        end)

      ctx = %{
        w: region.w,
        h: region.h,
        types: present_types,
        anchored_shapes: anchored_shapes
      }

      backtrack(0, grid, ctx, counts, max_skips)
    end
  end

  def backtrack(idx, grid, ctx, counts, skips_left) do
    if idx == ctx.w * ctx.h do
      Enum.all?(Map.values(counts), fn c -> c == 0 end)
    else
      if MapSet.member?(grid, idx) do
        backtrack(idx + 1, grid, ctx, counts, skips_left)
      else
        r = div(idx, ctx.w)
        c = rem(idx, ctx.w)

        # Try to place a shape
        found =
          Enum.find_value(ctx.types, fn type_id ->
            if counts[type_id] > 0 do
              Enum.find_value(ctx.anchored_shapes[type_id], fn shape ->
                fits =
                  Enum.all?(shape, fn {dr, dc} ->
                    pr = r + dr
                    pc = c + dc
                    pr >= 0 and pr < ctx.h and pc >= 0 and pc < ctx.w and
                      not MapSet.member?(grid, pr * ctx.w + pc)
                  end)

                if fits do
                  new_grid =
                    Enum.reduce(shape, grid, fn {dr, dc}, acc ->
                      MapSet.put(acc, (r + dr) * ctx.w + (c + dc))
                    end)

                  new_counts = Map.update!(counts, type_id, &(&1 - 1))

                  if backtrack(idx + 1, new_grid, ctx, new_counts, skips_left) do
                    true
                  else
                    false
                  end
                else
                  false
                end
              end)
            else
              false
            end
          end)

        if found do
          true
        else
          # Try to skip
          if skips_left > 0 do
            backtrack(idx + 1, MapSet.put(grid, idx), ctx, counts, skips_left - 1)
          else
            false
          end
        end
      end
    end
  end
end

