defmodule Event12 do
  @directions ~w(N E S W)

  def run do
    IO.puts("Test part1: #{part1("input/event12/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/event12/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/event12/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/event12/puzzle.txt")}")
  end

  def part1(path), do: input_stream(path) |> reduce_instructions()
  def part2(path), do: input_stream(path) |> reduce_instructions2()

  def input_stream(path), do: File.stream!(path) |> Stream.map(&parse_input/1)

  def parse_input(input) do
    {d, v} = String.trim(input) |> String.split_at(1)
    {d, String.to_integer(v)}
  end

  def reduce_instructions(stream) do
    %{ns: {_, ns}, ew: {_, ew}} =
      Enum.reduce(stream, %{d: "E", ns: {"N", 0}, ew: {"E", 0}}, &step/2)

    ns + ew
  end

  def step(inst = {d, _}, a) when d in @directions,
    do: %{d: a.d, ns: ns(a, inst), ew: ew(a, inst)}

  def step(inst = {r, _}, a) when r in ["L", "R"],
    do: %{d: nd(a.d, inst), ns: ns(a, inst), ew: ew(a, inst)}

  def step(inst = {"F", _}, a), do: %{d: a.d, ns: ns(a, inst), ew: ew(a, inst)}

  def ns(%{ns: {_, 0}}, {d, v}) when d in ["N", "S"], do: {d, v}
  def ns(%{ns: {d, a}}, {d, v}) when d in ["N", "S"], do: {d, a + v}
  def ns(%{ns: {d_a, a}}, {d, v}) when d in ["N", "S"], do: {(a - v < 0 && d) || d_a, abs(a - v)}
  def ns(%{d: d, ns: {d, a}}, {"F", v}) when d in ["N", "S"], do: {d, a + v}

  def ns(%{d: d, ns: {d_a, a}}, {"F", v}) when d in ["N", "S"],
    do: {(a - v < 0 && d) || d_a, abs(a - v)}

  def ns(%{ns: a}, _), do: a

  def ew(%{ew: {_, 0}}, {d, v}) when d in ["E", "W"], do: {d, v}
  def ew(%{ew: {d, a}}, {d, v}) when d in ["E", "W"], do: {d, a + v}
  def ew(%{ew: {d_a, a}}, {d, v}) when d in ["E", "W"], do: {(a - v < 0 && d) || d_a, abs(a - v)}
  def ew(%{d: d, ew: {d, a}}, {"F", v}) when d in ["E", "W"], do: {d, a + v}

  def ew(%{d: d, ew: {d_a, a}}, {"F", v}) when d in ["E", "W"],
    do: {(a - v < 0 && d) || d_a, abs(a - v)}

  def ew(%{ew: a}, _), do: a

  def nd(d, {turn, v}) do
    operator = if turn == "L", do: &-/2, else: &+/2
    d_index = Enum.find_index(@directions, &(&1 == d))
    mv = div(v, 90)
    new_index = operator.(d_index, mv)
    new_index = rem(new_index, 4)
    Enum.at(@directions, new_index)
  end

  def reduce_instructions2(stream) do
    %{s: {y, x}} = Enum.reduce(stream, %{wp: {1, -10}, s: {0, 0}}, &step2/2)

    abs(x) + abs(y)
  end

  def step2(inst = {d, _}, a) when d in @directions, do: %{a | wp: mvp(a.wp, inst)}
  def step2(inst = {r, _}, a) when r in ["L", "R"], do: %{a | wp: rvp(a.wp, inst)}
  def step2(inst = {"F", _}, a), do: mship(a, inst)

  def mvp({y, x}, {"N", v}), do: {y + v, x}
  def mvp({y, x}, {"S", v}), do: {y - v, x}
  def mvp({y, x}, {"W", v}), do: {y, x + v}
  def mvp({y, x}, {"E", v}), do: {y, x - v}

  def rvp({0, 0}, _), do: 0

  def rvp(wp, {r, v}) when r in ["L", "R"] do
    mv = div(v, 90)
    Enum.reduce(1..mv, wp, fn _, w -> rvp(w, r) end)
  end

  def rvp({y, x}, "L") when x >= 0 and y >= 0, do: {-x, y}
  def rvp({y, x}, "L") when x >= 0 and y < 0, do: {-x, y}
  def rvp({y, x}, "L") when x < 0 and y < 0, do: {abs(x), y}
  def rvp({y, x}, "L") when x < 0 and y >= 0, do: {abs(x), y}

  def rvp({y, x}, "R") when x >= 0 and y >= 0, do: {x, -y}
  def rvp({y, x}, "R") when x >= 0 and y < 0, do: {x, abs(y)}
  def rvp({y, x}, "R") when x < 0 and y < 0, do: {x, abs(y)}
  def rvp({y, x}, "R") when x < 0 and y >= 0, do: {x, -y}

  def mship(a = %{wp: {wy, wx}, s: {y, x}}, {"F", m}), do: %{a | s: {y + wy * m, x + wx * m}}
end
