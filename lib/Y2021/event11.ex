defmodule Y2021.Event11 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event11/test.txt", 100)}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event11/puzzle.txt", 100)}")
    IO.puts("Test part2: #{part2("input/Y2021/event11/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event11/puzzle.txt")}")
  end

  def part1(path, n) do
    map = get_input(path)
    Enum.reduce(1..n, {0, map}, fn _, acc -> flash(acc) end) |> elem(0)
  end

  def part2(path) do
    map = get_input(path)

    flash2(map, 0)
  end

  def flash2(map, acc) do
    # render_map(map)

    new_map =
      Map.map(map, fn
        {_key, val} -> val + 1
      end)

    flashed = Map.filter(new_map, fn {_key, val} -> val > 9 end)

    new_map2 =
      Enum.reduce(flashed, new_map, &do_flash/2)
      |> Map.map(fn
        {_key, val} when val > 9 -> 0
        {_key, val} -> val
      end)

    count =
      Map.filter(new_map2, fn {_, val} -> val == 0 end)
      |> Enum.count()

    if count == 100 do
      acc + 1
    else
      flash2(new_map2, acc + 1)
    end
  end

  def flash({acc, map}) do
    # render_map(map)

    new_map =
      Map.map(map, fn
        {_key, val} -> val + 1
      end)

    flashed = Map.filter(new_map, fn {_key, val} -> val > 9 end)

    new_map2 =
      Enum.reduce(flashed, new_map, &do_flash/2)
      |> Map.map(fn
        {_key, val} when val > 9 -> 0
        {_key, val} -> val
      end)

    count =
      Map.filter(new_map2, fn {_, val} -> val == 0 end)
      |> Enum.count()

    {acc + count, new_map2}
  end

  def do_flash({position, _val}, map) do
    surrounding_elements =
      surrounding_positions(position)
      |> Enum.flat_map(
        &case Map.get(map, &1) do
          nil -> []
          val -> [{&1, val + 1}]
        end
      )
      |> Enum.into(%{})

    flashed = Map.filter(surrounding_elements, fn {_key, val} -> val == 10 end)

    if Enum.empty?(flashed) do
      Map.merge(map, surrounding_elements)
    else
      Enum.reduce(
        flashed,
        Map.merge(map, surrounding_elements),
        &do_flash/2
      )
    end
  end

  def get_basin_elements({position, val} = point, map, used_positions \\ []) do
    surrounding_elements =
      (surrounding_positions(position) -- used_positions)
      |> Enum.flat_map(
        &case Map.get(map, &1) do
          nil -> []
          9 -> []
          val -> [{&1, val}]
        end
      )
      |> Enum.filter(fn
        {_, 9} -> false
        {_, h} -> h > val
      end)

    if surrounding_elements == [] do
      [point]
    else
      [
        point
        | Enum.flat_map(
            surrounding_elements,
            &get_basin_elements(
              &1,
              map,
              [position | surrounding_positions(position) ++ used_positions]
            )
          )
      ]
    end
  end

  def surrounding_positions({x, y}) do
    for(
      j <- (y - 1)..(y + 1),
      i <- (x - 1)..(x + 1),
      {i, j} !== {x, y},
      do: {i, j}
    )
  end

  def get_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(&1 |> String.graphemes() |> Enum.map(fn x -> String.to_integer(x) end)))
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row |> Enum.with_index() |> Enum.flat_map(fn {val, x} -> [{{x, y}, val}] end)
    end)
    |> Enum.into(%{})
  end

  def render_map(map) do
    for(
      j <- 0..9,
      i <- 0..9,
      do: {i, j}
    )
    |> Enum.map(&Map.get(map, &1))
    |> Enum.chunk_every(10)
    |> Enum.map(fn row -> Enum.join(row) |> IO.puts() end)

    IO.puts("\n")
  end
end
