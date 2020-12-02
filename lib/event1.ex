defmodule Event1 do
  def run do
    IO.puts("Test part1: #{part1("input/event1/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/event1/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/event1/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/event1/puzzle.txt")}")
  end

  def part1(path), do: input_stream(path) |> Enum.into([]) |> find_result()
  def part2(path), do: input_stream(path) |> Enum.into([]) |> find_result2()

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)
  def parse_input(input), do: input |> Integer.parse() |> elem(0)

  def find_result(inputs) do
    try do
      for(i <- inputs, j <- inputs, i + j == 2020, do: throw(i * j))
    catch
      x -> x
    end
  end

  def find_result2(inputs) do
    try do
      for(i <- inputs, j <- inputs, k <- inputs, i + j + k == 2020, do: throw(i * j * k))
    catch
      x -> x
    end
  end
end
