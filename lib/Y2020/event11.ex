defmodule Y2020.Event11 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2020/event11/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2020/event11/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2020/event11/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event11/puzzle.txt")}")
  end

  def part1(path), do: fill_till_constant(get_input(path), &fill_seat/2)
  def part2(path), do: fill_till_constant(get_input(path), &fill_seat2/2)

  def get_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row |> Enum.with_index() |> Enum.flat_map(fn {val, x} -> [{{x, y}, val}] end)
    end)
    |> Enum.into(%{})
  end

  def fill_till_constant(seat_map, filler) do
    occupied = Map.values(seat_map) |> Enum.count(&(&1 == "#"))
    new_seat_map = fill(seat_map, filler)
    after_fill_occupied = Map.values(new_seat_map) |> Enum.count(&(&1 == "#"))

    if occupied == after_fill_occupied,
      do: after_fill_occupied,
      else: fill_till_constant(new_seat_map, filler)
  end

  def fill(seat_map, filler), do: Enum.map(seat_map, &filler.(&1, seat_map)) |> Enum.into(%{})

  def fill_seat(val = {_, "."}, _), do: val

  def fill_seat(val = {position, _}, seat_map) do
    surrounding_positions(position)
    |> Enum.map(&Map.get(seat_map, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.count(&(&1 == "#"))
    |> new_position(val)
  end

  def new_position(0, {position, "L"}), do: {position, "#"}
  def new_position(count, {position, "#"}) when count >= 4, do: {position, "L"}
  def new_position(_, val), do: val

  def fill_seat2(val = {_, "."}, _), do: val

  def fill_seat2(val = {position, _}, seat_map) do
    directions()
    |> Enum.map(&find_seat(seat_map, position, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.count(&(&1 == "#"))
    |> new_position2(val)
  end

  def new_position2(0, {position, "L"}), do: {position, "#"}
  def new_position2(count, {position, "#"}) when count >= 5, do: {position, "L"}
  def new_position2(_, val), do: val

  def find_seat(seat_map, {x, y}, {i, j}) do
    search_position = {x + i, y + j}

    case Map.get(seat_map, search_position) do
      "." -> find_seat(seat_map, search_position, {i, j})
      other -> other
    end
  end

  def surrounding_positions({x, y}),
    do: for(j <- (y - 1)..(y + 1), i <- (x - 1)..(x + 1), {i, j} !== {x, y}, do: {i, j})

  def directions, do: for(j <- -1..1, i <- -1..1, {i, j} !== {0, 0}, do: {i, j})
end
