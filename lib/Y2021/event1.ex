defmodule Y2021.Event1 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event1/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event1/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event1/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event1/puzzle.txt")}")
  end

  def part1(path), do: input_stream(path) |> Enum.reduce({0, nil}, &transform_fun/2) |> elem(0)

  def part2(path) do
    input_stream(path)
    |> Stream.chunk_every(3, 1, :discard)
    |> Stream.map(&Enum.sum/1)
    |> Enum.reduce({0, nil}, &transform_fun/2)
    |> elem(0)
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input), do: input |> String.trim() |> String.to_integer()

  def transform_fun(x, {c, nil}), do: {c, x}
  def transform_fun(x, {c, p}) when p < x, do: {c + 1, x}
  def transform_fun(x, {c, _}), do: {c, x}
end
