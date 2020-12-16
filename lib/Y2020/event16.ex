defmodule Y2020.Event16 do
  def run do
    # IO.puts("Test part1: #{part1("input/Y2020/event16/test.txt")}")
    # IO.puts("Puzzle part1: #{part1("input/Y2020/event16/puzzle.txt")}")
    # IO.puts("Test part2: #{part2("input/Y2020/event16/test2.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event16/puzzle.txt")}")
  end

  def part1(path) do
    {rules, _, nearby} = get_input(path)

    ranges = Enum.concat(Map.values(rules))

    Enum.flat_map(nearby, fn ticket ->
      case Enum.find(ticket, fn n -> Enum.all?(ranges, &(not (n in &1))) end) do
        nil -> []
        n -> [n]
      end
    end)
    |> Enum.sum()
  end

  def part2(path) do
    {rules, ticket, nearby} = get_input(path)

    ranges = Enum.concat(Map.values(rules))

    valid =
      Enum.reject(nearby, fn ticket ->
        Enum.find(ticket, fn n -> Enum.all?(ranges, &(not (n in &1))) end)
      end)

    values_by_index =
      Enum.map(0..(length(ticket) - 1), fn index ->
        Enum.map(valid, &Enum.at(&1, index))
      end)

    possible_value_indexes =
      Enum.map(rules, fn {rule, ranges} ->
        indexes =
          Enum.with_index(values_by_index)
          |> Enum.flat_map(fn {values, index} ->
            if Enum.all?(values, &(&1 in Enum.concat(ranges))), do: [index], else: []
          end)

        {rule, indexes}
      end)
      |> Enum.into(%{})

    value_indexes =
      Enum.reduce(
        possible_value_indexes,
        {possible_value_indexes, %{}},
        fn _, {leftover, acc} ->
          solved =
            Enum.flat_map(leftover, fn
              {key, [val]} -> [{key, val}]
              _ -> []
            end)
            |> Enum.into(%{})

          solved_values = Map.values(solved)

          leftover =
            Map.drop(leftover, Map.keys(solved))
            |> Enum.map(fn {key, values} ->
              {key, Enum.reduce(solved_values, values, &List.delete(&2, &1))}
            end)
            |> Enum.into(%{})

          {leftover, Map.merge(acc, solved)}
        end
      )
      |> elem(1)

    Enum.map(value_indexes, fn {value, index} -> {value, Enum.at(ticket, index)} end)
    |> Enum.flat_map(fn {key, val} ->
      if String.contains?(key, "departure"), do: [val], else: []
    end)
    |> case do
      [] -> 0
      list -> Enum.reduce(list, &*/2)
    end
  end

  def get_input(path) do
    input_blocks =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_by(&(&1 == ""))
      |> Enum.reject(&(&1 == [""]))

    rules =
      input_blocks
      |> List.first()
      |> Stream.map(&parse_rule/1)
      |> Enum.into(%{})

    ticket =
      input_blocks
      |> Enum.at(1)
      |> Enum.at(1)
      |> parse_ticket()

    nearby_tickets =
      input_blocks
      |> Enum.at(2)
      |> Enum.drop(1)
      |> Enum.map(&parse_ticket/1)

    {rules, ticket, nearby_tickets}
  end

  def parse_rule(rule) do
    [key, val] = String.split(rule, ":")
    ranges = String.split(val, "or") |> Enum.map(&parse_range/1)
    {key, ranges}
  end

  def parse_range(range) do
    [from, to] =
      String.trim(range)
      |> String.split("-")

    String.to_integer(from)..String.to_integer(to)
  end

  def parse_ticket(ticket), do: ticket |> String.split(",") |> Enum.map(&String.to_integer/1)
end
