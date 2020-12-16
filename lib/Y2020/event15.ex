defmodule Y2020.Event15 do
  @test [0, 3, 6]
  @test2 [2, 1, 3]
  @puzzle [0, 6, 1, 7, 2, 19, 20]

  def run do
    IO.puts("Test part1: #{solve(@test, 2020)}")
    IO.puts("Test2 part1: #{solve(@test2, 2020)}")
    IO.puts("Puzzle part1: #{solve(@puzzle, 2020)}")
    IO.puts("Test part2: #{solve(@test, 30_000_000)}")
    IO.puts("Puzzle part2: #{solve(@puzzle, 30_000_000)}")
  end

  def solve(numbers, x) do
    map = numbers |> Enum.with_index(1) |> Enum.into(%{})
    find_xth(map, 0, map_size(map) + 1, x)
  end

  def find_xth(_map, last, count, count), do: last

  def find_xth(map, last, count, x) do
    case Map.get(map, last) do
      nil ->
        find_xth(Map.put(map, last, count), 0, count + 1, x)

      index ->
        find_xth(Map.put(map, last, count), count - index, count + 1, x)
    end
  end
end
