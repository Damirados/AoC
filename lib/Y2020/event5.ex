defmodule Y2020.Event5 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2020/event5/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2020/event5/puzzle.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event5/puzzle.txt")}")
  end

  def part1(path), do: input_stream(path) |> Stream.map(&seat_id/1) |> Enum.max()

  def part2(path) do
    input_stream(path)
    |> Stream.map(&seat_id/1)
    |> Enum.sort()
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.find_value(fn [x, z] -> z == x + 2 && x + 1 end)
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&String.trim/1)

  # Did much uglier version of this with recursion as solution
  # then saw comprehension version on elixir forum
  def seat_id(boarding_pass) do
    <<id::integer-10>> = for <<char <- boarding_pass>>, into: <<>>, do: char_to_bit(char)
    id
  end

  def char_to_bit(c) when c in 'FL', do: <<0::1>>
  def char_to_bit(c) when c in 'BR', do: <<1::1>>
end
