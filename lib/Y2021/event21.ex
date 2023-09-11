defmodule Y2021.Event21 do
  use Memoize

  @limit 1000
  @limit2 21

  def run do
    IO.puts("Test part1: #{part1({4, 8})}")
    IO.puts("Puzzle part1: #{part1({8, 9})}")

    # IO.puts("Test part2: #{part2("input/Y2021/event20/test.txt")}")
    # IO.puts("Puzzle part2: #{part2("input/Y2021/event20/puzzle.txt")}")
  end

  def part1({p1, p2}) do
    Enum.reduce_while(dice(), {{p1, 0}, {p2, 0}}, fn [d1, d2], {{p1, p1s}, {p2, p2s}} ->
      np1 = to_pos(d1, p1)
      np1s = p1s + np1
      np2 = to_pos(d2, p2)
      np2s = p2s + np2

      cond do
        np1s >= @limit ->
          {:halt, p2s * List.last(d1)}

        np2s >= @limit ->
          {:halt, np1s * List.last(d2)}

        true ->
          {:cont, {{np1, np1s}, {np2, np2s}}}
      end
    end)
  end

  def part2({p1, p2}) do
    Enum.map(d_freqs(), &count_wins({{p1, 0}, {p2, 0}}, &1))
    |> sum()
    |> then(fn {p1, p2} -> max(p1, p2) end)
  end

  defmemo count_wins({{p1, p1s}, {p2, p2s}}, {d, d_f}, {acc1, acc2} \\ {1, 1}) do
    np1 = to_pos2(d, p1)
    np1s = p1s + np1

    cond do
      np1s >= @limit2 ->
        {acc1 * d_f, 0}

      true ->
        Enum.map(d_freqs(), fn {d2, d2_f} ->
          np2 = to_pos2(d2, p2)
          np2s = p2s + np2

          cond do
            np2s >= @limit2 ->
              {0, acc2 * d_f * d2_f}

            true ->
              Enum.map(
                d_freqs(),
                &count_wins(
                  {{np1, np1s}, {np2, np2s}},
                  &1,
                  {acc1 * d_f * d2_f, acc2 * d_f * d2_f}
                )
              )
              |> sum()
          end
        end)
        |> sum()
    end
  end

  def sum(list) do
    Enum.reduce(list, fn {p1, p2}, {acc1, acc2} -> {acc1 + p1, acc2 + p2} end)
  end

  def to_pos(d, p) do
    ds =
      d
      |> Enum.map(fn x ->
        case rem(x, 100) do
          0 -> 100
          x -> x
        end
      end)
      |> Enum.sum()

    case rem(p + ds, 10) do
      0 -> 10
      x -> x
    end
  end

  def to_pos2(d, p) do
    case rem(p + d, 10) do
      0 -> 10
      x -> x
    end
  end

  def dice() do
    Stream.resource(fn -> 1 end, &{[&1], &1 + 1}, & &1)
    |> Stream.chunk_every(3)
    |> Stream.chunk_every(2)
  end

  def d_freqs(), do: dirac_possibilities() |> Enum.map(&Enum.sum/1) |> Enum.frequencies()

  def dirac_possibilities do
    for(a <- 1..3, b <- 1..3, c <- 1..3, do: [a, b, c])
  end
end
