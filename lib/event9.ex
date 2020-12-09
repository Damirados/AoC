defmodule Event9 do
  def run do
    IO.puts("Test part1: #{part1("input/event9/test.txt", 5)}")
    IO.puts("Puzzle part1: #{part1("input/event9/puzzle.txt", 25)}")
    IO.puts("Test part2: #{part2("input/event9/test.txt", 5)}")
    IO.puts("Puzzle part2: #{part2("input/event9/puzzle.txt", 25)}")
  end

  def part1(path, preamble_length), do: input_stream(path) |> find_invalid_num(preamble_length)

  def part2(path, preamble_length) do
    input_list = input_stream(path) |> Enum.into([])
    invalid_num = find_invalid_num(input_list, preamble_length)

    continous_list =
      input_list
      |> Stream.chunk_while(
        [],
        fn element, acc ->
          case trim_list_or_find(acc, invalid_num) do
            {:found, acc} -> {:cont, acc, []}
            {:trimmed, acc} -> {:cont, acc ++ [element]}
          end
        end,
        &{:cont, nil, &1}
      )
      |> Enum.take(1)
      |> List.first()

    Enum.min(continous_list) + Enum.max(continous_list)
  end

  def input_stream(path),
    do: path |> File.stream!() |> Stream.map(&(&1 |> String.trim() |> String.to_integer()))

  def find_invalid_num(list, preamble_length) do
    list
    |> Stream.chunk_while(
      [],
      fn element, acc ->
        cond do
          length(acc) < preamble_length ->
            {:cont, [element | acc]}

          true ->
            case find_num(acc, element) do
              [] -> {:cont, element, []}
              num -> {:cont, Enum.take([num | acc], preamble_length)}
            end
        end
      end,
      &{:cont, nil, &1}
    )
    |> Enum.take(1)
    |> List.first()
  end

  def find_num(list, num) do
    try do
      for(i <- list, j <- list, i + j == num, do: throw(num))
    catch
      x -> x
    end
  end

  def trim_list_or_find(list, search_cond) do
    cond do
      Enum.sum(list) > search_cond -> trim_list_or_find(Enum.drop(list, 1), search_cond)
      Enum.sum(list) == search_cond -> {:found, list}
      true -> {:trimmed, list}
    end
  end
end
