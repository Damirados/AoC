defmodule Event7 do
  def run do
    IO.puts("Test part1: #{part1("input/event7/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/event7/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/event7/test2.txt")}")
    IO.puts("Puzzle part2: #{part2("input/event7/puzzle.txt")}")
  end

  def part1(path) do
    input_stream(path)
    |> Enum.into([])
    |> get_parents("shiny gold")
    |> Enum.uniq()
    |> Enum.count()
  end

  def part2(path) do
    input_stream(path)
    |> Enum.into([])
    |> count_children("shiny gold")
    |> Kernel.-(1)
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    [bag | rules] =
      input
      |> String.trim()
      |> String.split(~r/contain|[,.]/, trim: true)
      |> Enum.map(&String.trim/1)

    rules =
      Enum.flat_map(rules, fn
        "no other bags" ->
          []

        rule ->
          {count, bag} = rule |> String.split_at(1)
          [{String.to_integer(count), trim_bag(bag)}]
      end)

    {trim_bag(bag), rules}
  end

  def trim_bag(bag), do: bag |> String.replace(["bag", "bags"], "") |> String.trim()

  def get_parents(rules, child) do
    parents =
      Enum.flat_map(rules, fn {bag, bag_rules} ->
        Enum.find_value(bag_rules, [], fn
          {_n, b} when b == child -> [bag]
          _ -> false
        end)
      end)

    Enum.flat_map(parents, &get_parents(rules, &1)) ++ parents
  end

  def count_children(rules, parent) do
    bag_rules = Enum.find_value(rules, fn {bag, bag_rules} -> bag == parent && bag_rules end)
    1 + (Enum.map(bag_rules, fn {n, bag} -> n * count_children(rules, bag) end) |> Enum.sum())
  end
end
