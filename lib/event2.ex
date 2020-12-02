defmodule Event2 do
  def run do
    IO.puts("Test part1: #{part1("input/event2/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/event2/puzzle.txt")}")
    IO.puts("Test part1: #{part2("input/event2/test.txt")}")
    IO.puts("Puzzle part1: #{part2("input/event2/puzzle.txt")}")
  end

  def part1(path), do: input_stream(path) |> Stream.filter(&filter_fun/1) |> Enum.count()
  def part2(path), do: input_stream(path) |> Stream.filter(&filter_fun2/1) |> Enum.count()

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    [positions_s, letter_s, pass_s] = String.split(input, " ")
    [low, high] = String.split(positions_s, "-")
    [letter, _] = String.split(letter_s, ":")
    [pass, _] = String.split(pass_s, "\n")
    {String.to_integer(low), String.to_integer(high), letter, pass}
  end

  def filter_fun({low, high, letter, pass}) do
    pass_letter_count = pass |> String.graphemes() |> Enum.count(&(&1 == letter))
    low <= pass_letter_count and pass_letter_count <= high
  end

  def filter_fun2({low, high, letter, pass}) do
    low_contains = binary_part(pass, low - 1, 1) == letter
    high_contains = binary_part(pass, high - 1, 1) == letter
    :erlang.xor(low_contains, high_contains)
  end
end
