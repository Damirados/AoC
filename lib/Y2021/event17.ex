defmodule Y2021.Event17 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event17/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event17/puzzle.txt")}")

    IO.puts("Test part2: #{part2("input/Y2021/event17/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event17/puzzle.txt")}")
  end

  def part1(path) do
    bounds = {x_bounds, _y_bounds} = get_input(path) |> IO.inspect(label: "Bounds")

    min_x_v = min_x_v(x_bounds) |> IO.inspect(label: "Min xv")

    hits = get_hits(min_x_v, bounds)

    Enum.max_by(hits, fn {_, y} -> y end)
    |> elem(1)
    |> n_sum()
  end

  def part2(path) do
    bounds = {x_bounds, _y_bounds} = get_input(path) |> IO.inspect(label: "Bounds")

    min_x_v = min_x_v(x_bounds) |> IO.inspect(label: "Min xv")

    get_hits(min_x_v, bounds) |> Enum.count()
  end

  def min_x_v({min_x, max_x}),
    do: Enum.find_value(n_sums(), fn {x, n_sum} -> n_sum > min_x and n_sum < max_x && x end)

  def get_hits(min_xv, bounds = {{_, max_x}, {min_y, _max_y}}) do
    for j <- min_y..abs(min_y),
        i <- min_xv..max_x,
        try_hit({i, j}, bounds) == :hit,
        do: {i, j}
  end

  def try_hit(vs, bounds, acc \\ {0, 0})

  def try_hit(_, {{_, max_x}, {min_y, _}}, {x, y})
      when x > max_x or y < min_y,
      do: :miss

  def try_hit(_, {{min_x, max_x}, {min_y, max_y}}, {x, y})
      when x >= min_x and x <= max_x and y >= min_y and y <= max_y,
      do: :hit

  def try_hit({0, yv}, bounds, {x, y}) do
    try_hit({0, yv - 1}, bounds, {x, y + yv})
  end

  def try_hit({xv, yv}, bounds, {x, y}) do
    try_hit({xv - 1, yv - 1}, bounds, {x + xv, y + yv})
  end

  def n_sums() do
    Stream.resource(fn -> 1 end, &{[&1], &1 + 1}, & &1)
    |> Stream.map(&{&1, n_sum(&1)})
  end

  def n_sum(n), do: div(n * (n + 1), 2)

  def get_input(path) do
    [[min_x, max_x], [min_y, max_y]] =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Enum.at(0)
      |> String.split(":", trim: true)
      |> IO.inspect()
      |> Enum.at(1)
      |> String.split(",", trim: true)
      |> Enum.map(
        &(&1
          |> String.split("=")
          |> Enum.at(1)
          |> String.split("..")
          |> Enum.map(fn x -> String.to_integer(x) end))
      )

    {{min_x, max_x}, {min_y, max_y}}
  end
end
