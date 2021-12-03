defmodule Y2021.Event2 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event2/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event2/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event2/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event2/puzzle.txt")}")
  end

  def part1(path), do: input_stream(path) |> Enum.reduce({0, 0}, &reduce_fun/2) |> multiply()

  def part2(path), do: input_stream(path) |> Enum.reduce({0, 0, 0}, &reduce_fun2/2) |> multiply2()

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    [direction, units] = String.trim(input) |> String.split(" ", trim: true)
    {direction, String.to_integer(units)}
  end

  def reduce_fun({"forward", x}, {h, v}), do: {h + x, v}
  def reduce_fun({"down", x}, {h, v}), do: {h, v + x}
  def reduce_fun({"up", x}, {h, v}), do: {h, v - x}

  def multiply({h, v}), do: h * v

  def reduce_fun2({"forward", x}, {h, v, a}), do: {h + x, v + x * a, a}
  def reduce_fun2({"down", x}, {h, v, a}), do: {h, v, a + x}
  def reduce_fun2({"up", x}, {h, v, a}), do: {h, v, a - x}

  def multiply2({h, v, _}), do: h * v
end
