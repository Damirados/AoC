defmodule Y2021.Event25 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event25/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event25/puzzle.txt")}")

    # IO.puts("Test part2: #{part2("input/Y2021/event22/test.txt")}")
    # IO.puts("Puzzle part2: #{part2("input/Y2021/event22/puzzle.txt")}")
  end

  def part1(path) do
    map = get_input(path)

    {max_x, max_y, order} = map_order(map)

    find_halt(map, order, max_x, max_y)
  end

  def part2(path) do
  end

  def find_halt(map, order, max_x, max_y, acc \\ 0) do
    new_map = do_step(map, order, max_x, max_y)

    if Map.equal?(map, new_map),
      do: acc + 1,
      else: find_halt(new_map, order, max_x, max_y, acc + 1)
  end

  def do_step(map, order, max_x, max_y) do
    map =
      Enum.reduce(order, map, fn {x, y} = position, acc ->
        case Map.get(map, position) do
          ">" ->
            next_x = next_position(x, max_x)
            next_position = {next_x, y}

            case Map.get(map, next_position) do
              "." ->
                Map.put(acc, position, ".") |> Map.put(next_position, ">")

              _ ->
                acc
            end

          _ ->
            acc
        end
      end)

    Enum.reduce(order, map, fn {x, y} = position, acc ->
      case Map.get(map, position) do
        "v" ->
          next_y = next_position(y, max_y)
          next_position = {x, next_y}

          case Map.get(map, next_position) do
            "." ->
              Map.put(acc, position, ".") |> Map.put(next_position, "v")

            _ ->
              acc
          end

        _ ->
          acc
      end
    end)
  end

  def next_position(x, x), do: 0
  def next_position(x, _), do: x + 1

  def map_order(map) do
    keys = Map.keys(map)
    xs = Enum.map(keys, &elem(&1, 0))
    ys = Enum.map(keys, &elem(&1, 1))

    max_x = Enum.max(xs)
    max_y = Enum.max(ys)

    {max_x, max_y, for(j <- 0..max_y, i <- 0..max_x, do: {i, j})}
  end

  def get_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.with_index()
    |> Stream.flat_map(fn {row, y} ->
      row |> Enum.with_index() |> Enum.flat_map(fn {val, x} -> [{{x, y}, val}] end)
    end)
    |> Enum.into(%{})
  end
end
