defmodule Y2021.Event15 do
  @infinity 999_999_999

  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event15/test.txt")}")

    :timer.tc(fn ->
      IO.puts("Puzzle part1: #{part1("input/Y2021/event15/puzzle.txt")}")
      :ok
    end)
    |> IO.inspect()

    IO.puts("Test part1_: #{part1_("input/Y2021/event15/test.txt")}")

    :timer.tc(fn ->
      IO.puts("Puzzle part1_: #{part1_("input/Y2021/event15/puzzle.txt")}")
      :ok
    end)
    |> IO.inspect()

    IO.puts("Test part2_: #{part2_("input/Y2021/event15/test.txt")}")

    :timer.tc(fn -> IO.puts("Puzzle part2_: #{part2_("input/Y2021/event15/puzzle.txt")}") end)
    |> IO.inspect()

    IO.puts("Test part2: #{part2("input/Y2021/event15/test.txt")}")

    :timer.tc(fn -> IO.puts("Puzzle part2: #{part2("input/Y2021/event15/puzzle.txt")}") end)
    |> IO.inspect()

    # IO.puts("Test part2: #{part2("input/Y2021/event9/test.txt")}")
    # IO.puts("Test part2: #{part2("input/Y2021/event9/puzzle.txt")}")
  end

  def part1(path), do: get_input(path) |> solve_map()
  def part1_(path), do: get_input(path) |> solve_map2()
  def part2(path), do: get_input(path) |> expand_map |> solve_map()
  def part2_(path), do: get_input(path) |> expand_map |> solve_map2()

  def solve_map(map) do
    max_x = Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max()

    h = fn {x, y} -> max_y - y + (max_x - x) end

    d = fn key -> Map.get(map, key) end

    start = {0, 0}

    data = %{
      open_set: MapSet.new([{0, 0}]),
      g_score: %{start => 0},
      f_score: %{start => h.(start)},
      came_from: %{}
    }

    path_sum = find_path(start, {max_x, max_y}, h, d, data) |> Enum.map(d) |> Enum.sum()
    path_sum - d.(start)
  end

  def solve_map2(map) do
    max_x = Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max()

    h = fn {x, y} -> max_y - y + (max_x - x) end

    d = fn key -> Map.get(map, key) end

    start = {0, 0}

    data =
      Map.map(map, fn
        {{0, 0}, _} ->
          %{
            g_score: 0,
            f_score: h.({0, 0}),
            came_from: nil
          }

        {_, _} ->
          %{
            g_score: nil,
            f_score: nil,
            came_from: nil
          }
      end)

    path_sum =
      find_path2(start, {max_x, max_y}, h, d, data, MapSet.new([start]))
      |> Enum.map(d)
      |> Enum.sum()

    path_sum - d.(start)
  end

  def find_path(start, goal, h, d, data) do
    current = get_current(data.open_set, data.f_score)

    if current == goal do
      reconstruct_path(data.came_from, current)
    else
      data = Map.put(data, :open_set, MapSet.delete(data.open_set, current))

      data =
        Enum.reduce(surrounding_positions(current, goal), data, fn neighbor, data ->
          tentative_g_score = Map.get(data.g_score, current, @infinity) + d.(neighbor)

          if tentative_g_score < Map.get(data.g_score, neighbor, @infinity) do
            Map.merge(data, %{
              came_from: Map.put(data.came_from, neighbor, current),
              g_score: Map.put(data.g_score, neighbor, tentative_g_score),
              f_score: Map.put(data.f_score, neighbor, tentative_g_score + h.(neighbor)),
              open_set: MapSet.put(data.open_set, neighbor)
            })
          else
            data
          end
        end)

      if Enum.empty?(data.open_set) do
        throw("failure")
      else
        find_path(start, goal, h, d, data)
      end
    end
  end

  def find_path2(start, goal, h, d, data, open_set) do
    current = get_current2(open_set, data)

    if current == goal do
      reconstruct_path2(data, current)
    else
      open_set = MapSet.delete(open_set, current)

      {data, open_set} =
        Enum.reduce(surrounding_positions(current, goal), {data, open_set}, fn neighbor,
                                                                               {data, open_set} ->
          # IO.inspect(neighbor, label: "Working on")
          current_data = Map.get(data, current)
          neighbour_data = Map.get(data, neighbor)

          tentative_g_score = (current_data.g_score || @infinity) + d.(neighbor)

          if tentative_g_score < (neighbour_data.g_score || @infinity) do
            neighbour_data = %{
              came_from: current,
              g_score: tentative_g_score,
              f_score: tentative_g_score + h.(neighbor)
            }

            data = Map.put(data, neighbor, neighbour_data)

            open_set = MapSet.put(open_set, neighbor)
            {data, open_set}
          else
            {data, open_set}
          end
        end)

      if Enum.empty?(open_set) do
        throw("failure")
      else
        find_path2(start, goal, h, d, data, open_set)
      end
    end
  end

  def add_to_open_set([], _data, position), do: [position]

  def add_to_open_set(set, data, position) do
    [position | set] |> Enum.sort_by(fn p -> get_in(data, [p, :f_score]) end)
  end

  def get_current(open_set, f_score),
    do: Enum.min_by(open_set, fn position -> Map.get(f_score, position) end)

  def get_current2(open_set, data),
    do: Enum.min_by(open_set, fn p -> get_in(data, [p, :f_score]) end)

  def reconstruct_path(came_from, current, acc \\ []) do
    acc = [current | acc]

    case Map.get(came_from, current) do
      nil -> acc
      c -> reconstruct_path(came_from, c, acc)
    end
  end

  def reconstruct_path2(data, current, acc \\ []) do
    acc = [current | acc]

    case get_in(data, [current, :came_from]) do
      nil -> acc
      c -> reconstruct_path2(data, c, acc)
    end
  end

  def expand_map(map) do
    max_x = Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for(
      j <- 0..4,
      i <- 0..4,
      do: {i, j}
    )
    |> Enum.flat_map(fn
      {0, 0} ->
        Enum.into(map, [])

      {i, j} ->
        Enum.map(map, fn {{x, y}, val} ->
          {{x + i * (max_x + 1), y + j * (max_y + 1)}, increase_risk(val, i + j)}
        end)
    end)
    |> Enum.into(%{})
  end

  def increase_risk(r, add) when r + add < 10, do: r + add
  def increase_risk(r, add), do: r + add - 9

  def surrounding_positions({x, y}, {max_x, max_y}) do
    for(
      j <- (y - 1)..(y + 1),
      i <- (x - 1)..(x + 1),
      {i, j} !== {x, y} and (x == i or y == j) and i >= 0 and i <= max_x and j >= 0 and
        j <= max_y,
      do: {i, j}
    )
  end

  def get_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&(&1 |> String.graphemes() |> Enum.map(fn x -> String.to_integer(x) end)))
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row |> Enum.with_index() |> Enum.flat_map(fn {val, x} -> [{{x, y}, val}] end)
    end)
    |> Enum.into(%{})
  end

  def render_map(map) do
    max_x = Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max() |> IO.inspect()
    max_y = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max() |> IO.inspect()

    for(
      j <- 0..max_x,
      i <- 0..max_y,
      do: {i, j}
    )
    |> Enum.map(&Map.get(map, &1))
    |> Enum.chunk_every(max_x + 1)
    |> Enum.map(fn row -> Enum.join(row) |> IO.puts() end)

    IO.puts("\n")
  end
end
