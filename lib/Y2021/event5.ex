defmodule Y2021.Event5 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event5/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event5/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event5/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event5/puzzle.txt")}")
  end

  def part1(path) do
    input = path |> input_stream()

    Enum.reduce(input, %{}, &reduce_fun/2)
    |> Map.values()
    |> Enum.filter(&(&1 > 1))
    |> Enum.count()
  end

  def part2(path) do
    input = path |> input_stream()

    Enum.reduce(input, %{}, &reduce_fun2/2)
    |> Map.values()
    |> Enum.filter(&(&1 > 1))
    |> Enum.count()
  end

  def reduce_fun({{x1, y}, {x2, y}}, acc),
    do: Enum.reduce(x1..x2, acc, fn x, acc -> Map.update(acc, {x, y}, 1, &(&1 + 1)) end)

  def reduce_fun({{x, y1}, {x, y2}}, acc),
    do: Enum.reduce(y1..y2, acc, fn y, acc -> Map.update(acc, {x, y}, 1, &(&1 + 1)) end)

  def reduce_fun(_, acc), do: acc

  def reduce_fun2({{x1, y}, {x2, y}}, acc),
    do: Enum.reduce(x1..x2, acc, fn x, acc -> Map.update(acc, {x, y}, 1, &(&1 + 1)) end)

  def reduce_fun2({{x, y1}, {x, y2}}, acc),
    do: Enum.reduce(y1..y2, acc, fn y, acc -> Map.update(acc, {x, y}, 1, &(&1 + 1)) end)

  def reduce_fun2({{x1, y1}, {x2, y2}}, acc) do
    Enum.reduce(Enum.zip(x1..x2, y1..y2), acc, fn {x, y}, acc ->
      Map.update(acc, {x, y}, 1, &(&1 + 1))
    end)
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    pairs = String.trim(input) |> String.split(" -> ")

    [x1, y1, x2, y2] =
      Enum.flat_map(pairs, fn pair ->
        String.split(pair, ",") |> Enum.map(&String.to_integer/1)
      end)

    {{x1, y1}, {x2, y2}}
  end
end
