defmodule Event6 do
  def run do
    IO.puts("Test part1: #{part1("input/event6/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/event6/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/event6/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/event6/puzzle.txt")}")
  end

  def part1(path) do
    input_stream(path)
    |> collect_answers()
    |> Stream.map(&count_answers/1)
    |> Enum.sum()
  end

  def part2(path) do
    input_stream(path)
    |> collect_answers()
    |> Stream.map(&count_answers2/1)
    |> Enum.sum()
  end

  def collect_answers(stream) do
    Stream.chunk_while(
      stream,
      [],
      fn
        "", acc -> {:cont, Enum.reverse(acc), []}
        answers, [] -> {:cont, [answers]}
        answers, group -> {:cont, [answers | group]}
      end,
      &{:cont, Enum.reverse(&1), []}
    )
  end

  def count_answers(group) do
    group
    |> Enum.reduce(&<>/2)
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.count()
  end

  def count_answers2(group) do
    people = length(group)

    group
    |> Enum.flat_map(&(&1 |> String.graphemes() |> Enum.uniq()))
    |> Enum.group_by(& &1)
    |> Enum.flat_map(fn {key, value} -> (length(value) == people && [key]) || [] end)
    |> Enum.count()
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&String.trim/1)
end
