defmodule Y2021.Event9 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event9/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event9/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event9/test.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event9/puzzle.txt")}")
  end

  def part1(path) do
    map = get_input(path)
    Enum.filter(map, &is_low_point?(&1, map)) |> Enum.map(&(elem(&1, 1) + 1)) |> Enum.sum()
  end

  def part2(path) do
    map = get_input(path)
    low_points = Enum.filter(map, &is_low_point?(&1, map))

    basins =
      Enum.map(
        low_points,
        fn point ->
          IO.inspect(point, label: "getting basin size for")
          b_elements = get_basin_elements(point, map) |> Enum.uniq()
          Enum.count(b_elements) |> IO.inspect(label: "basin_size")
        end
      )

    basins
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.reduce(&(&1 * &2))
  end

  def is_low_point?({_position, 9}, _map), do: false

  def is_low_point?({position, val}, map) do
    surrounding_positions(position)
    |> Enum.map(&Map.get(map, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.all?(&(&1 > val))
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
      {i, j} !== {x, y} and (x == i or y == j) and i >= 0 and j >= 0,
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
end
