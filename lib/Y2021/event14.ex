defmodule Y2021.Event14 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event14/test.txt", 10)}")
    # IO.puts("Puzzle part1: #{part1("input/Y2021/event14/puzzle.txt", 10)}")
    IO.puts("Test part2: #{part2("input/Y2021/event14/test.txt", 10)}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event14/puzzle.txt", 40)}")
    # IO.puts("Puzzle part1: #{part1("input/Y2021/event13/puzzle.txt")}")
    # IO.puts("Test part2: #{part2("input/Y2021/event13/test.txt")}")
    # IO.puts("Puzzle part2: #{part2("input/Y2021/event13/puzzle.txt")}")
  end

  def part1(path, steps) do
    {chain, rules} = get_input(path)

    new_chain = Enum.reduce(1..steps, chain, fn _, acc -> pair_insertion(acc, rules) end)

    freqs = Enum.frequencies(new_chain)

    freq_vals = Map.values(freqs)

    max = Enum.max(freq_vals)
    min = Enum.min(freq_vals)

    max - min
  end

  def part2(path, steps) do
    {chain, rules} = get_input(path)
    chain_pairs = Enum.chunk_every(chain, 2, 1, :discard)

    pair_map =
      Enum.map(chain_pairs, &{&1, 1})
      |> Enum.into(%{})
      |> IO.inspect()

    new_pair_map = Enum.reduce(1..steps, pair_map, fn _, acc -> pair_insertion2(acc, rules) end)

    letters = Map.keys(new_pair_map) |> List.flatten() |> Enum.uniq()

    freqs =
      Enum.reduce(letters, %{}, fn l, acc ->
        l_count =
          new_pair_map
          |> Enum.flat_map(fn
            {[_, sl], value} when sl == l -> [value]
            _ -> []
          end)
          |> Enum.sum()

        Map.put(acc, l, l_count)
      end)

    freq_vals = Map.values(freqs)

    max = Enum.max(freq_vals)
    min = Enum.min(freq_vals)

    max - min
  end

  def pair_insertion(chain, rules) do
    Enum.chunk_every(chain, 2, 1, :discard)
    |> Enum.map(fn [a, b] = pair ->
      case Map.get(rules, pair) do
        nil -> pair
        add -> [a, add, b]
      end
    end)
    |> Enum.reduce(
      [],
      fn
        e, [] ->
          Enum.reverse(e)

        e, [_h | tail] ->
          e = Enum.reverse(e)
          e ++ tail
      end
    )
    |> Enum.reverse()
  end

  def pair_insertion2(pair_map, rules) do
    Enum.reduce(pair_map, %{}, fn {[a, b] = key, value}, acc ->
      case Map.get(rules, key) do
        nil ->
          acc

        add ->
          map_addition = %{
            [a, add] => value,
            [add, b] => value
          }

          Map.merge(acc, map_addition, fn _k, v1, v2 -> v1 + v2 end)
      end
    end)
  end

  def get_input(path) do
    {chain, rules} =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Enum.into([])
      |> Enum.split_while(&(&1 !== ""))

    chain = List.first(chain) |> String.graphemes()

    rules =
      Enum.reject(rules, &(&1 == ""))
      |> Enum.map(fn line ->
        [match, add] = line |> String.split(" -> ")
        {String.graphemes(match), add}
      end)
      |> Enum.into(%{})

    {chain, rules}
  end

  def render_map(map) do
    xs = Enum.map(map, &elem(&1, 0))
    x = Enum.max(xs)
    ys = Enum.map(map, &elem(&1, 1))
    y = Enum.max(ys)

    for(
      j <- 0..y,
      i <- 0..x,
      do: {i, j}
    )
    |> Enum.map(&((&1 in map && "#") || " "))
    |> Enum.chunk_every(x + 1)
    |> Enum.map(fn row -> Enum.join(row) |> IO.puts() end)

    IO.puts("\n")
  end
end
