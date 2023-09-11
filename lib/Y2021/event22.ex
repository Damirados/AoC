defmodule Y2021.Event22 do
  require Integer

  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event22/test.txt")}")
    # IO.puts("Test2 part1: #{part1("input/Y2021/event22/test2.txt")}")
    # IO.puts("Puzzle part1: #{part1("input/Y2021/event22/puzzle.txt")}")

    IO.puts("Test part2: #{part2("input/Y2021/event22/test.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event22/test2i.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event22/puzzle.txt")}")
  end

  def part1(path) do
    get_input(path)
    |> Enum.reduce(MapSet.new([]), fn
      {"on", bounds}, acc -> MapSet.union(acc, bounds_to_cordinates(bounds))
      {"off", bounds}, acc -> MapSet.difference(acc, bounds_to_cordinates(bounds))
    end)
    |> MapSet.size()
  end

  def part2(path) do
    get_input(path)
    |> Enum.reduce(MapSet.new([]), fn
      {"on", bounds}, acc ->
        case find_intersecting_elements(acc, bounds) do
          [] ->
            MapSet.put(acc, bounds)

          i_elements ->
            Enum.reduce(i_elements, acc, fn {el1, _el2, _intersect} = i, acc ->
              {el1d, el2} = deinterscet(i)
              elements = MapSet.new([el2 | el1d])

              acc |> MapSet.delete(el1) |> MapSet.union(elements)
            end)
        end

      {"off", bounds}, acc ->
        case find_intersecting_elements(acc, bounds) do
          [] ->
            acc

          i_elements ->
            Enum.reduce(i_elements, acc, fn {el1, _el2, _intersect} = i, acc ->
              {el1d, _el2} = deinterscet(i)
              elements = MapSet.new(el1d)

              acc |> MapSet.delete(el1) |> MapSet.union(elements)
            end)
        end
    end)
    |> Enum.reduce(0, fn {x, y, z}, acc ->
      ([x, y, z]
       |> Enum.map(&pair_value/1)
       |> Enum.reduce(&(&1 * &2))) + acc
    end)
  end

  def pair_value({a, b}), do: b - (a - 1)

  def find_intersecting_elements(set, {x, y, z} = el2) do
    Enum.flat_map(set, fn {i, j, k} = el1 ->
      intersect =
        Enum.map([{x, i}, {y, j}, {k, z}], fn {a, b} -> coordinate_intersection(a, b) end)

      if Enum.any?(intersect, &(&1 == :no_intersection)) do
        []
      else
        [{el1, el2, intersect |> List.to_tuple()}]
      end
    end)
  end

  def find_intersecting_element(set, {x, y, z} = el2) do
    Enum.find_value(set, fn {i, j, k} = el1 ->
      intersect =
        Enum.map([{x, i}, {y, j}, {k, z}], fn {a, b} -> coordinate_intersection(a, b) end)

      if Enum.any?(intersect, &(&1 == :no_intersection)) do
        false
      else
        {el1, el2, intersect |> List.to_tuple()}
      end
    end)
  end

  def coordinate_intersection({a1, a2}, {b1, b2}) do
    cond do
      b1 >= a1 and b1 <= a2 and b2 >= a2 ->
        {b1, a2}

      b1 >= a1 and b2 <= a2 ->
        {b1, b2}

      b1 < a1 and b2 >= a1 and b2 <= a2 ->
        {a1, b2}

      b1 <= a1 and b2 >= a2 ->
        {a1, a2}

      true ->
        :no_intersection
    end
  end

  def deinterscet({el1, el2, i}) do
    el1 = deinterscet(el1, i)
    {el1, el2}
  end

  def deinterscet(el, i) do
    {z1, z2} = elem(el, 2)
    {zi1, zi2} = elem(i, 2)

    p1 = if z1 < zi1, do: [{elem(el, 0), elem(el, 1), {z1, zi1 - 1}}], else: []
    p2 = if z2 > zi2, do: [{elem(el, 0), elem(el, 1), {zi2 + 1, z2}}], else: []

    {y1, y2} = elem(el, 1)
    {yi1, yi2} = elem(i, 1)

    p3 = if y1 < yi1, do: [{elem(el, 0), {y1, yi1 - 1}, {zi1, zi2}}], else: []
    p4 = if y2 > yi2, do: [{elem(el, 0), {yi2 + 1, y2}, {zi1, zi2}}], else: []

    {x1, x2} = elem(el, 0)
    {xi1, xi2} = elem(i, 0)

    p5 = if x1 < xi1, do: [{{x1, xi1 - 1}, {yi1, yi2}, {zi1, zi2}}], else: []
    p6 = if x2 > xi2, do: [{{xi2 + 1, x2}, {yi1, yi2}, {zi1, zi2}}], else: []

    Enum.flat_map([p1, p2, p3, p4, p5, p6], & &1)
  end

  def get_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  def bounds_to_cordinates({{x1, x2}, {y1, y2}, {z1, z2}})
      when x1 < -50 or y1 < -50 or z1 < -50 or x2 > 50 or y2 > 50 or z2 > 50,
      do: MapSet.new([])

  def bounds_to_cordinates({{x1, x2}, {y1, y2}, {z1, z2}}),
    do: for(k <- z1..z2, j <- y1..y2, i <- x1..x2, do: {i, j, k}) |> MapSet.new()

  def parse_line(line) do
    [action, bounds] = String.split(line, " ", trim: true)

    bounds =
      String.split(bounds, ",")
      |> Enum.map(
        &(&1
          |> String.split("=")
          |> Enum.at(1)
          |> String.split("..")
          |> Enum.map(fn x -> String.to_integer(x) end)
          |> List.to_tuple())
      )
      |> List.to_tuple()

    {action, bounds}
  end
end
