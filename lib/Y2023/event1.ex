defmodule Y2023.Event1 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2023/event1/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2023/event1/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2023/event1/test2.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2023/event1/puzzle.txt")}")
  end

  def part1(path) do
    path
    |> input_stream()
    |> Stream.map(&parse_digits/1)
    |> Stream.map(&Integer.undigits/1)
    |> Enum.sum()
  end

  def part2(path) do
    path
    |> input_stream()
    |> Stream.map(&parse_digits2/1)
    |> Stream.map(&Integer.undigits/1)
    |> Enum.sum()
  end

  defp input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)
  defp parse_input(input), do: String.trim(input) |> String.graphemes()

  defp parse_digits(graphemes) do
    Enum.flat_map(
      graphemes,
      &case Integer.parse(&1) do
        {int, _} -> [int]
        :error -> []
      end
    )
  end

  defp parse_digits2(graphemes) do
    chunk_fun = fn element, acc ->
      case Integer.parse(element) do
        {int, _} ->
          {:cont, int, []}

        :error ->
          word = Enum.reverse([element | acc]) |> Enum.join()

          cond do
            String.contains?(word, "one") -> {:cont, 1, ["e"]}
            String.contains?(word, "two") -> {:cont, 2, ["o"]}
            String.contains?(word, "three") -> {:cont, 3, ["e"]}
            String.contains?(word, "four") -> {:cont, 4, []}
            String.contains?(word, "five") -> {:cont, 5, ["e"]}
            String.contains?(word, "six") -> {:cont, 6, []}
            String.contains?(word, "seven") -> {:cont, 7, ["n"]}
            String.contains?(word, "eight") -> {:cont, 8, ["t"]}
            String.contains?(word, "nine") -> {:cont, 9, ["e"]}
            true -> {:cont, [element | acc]}
          end
      end
    end

    after_fun = fn _ -> {:cont, []} end

    Enum.chunk_while(graphemes, [], chunk_fun, after_fun)
  end
end
