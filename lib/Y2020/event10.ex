defmodule Y2020.Event10 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2020/event10/test.txt")}")
    IO.puts("Test2 part1: #{part1("input/Y2020/event10/test2.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2020/event10/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2020/event10/test.txt")}")
    IO.puts("Test2 part2: #{part2("input/Y2020/event10/test2.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event10/puzzle.txt")}")
    IO.puts("Test part2_optimal: #{part2_optimal("input/Y2020/event10/test.txt")}")
    IO.puts("Test2 part2_optimal: #{part2_optimal("input/Y2020/event10/test2.txt")}")
    IO.puts("Puzzle part2_optimal: #{part2_optimal("input/Y2020/event10/puzzle.txt")}")
  end

  def part1(path) do
    input_list = input_stream(path) |> Enum.sort()
    input_list = input_list ++ [List.last(input_list) + 3]

    {_, one_links, three_links, _} = find_chain(input_list)
    one_links * three_links
  end

  def part2(path) do
    input_list = input_stream(path) |> Enum.sort()
    input_list = input_list ++ [List.last(input_list) + 3]
    {_, _, _, cont_chains} = find_chain(input_list)

    cont_chains
    |> Stream.flat_map(fn
      chain when length(chain) > 2 -> [cont_chain_permutations(chain)]
      _ -> []
    end)
    |> Enum.reduce(&(&1 * &2))
  end

  def part2_optimal(path) do
    input_stream(path)
    |> Enum.sort()
    |> Enum.reduce({[0], [1]}, fn
      element, {interval, accumulators} ->
        relevant_interval = Enum.filter(interval, &(&1 + 3 >= element))
        relevant_accs = Enum.take(accumulators, -length(relevant_interval))

        new_acc =
          (length(relevant_accs) > 1 && Enum.sum(relevant_accs)) || List.last(relevant_accs)

        {relevant_interval ++ [element], relevant_accs ++ [new_acc]}
    end)
    |> elem(1)
    |> List.last()
  end

  def input_stream(path),
    do: path |> File.stream!() |> Stream.map(&(&1 |> String.trim() |> String.to_integer()))

  def find_chain(list) do
    Enum.reduce(list, {0, 0, 0, [[0]]}, fn element,
                                           {last_adapter, one_links, three_links,
                                            cont_chains = [last_chain | prev_chains]} ->
      case element - last_adapter do
        3 ->
          {element, one_links, three_links + 1, [[element] | cont_chains]}

        1 ->
          {element, one_links + 1, three_links, [[element | last_chain] | prev_chains]}
      end
    end)
  end

  def cont_chain_permutations(chain) do
    case length(chain) do
      3 -> 2
      4 -> 4
      5 -> 7
    end
  end
end
