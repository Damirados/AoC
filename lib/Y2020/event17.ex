defmodule Y2020.Event17 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2020/event17/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2020/event17/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2020/event17/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event17/puzzle.txt")}")
  end

  def part1(path),
    do: fill_n_cycles(get_input(path), &fill_cube/2, 6) |> Enum.count(&elem(&1, 1))

  def part2(path),
    do: fill_n_cycles2(get_input2(path), &fill_cube2/2, 6) |> Enum.count(&elem(&1, 1))

  # def part2(path), do: fill_till_constant(get_input(path), &fill_seat2/2)

  def get_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row |> Enum.with_index() |> Enum.flat_map(fn {val, x} -> [{{x, y, 0}, val == "#"}] end)
    end)
    |> Enum.into(%{})
  end

  def get_input2(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row |> Enum.with_index() |> Enum.flat_map(fn {val, x} -> [{{x, y, 0, 0}, val == "#"}] end)
    end)
    |> Enum.into(%{})
  end

  def fill_n_cycles(cubes, filler, n, c \\ 0)
  def fill_n_cycles(cubes, _filler, n, n), do: cubes

  def fill_n_cycles(cubes, filler, n, c) do
    new_cubes = fill(cubes, filler)
    fill_n_cycles(new_cubes, filler, n, c + 1)
  end

  def fill_n_cycles2(cubes, filler, n, c \\ 0)
  def fill_n_cycles2(cubes, _filler, n, n), do: cubes

  def fill_n_cycles2(cubes, filler, n, c) do
    new_cubes = fill2(cubes, filler)
    fill_n_cycles2(new_cubes, filler, n, c + 1)
  end

  def fill(cubes, filler) do
    Enum.flat_map(iteration_map(cubes), &filler.(&1, cubes)) |> Enum.into(%{})
  end

  def fill2(cubes, filler) do
    Enum.flat_map(iteration_map2(cubes), &filler.(&1, cubes)) |> Enum.into(%{})
  end

  def iteration_map(cubes) do
    keys = Map.keys(cubes)
    {{minx, _, _}, {maxx, _, _}} = Enum.min_max_by(keys, &elem(&1, 0))
    {{_, miny, _}, {_, maxy, _}} = Enum.min_max_by(keys, &elem(&1, 1))
    {{_, _, minz}, {_, _, maxz}} = Enum.min_max_by(keys, &elem(&1, 2))

    for(
      k <- (minz - 1)..(maxz + 1),
      j <- (miny - 1)..(maxy + 1),
      i <- (minx - 1)..(maxx + 1),
      do: {i, j, k}
    )
  end

  def iteration_map2(cubes) do
    keys = Map.keys(cubes)
    {{minx, _, _, _}, {maxx, _, _, _}} = Enum.min_max_by(keys, &elem(&1, 0))
    {{_, miny, _, _}, {_, maxy, _, _}} = Enum.min_max_by(keys, &elem(&1, 1))
    {{_, _, minz, _}, {_, _, maxz, _}} = Enum.min_max_by(keys, &elem(&1, 2))
    {{_, _, _, minw}, {_, _, _, maxw}} = Enum.min_max_by(keys, &elem(&1, 3))

    for(
      l <- (minw - 1)..(maxw + 1),
      k <- (minz - 1)..(maxz + 1),
      j <- (miny - 1)..(maxy + 1),
      i <- (minx - 1)..(maxx + 1),
      do: {i, j, k, l}
    )
  end

  def fill_cube(position, cubes) do
    surrounding_positions(position)
    |> Enum.map(&Map.get(cubes, &1, false))
    |> Enum.count(& &1)
    |> new_position({position, Map.get(cubes, position, false)})
  end

  def fill_cube2(position, cubes) do
    surrounding_positions2(position)
    |> Enum.map(&Map.get(cubes, &1, false))
    |> Enum.count(& &1)
    |> new_position({position, Map.get(cubes, position, false)})
  end

  def new_position(3, {position, false}), do: [{position, true}]
  def new_position(count, {position, true}) when count in [2, 3], do: [{position, true}]
  def new_position(_, _), do: []

  def surrounding_positions({x, y, z}) do
    for(
      k <- (z - 1)..(z + 1),
      j <- (y - 1)..(y + 1),
      i <- (x - 1)..(x + 1),
      {i, j, k} !== {x, y, z},
      do: {i, j, k}
    )
  end

  def surrounding_positions2({x, y, z, w}) do
    for(
      l <- (w - 1)..(w + 1),
      k <- (z - 1)..(z + 1),
      j <- (y - 1)..(y + 1),
      i <- (x - 1)..(x + 1),
      {i, j, k, l} !== {x, y, z, w},
      do: {i, j, k, l}
    )
  end
end
