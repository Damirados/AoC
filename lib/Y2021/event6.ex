defmodule Y2021.Event6 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event6/test.txt", 18)}")
    IO.puts("Test part1: #{part1("input/Y2021/event6/test.txt", 80)}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event6/puzzle.txt", 80)}")
    IO.puts("Test part2: #{part2("input/Y2021/event6/test.txt", 18)}")
    IO.puts("Test part2: #{part2("input/Y2021/event6/test.txt", 80)}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event6/puzzle.txt", 80)}")
    IO.puts("Test part2 full: #{part2("input/Y2021/event6/test.txt", 256)}")
    IO.puts("Puzzle part2 full: #{part2("input/Y2021/event6/puzzle.txt", 256)}")
  end

  def part1(path, days) do
    input = path |> input_stream() |> Enum.at(0)

    Enum.reduce(1..days, input, fn d, acc ->
      {new_acc, count} =
        Enum.map_reduce(acc, 0, fn
          0, acc -> {6, acc + 1}
          x, acc -> {x - 1, acc}
        end)

      new_tail = Stream.repeatedly(fn -> 8 end) |> Enum.take(count)
      new_acc ++ new_tail
    end)
    |> Enum.count()
  end

  def part2(path, days) do
    input = path |> input_stream() |> Enum.at(0) |> IO.inspect()
    counts = Enum.map(0..8, &{&1, 0}) |> Enum.into(%{})
    acc = Enum.reduce(input, counts, &Map.update(&2, &1, 1, fn x -> x + 1 end))

    Enum.reduce(1..days, acc, fn _d, acc ->
      %{
        0 => acc[1],
        1 => acc[2],
        2 => acc[3],
        3 => acc[4],
        4 => acc[5],
        5 => acc[6],
        6 => acc[7] + acc[0],
        7 => acc[8],
        8 => acc[0]
      }
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def calc_for_number(n, days) do
    Enum.reduce(1..days, [n], fn d, acc ->
      IO.inspect({d, Enum.count(acc)})

      {new_acc, count} =
        Enum.map_reduce(acc, 0, fn
          0, acc -> {6, acc + 1}
          x, acc -> {x - 1, acc}
        end)

      new_tail = Stream.repeatedly(fn -> 8 end) |> Enum.take(count)
      new_acc ++ new_tail
    end)
    |> Enum.count()
  end

  def calc_for_number2(n, days) do
    1 + n_of_children(n, days)
  end

  def n_of_children(x, days) when days <= x, do: 0
  def n_of_children(x, days) when days - 1 == x, do: 1

  def n_of_children(x, days) do
    n_of_children = 1 + div(days - (x + 1), 7)

    childrens_children =
      1..n_of_children
      |> Enum.map(&n_of_children(0, days - (x + 2) - &1 * 7))
      |> Enum.sum()

    n_of_children + childrens_children
  end

  def calc_for_number3(n, days) do
    n_of_children2(n, days)
  end

  def tt(n, days) do
    IO.inspect(calc_for_number2(n, days), label: "number")
    # n_of_children2(n, days)
  end

  def n_of_children2(x, days) do
    solve_days(days - x)
  end

  def gchild_branch(days), do: Enum.map(1..(div(days, 9) + 1), &(days - &1 * 9))

  def solve_days(days) when days < 1, do: 1
  def solve_days(days) when days < 8, do: 2

  def solve_days(days) do
    solve_days(days - 7) + solve_days(days - 9)
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input),
    do: String.trim(input) |> String.split(",") |> Enum.map(&String.to_integer/1)
end
