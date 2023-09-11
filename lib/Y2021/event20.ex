defmodule Y2021.Event20 do
  require Integer

  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event20/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event20/puzzle.txt")}")

    IO.puts("Test part2: #{part2("input/Y2021/event20/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event20/puzzle.txt")}")
  end

  def part1(path) do
    {algo, map} = get_input(path)

    default = 0
    default_algo = is_lit?(%{}, algo, default, {0, 0})

    Enum.reduce(1..2, map, fn x, acc ->
      def = (Integer.is_odd(x) && default) || default_algo

      map_bounds(acc)
      |> Enum.map(&{&1, is_lit?(acc, algo, def, &1)})
      |> Enum.into(%{})
    end)
    |> Enum.count(&(elem(&1, 1) == 1))
  end

  def part2(path) do
    {algo, map} = get_input(path)

    default = 0
    default_algo = is_lit?(%{}, algo, default, {0, 0})

    Enum.reduce(1..50, map, fn x, acc ->
      def = (Integer.is_odd(x) && default) || default_algo

      map_bounds(acc)
      |> Enum.map(&{&1, is_lit?(acc, algo, def, &1)})
      |> Enum.into(%{})
    end)
    |> Enum.count(&(elem(&1, 1) == 1))
  end

  def is_lit?(map, algo, default, position) do
    surrounding_positions(position)
    |> Enum.map(&Map.get(map, &1, default))
    |> Integer.undigits(2)
    |> then(&Enum.at(algo, &1))
  end

  def map_bounds(map) do
    keys = Map.keys(map)
    xs = Enum.map(keys, &elem(&1, 0))
    ys = Enum.map(keys, &elem(&1, 1))

    min_x = Enum.min(xs)
    max_x = Enum.max(xs)
    min_y = Enum.min(ys)
    max_y = Enum.max(ys)

    for(
      j <- (min_y - 2)..(max_y + 2),
      i <- (min_x - 2)..(max_x + 2),
      do: {i, j}
    )
  end

  def surrounding_positions({x, y}) do
    for(
      j <- (y - 1)..(y + 1),
      i <- (x - 1)..(x + 1),
      do: {i, j}
    )
  end

  def get_input(path) do
    [algo | map] =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Enum.filter(&(&1 != ""))

    map =
      map
      |> Stream.map(&(&1 |> String.graphemes() |> Enum.map(fn x -> to_int(x) end)))
      |> Stream.with_index()
      |> Stream.flat_map(fn {row, y} ->
        row |> Enum.with_index() |> Enum.flat_map(fn {val, x} -> [{{x, y}, val}] end)
      end)
      |> Enum.into(%{})

    algo = algo |> String.graphemes() |> Enum.map(&to_int/1)

    {algo, map}
  end

  def to_int("#"), do: 1
  def to_int("."), do: 0
end
