defmodule Y2021.Event12 do
  def run do
    IO.puts("Test1 part1: #{part1("input/Y2021/event12/test1.txt")}")
    IO.puts("Test2 part1: #{part1("input/Y2021/event12/test2.txt")}")
    IO.puts("Test3 part1: #{part1("input/Y2021/event12/test3.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event12/puzzle.txt")}")
    IO.puts("Test1 part2: #{part2("input/Y2021/event12/test1.txt")}")
    IO.puts("Test2 part2: #{part2("input/Y2021/event12/test2.txt")}")
    IO.puts("Test3 part2: #{part2("input/Y2021/event12/test3.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event12/puzzle.txt")}")
    # IO.puts("Test part2: #{part2("input/Y2021/event11/test.txt")}")
    # IO.puts("Puzzle part2: #{part2("input/Y2021/event11/puzzle.txt")}")
  end

  def part1(path) do
    map = get_input(path)
    find_paths(map, "start")
  end

  def part2(path) do
    map = get_input(path)
    find_paths2(map, "start")
  end

  def find_paths(map, start, acc \\ [])

  def find_paths(_map, "end", acc), do: ["end" | acc]

  def find_paths(map, "start", []) do
    Map.get(map, "start", [])
    |> Enum.flat_map(&find_paths(map, &1, ["start"]))
    |> List.flatten()
    |> Enum.chunk_while(
      [],
      fn
        "start", acc -> {:cont, ["start" | acc], []}
        x, acc -> {:cont, [x | acc]}
      end,
      fn acc -> {:cont, acc} end
    )
    |> Enum.count()
  end

  def find_paths(_map, "start", _), do: []

  def find_paths(map, start, acc) do
    if not Enum.all?(String.to_charlist(start), &(&1 in 65..90)) and start in acc do
      []
    else
      Map.get(map, start, [])
      |> case do
        [x] ->
          if Enum.all?(String.to_charlist(x), &(&1 in 65..90)),
            do: find_paths(map, x, [start | acc]),
            else: (x in [acc] && []) || find_paths(map, x, [start | acc])

        list ->
          Enum.map(list, &find_paths(map, &1, [start | acc]))
          |> Enum.reject(&(&1 == []))
      end
    end
  end

  def find_paths2(map, start, acc \\ [])

  def find_paths2(_map, "end", acc), do: ["end" | acc]

  def find_paths2(map, "start", []) do
    Map.get(map, "start", [])
    |> Enum.flat_map(&find_paths2(map, &1, ["start"]))
    |> List.flatten()
    |> Enum.chunk_while(
      [],
      fn
        "start", acc -> {:cont, ["start" | acc], []}
        x, acc -> {:cont, [x | acc]}
      end,
      fn acc -> {:cont, acc} end
    )
    |> Enum.count()
  end

  def find_paths2(_map, "start", _), do: []

  def find_paths2(map, start, acc) do
    if not capital?(start) and sc_limit?(acc, start) do
      []
    else
      Map.get(map, start, [])
      |> case do
        [x] ->
          if capital?(x),
            do: find_paths2(map, x, [start | acc]),
            else: (sc_limit?(acc, x) && []) || find_paths2(map, x, [start | acc])

        list ->
          Enum.map(list, &find_paths2(map, &1, [start | acc]))
          |> Enum.reject(&(&1 == []))
      end
    end
  end

  def get_input(path) do
    map =
      File.stream!(path)
      |> Stream.map(&(&1 |> String.trim() |> String.split("-") |> List.to_tuple()))
      |> Enum.reduce(%{}, fn {key, val}, acc ->
        Map.update(acc, key, [val], fn vals -> [val | vals] end)
      end)

    Enum.reduce(map, map, fn
      {"start", _conns}, acc ->
        acc

      {key, conns}, acc ->
        Enum.reduce(conns, acc, fn
          x, acc -> Map.update(acc, x, [key], fn vals -> Enum.uniq([key | vals]) end)
        end)
    end)
    |> Map.map(fn {_key, vals} -> Enum.uniq(vals) |> List.delete("start") end)
  end

  def capital?(s), do: Enum.all?(String.to_charlist(s), &(&1 in 65..90))

  def sc_limit?(acc, x) do
    freqs =
      acc
      |> Enum.reject(&capital?/1)
      |> Enum.frequencies()

    d_cave_l? = freqs |> Map.values() |> Enum.any?(&(&1 > 1))

    d_cave_l? and Map.has_key?(freqs, x)
  end

  def render_map(map) do
    for(
      j <- 0..9,
      i <- 0..9,
      do: {i, j}
    )
    |> Enum.map(&Map.get(map, &1))
    |> Enum.chunk_every(10)
    |> Enum.map(fn row -> Enum.join(row) |> IO.puts() end)

    IO.puts("\n")
  end
end
