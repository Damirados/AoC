defmodule Event2 do
  def run do
    IO.puts("Test part1: #{part1("input/event2/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/event2/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/event2/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/event2/puzzle.txt")}")
  end

  def part1(path), do: input_stream(path) |> Stream.filter(&filter_fun/1) |> Enum.count()
  def part2(path), do: input_stream(path) |> Stream.filter(&filter_fun2/1) |> Enum.count()

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    [low, high, letter, pass] = String.trim(input) |> String.split(~r/[-: ]/, trim: true)
    {String.to_integer(low), String.to_integer(high), letter, pass}
  end

  def filter_fun({low, high, letter, pass}) do
    pass_letter_count = pass |> String.graphemes() |> Enum.count(&(&1 == letter))
    low <= pass_letter_count and pass_letter_count <= high
  end

  def filter_fun2({low, high, letter, pass}),
    do: :erlang.xor(String.at(pass, low - 1) == letter, String.at(pass, high - 1) == letter)
end
