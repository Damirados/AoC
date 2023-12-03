defmodule Y2023.Event3 do
  def run do
    # IO.puts("Test part1: #{part1("input/Y2023/event3/test.txt")}")
    # IO.puts("Puzzle part1: #{part1("input/Y2023/event3/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2023/event3/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2023/event3/puzzle.txt")}")
  end

  def part1(path) do
    matrix = process_input(path)
    numbers = find_numbers(matrix)
    symbols = Map.reject(matrix, fn {_, val} -> is_integer(val) end)

    numbers
    |> Stream.filter(&is_adjecent_to_symbol(symbols, &1))
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(path) do
    matrix = process_input(path)
    numbers = find_numbers(matrix)
    symbols = Map.filter(matrix, &(elem(&1, 1) == "*"))

    numbers
    |> Enum.group_by(&adjecent_symbol(symbols, &1), &elem(&1, 1))
    |> Map.delete(nil)
    |> Stream.filter(&(&1 |> elem(1) |> length == 2))
    |> Stream.map(fn {_key, ratios} -> Enum.product(ratios) end)
    |> Enum.sum()
  end

  def find_numbers(matrix) do
    Enum.group_by(
      matrix,
      fn {{_x, y}, val} -> is_integer(val) && y end,
      fn {{x, _y}, val} -> {x, val} end
    )
    |> Map.delete(false)
    |> Enum.flat_map(fn {y, row} ->
      chunk_fun = fn {x, val}, {prev_x, starting_x, acc} ->
        cond do
          is_nil(prev_x) and acc == [] ->
            {:cont, {x, x, [val]}}

          is_integer(prev_x) and prev_x + 1 == x ->
            {:cont, {x, starting_x, [val | acc]}}

          is_integer(prev_x) ->
            {
              :cont,
              {{starting_x..prev_x, y}, Enum.reverse(acc) |> Integer.undigits()},
              {x, x, [val]}
            }
        end
      end

      after_fun = fn
        {_, _, []} ->
          {:cont, []}

        {prev_x, starting_x, acc} ->
          {:cont, {{starting_x..prev_x, y}, Enum.reverse(acc) |> Integer.undigits()}, []}
      end

      Enum.sort_by(row, &elem(&1, 0))
      |> Enum.chunk_while({nil, nil, []}, chunk_fun, after_fun)
    end)
  end

  def is_adjecent_to_symbol(symbols, {{x_range, y}, _val}) do
    surrounding_positions = surrounding_positions(x_range, y)
    Enum.any?(Map.keys(symbols), fn key -> key in surrounding_positions end)
  end

  def adjecent_symbol(symbols, {{x_range, y}, _val}) do
    surrounding_positions = surrounding_positions(x_range, y)
    Enum.find(Map.keys(symbols), fn key -> key in surrounding_positions end)
  end

  defp surrounding_positions(x_range, y) do
    number_range = for(i <- x_range, do: {i, y})

    for(
      j <- (y - 1)..(y + 1),
      i <- (x_range.first - 1)..(x_range.last + 1),
      {i, j} not in number_range,
      do: {i, j}
    )
  end

  def process_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn x -> x |> String.graphemes() |> Enum.map(&parse_symbol/1) end)
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {nil, _x} -> []
        {val, x} -> [{{x, y}, val}]
      end)
    end)
    |> Enum.into(%{})
  end

  defp parse_symbol("."), do: nil

  defp parse_symbol(symbol) do
    case Integer.parse(symbol) do
      {integer, _} -> integer
      :error -> symbol
    end
  end
end
