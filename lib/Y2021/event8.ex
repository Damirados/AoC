defmodule Y2021.Event8 do
  def run do
    # IO.puts("Test part1: #{part1("input/Y2021/event8/test.txt")}")
    # IO.puts("Puzzle part1: #{part1("input/Y2021/event8/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event8/test.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event8/puzzle.txt")}")
  end

  def part1(path) do
    path
    |> input_stream()
    |> Stream.map(&Enum.at(&1, 1))
    |> Stream.flat_map(&Enum.map(&1, fn s -> String.length(s) end))
    |> Stream.filter(&(&1 in [2, 4, 3, 7]))
    |> Enum.count()
  end

  def part2(path) do
    path
    |> input_stream()
    |> Stream.map(&calculate_digit_map/1)
    |> Stream.map(&translate_output/1)
    |> Enum.sum()
  end

  def calculate_digit_map([segment_patterns, output]) do
    d1 = Enum.find(segment_patterns, &(String.length(&1) == 2))
    d7 = Enum.find(segment_patterns, &(String.length(&1) == 3))
    d4 = Enum.find(segment_patterns, &(String.length(&1) == 4))
    d8 = Enum.find(segment_patterns, &(String.length(&1) == 7))

    s1 = remove_sub(d7, d1)

    s7 =
      segment_patterns
      |> Enum.find(&(String.length(&1) == 5 and contains_sub(&1, d7)))
      |> remove_sub(d7)
      |> remove_sub(d4)

    s4 =
      segment_patterns
      |> Enum.find(&(String.length(&1) == 5 and contains_sub(&1, d7)))
      |> remove_sub(d7)
      |> remove_sub(s7)

    s2 = d4 |> remove_sub(d1) |> remove_sub(s4)

    s6 =
      segment_patterns
      |> Enum.find(&(String.length(&1) == 5 and contains_sub(&1, s1 <> s2 <> s4 <> s7)))
      |> remove_sub(s1 <> s2 <> s4 <> s7)

    s3 = remove_sub(d1, s6)
    s5 = remove_sub(d8, Enum.join([s1, s2, s3, s4, s6, s7]))

    d2 =
      Enum.find(
        segment_patterns,
        &(String.length(&1) == 5 and contains_sub(&1, Enum.join([s1, s3, s4, s5, s7])))
      )

    d3 =
      Enum.find(
        segment_patterns,
        &(String.length(&1) == 5 and contains_sub(&1, Enum.join([s1, s3, s4, s6, s7])))
      )

    d5 =
      Enum.find(
        segment_patterns,
        &(String.length(&1) == 5 and contains_sub(&1, Enum.join([s1, s2, s4, s6, s7])))
      )

    d6 =
      Enum.find(
        segment_patterns,
        &(String.length(&1) == 6 and contains_sub(&1, Enum.join([s1, s2, s4, s5, s6, s7])))
      )

    d9 =
      Enum.find(
        segment_patterns,
        &(String.length(&1) == 6 and contains_sub(&1, Enum.join([s1, s2, s3, s4, s6, s7])))
      )

    d0 =
      Enum.find(
        segment_patterns,
        &(String.length(&1) == 6 and contains_sub(&1, Enum.join([s1, s2, s3, s5, s6, s7])))
      )

    [
      %{d0 => 0, d1 => 1, d2 => 2, d3 => 3, d4 => 4, d5 => 5, d6 => 6, d7 => 7, d8 => 8, d9 => 9},
      output
    ]
  end

  def translate_output([digit_map, output]) do
    IO.inspect(binding())

    Enum.map(
      output,
      &Enum.find_value(digit_map, fn {key, val} ->
        String.length(key) == String.length(&1) && contains_sub(key, &1) && val
      end)
    )
    |> Integer.undigits()
    |> IO.inspect()
  end

  def remove_sub(string, sub), do: String.replace(string, String.graphemes(sub), "")

  def contains_sub(string, sub),
    do: String.graphemes(sub) |> Enum.all?(&String.contains?(string, &1))

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input), do: String.trim(input) |> String.split("|") |> Enum.map(&parse_vals/1)

  def parse_vals(vals), do: String.trim(vals) |> String.split()
end
