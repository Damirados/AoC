defmodule Y2020.Event13 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2020/event13/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2020/event13/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2020/event13/test.txt", 0)}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event13/puzzle.txt", 170_000_000_000_000)}")
  end

  def part1(path), do: find_earliest_id(get_input(path))
  def part2(path, start_point), do: find_cascading_ts(get_input(path) |> elem(1), start_point)

  def get_input(path) do
    input_stream = File.stream!(path)
    ts = Enum.take(input_stream, 1) |> List.first() |> String.trim() |> String.to_integer()

    ids =
      input_stream
      |> Stream.drop(1)
      |> Enum.take(1)
      |> List.first()
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&((&1 != "x" && String.to_integer(&1)) || &1))

    {ts, ids}
  end

  def find_earliest_id({ts, ids}) do
    {nts, id} =
      Enum.map(ids, &find_next_ts(ts, &1))
      |> Enum.reject(&is_nil/1)
      |> Enum.min_by(&elem(&1, 0))

    (nts - ts) * id
  end

  def find_next_ts(_ts, "x"), do: nil

  def find_next_ts(ts, id) do
    {
      Stream.iterate(ts - rem(ts, id), &(&1 + id))
      |> Stream.reject(&(&1 < ts))
      |> Enum.take(1)
      |> List.first(),
      id
    }
  end

  def find_cascading_ts(ids, _sp) do
    ids
    |> Stream.with_index()
    |> Stream.reject(&(elem(&1, 0) == "x"))
    |> Enum.reduce(fn two, one -> find_step([one, two]) end)
    |> elem(0)
  end

  def find_step([{id, i}, {id2, inc}]) do
    period = if i == 0, do: id, else: i

    {Stream.iterate(id, &(&1 + period))
     |> Enum.find(&(rem(&1 + inc, id2) == 0)), lcm(period, id2)}
  end

  def lcm(a, b), do: div(a * b, Integer.gcd(a, b))
end
