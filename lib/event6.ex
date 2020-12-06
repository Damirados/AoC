defmodule Event6 do
  def run do
    IO.puts("Test part1: #{solver("input/event6/test.txt", &count_answers/1)}")
    IO.puts("Puzzle part1: #{solver("input/event6/puzzle.txt", &count_answers/1)}")
    IO.puts("Test part2: #{solver("input/event6/test.txt", &count_answers2/1)}")
    IO.puts("Puzzle part2: #{solver("input/event6/puzzle.txt", &count_answers2/1)}")
  end

  def solver(path, counter),
    do: input_stream(path) |> Stream.chunk_by(&(&1 == "")) |> Stream.map(counter) |> Enum.sum()

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&String.trim/1)

  def count_answers(group),
    do: group |> Enum.reduce(&<>/2) |> String.graphemes() |> Enum.uniq() |> Enum.count()

  def count_answers2(group) do
    people = length(group)

    group
    |> Enum.flat_map(&(&1 |> String.graphemes() |> Enum.uniq()))
    |> Enum.group_by(& &1)
    |> Enum.flat_map(fn {key, value} -> (length(value) == people && [key]) || [] end)
    |> Enum.count()
  end
end
