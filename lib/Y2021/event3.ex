defmodule Y2021.Event3 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event3/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event3/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event3/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event3/puzzle.txt")}")
  end

  def part1(path) do
    input = path |> input_stream() |> Enum.into([])

    width = input |> List.first() |> Enum.count()
    length = Enum.count(input)
    start = Enum.map(1..width, &(&1 * 0))

    gamma =
      Enum.reduce(input, start, fn x, acc ->
        Enum.zip_with([acc, x], fn [a, b] -> a + b end)
      end)
      |> Enum.map(&((&1 > length / 2 && 1) || 0))
      |> Enum.join()

    epsilon = gamma |> String.graphemes() |> Enum.map(&((&1 == "1" && "0") || "1")) |> Enum.join()

    gamma = String.to_integer(gamma, 2)
    epsilon = String.to_integer(epsilon, 2)

    gamma * epsilon
  end

  def part2(path) do
    input = path |> input_stream() |> Enum.into([])
    width = List.first(input) |> Enum.count()
    indexes = 0..(width - 1)

    o2_rating =
      Enum.reduce_while(indexes, input, fn index, acc ->
        length = Enum.count(acc)
        bit_criteria = Enum.map(count_vertical_bits(acc), &((&1 >= length / 2 && 1) || 0))

        Enum.filter(acc, &(Enum.at(&1, index) == Enum.at(bit_criteria, index)))
        |> case do
          [n] -> {:halt, n}
          other -> {:cont, other}
        end
      end)
      |> bitlist_to_decimal()

    co2_rating =
      Enum.reduce_while(indexes, input, fn index, acc ->
        length = Enum.count(acc)
        bit_criteria = Enum.map(count_vertical_bits(acc), &((&1 < length / 2 && 1) || 0))

        Enum.filter(acc, &(Enum.at(&1, index) == Enum.at(bit_criteria, index)))
        |> case do
          [n] -> {:halt, n}
          other -> {:cont, other}
        end
      end)
      |> bitlist_to_decimal()

    o2_rating * co2_rating
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    String.trim(input)
    |> String.graphemes()
    |> Enum.map(&((&1 == "1" && 1) || 0))
  end

  def count_vertical_bits(matrix) do
    width = matrix |> List.first() |> Enum.count()
    zero_list = Enum.map(1..width, &(&1 * 0))

    Enum.reduce(matrix, zero_list, fn x, acc ->
      Enum.zip_with([acc, x], fn [a, b] -> a + b end)
    end)
  end

  def bitlist_to_decimal(bit_list), do: bit_list |> Enum.join() |> String.to_integer(2)
end
