defmodule Y2021.Event10 do
  def run do
    # IO.puts("Test part1: #{part1("input/Y2021/event10/test.txt")}")
    # IO.puts("Puzzle part1: #{part1("input/Y2021/event10/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event10/test.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event10/puzzle.txt")}")
  end

  def part1(path) do
    input_stream(path)
    |> Enum.flat_map(&check_line/1)
    |> Enum.reduce(0, fn
      ")", acc -> acc + 3
      "]", acc -> acc + 57
      "}", acc -> acc + 1197
      ">", acc -> acc + 25137
    end)
  end

  def part2(path) do
    input_stream(path)
    |> Enum.flat_map(&check_line2/1)
    |> IO.inspect()
    |> Enum.map(&calculate_score/1)
    |> Enum.sort()
    |> IO.inspect()
    |> find_median()
  end

  def check_line(line) do
    Enum.reduce_while(line, [], fn
      b, [] ->
        case b do
          b when b in ~w/( [ { </ -> {:cont, [b]}
          b when b in ~w/) ] } >/ -> {:halt, {:corrupted, b}}
        end

      b, [c | tail] = acc ->
        case b do
          b when b in ~w/( [ { </ -> {:cont, [b | acc]}
          ")" when c == "(" -> {:cont, tail}
          "]" when c == "[" -> {:cont, tail}
          "}" when c == "{" -> {:cont, tail}
          ">" when c == "<" -> {:cont, tail}
          b when b in ~w/) ] } >/ -> {:halt, {:corrupted, b}}
        end
        |> IO.inspect()
    end)
    |> case do
      {:corrupted, b} -> [b]
      _ -> []
    end
  end

  def check_line2(line) do
    Enum.reduce_while(line, [], fn
      b, [] ->
        case b do
          b when b in ~w/( [ { </ -> {:cont, [b]}
          b when b in ~w/) ] } >/ -> {:halt, {:corrupted, b}}
        end

      b, [c | tail] = acc ->
        case b do
          b when b in ~w/( [ { </ -> {:cont, [b | acc]}
          ")" when c == "(" -> {:cont, tail}
          "]" when c == "[" -> {:cont, tail}
          "}" when c == "{" -> {:cont, tail}
          ">" when c == "<" -> {:cont, tail}
          b when b in ~w/) ] } >/ -> {:halt, {:corrupted, b}}
        end
    end)
    |> case do
      {:corrupted, _} -> []
      closings -> [closings]
    end
  end

  def calculate_score(closings),
    do: Enum.reduce(closings, 0, fn x, acc -> acc * 5 + c_score(x) end)

  def c_score("("), do: 1
  def c_score("["), do: 2
  def c_score("{"), do: 3
  def c_score("<"), do: 4

  def find_median(list) do
    Enum.at(list, div(length(list), 2))
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input), do: String.trim(input) |> String.graphemes()
end
