defmodule Y2021.Event13 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event13/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event13/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event13/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event13/puzzle.txt")}")
  end

  def part1(path) do
    {map, folds} = get_input(path)

    Enum.reduce(folds |> Enum.take(1), map, &fold/2)
    |> Enum.uniq()
    |> Enum.sort_by(fn {x, y} -> x * 1000 + y end)
    |> Enum.count()
  end

  def part2(path) do
    {map, folds} = get_input(path)

    Enum.reduce(folds, map, &fold/2)
    |> Enum.uniq()
    |> render_map()
  end

  def fold({"x", line}, map) do
    Enum.map(map, fn {x, y} = kv ->
      af = x - line
      if af > 0, do: {line - af, y}, else: kv
    end)
  end

  def fold({"y", line}, map) do
    Enum.map(map, fn {x, y} = kv ->
      af = y - line
      if af > 0, do: {x, line - af}, else: kv
    end)
  end

  def get_input(path) do
    {dots, folds} =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Enum.into([])
      |> Enum.split_while(&(&1 !== ""))

    map =
      Enum.map(
        dots,
        &(String.split(&1, ",") |> Enum.map(fn x -> String.to_integer(x) end) |> List.to_tuple())
      )

    folds =
      Enum.reject(folds, &(&1 == ""))
      |> Enum.map(fn line ->
        {axis, n} = line |> String.split() |> List.last() |> String.split("=") |> List.to_tuple()
        {axis, String.to_integer(n)}
      end)

    {map, folds}
  end

  def render_map(map) do
    xs = Enum.map(map, &elem(&1, 0))
    x = Enum.max(xs)
    ys = Enum.map(map, &elem(&1, 1))
    y = Enum.max(ys)

    for(
      j <- 0..y,
      i <- 0..x,
      do: {i, j}
    )
    |> Enum.map(&((&1 in map && "#") || " "))
    |> Enum.chunk_every(x + 1)
    |> Enum.map(fn row -> Enum.join(row) |> IO.puts() end)

    IO.puts("\n")
  end
end
