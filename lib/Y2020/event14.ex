defmodule Y2020.Event14 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2020/event14/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2020/event14/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2020/event14/test2.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event14/puzzle.txt")}")
  end

  def part1(path) do
    get_value_stream(path)
    |> Stream.map(&unmask/1)
    |> Enum.into(%{})
    |> Map.values()
    |> Enum.sum()
  end

  def part2(path) do
    get_value_stream(path)
    |> Stream.map(&unmask2/1)
    |> Stream.concat()
    |> Enum.into(%{})
    |> Map.values()
    |> Enum.sum()
  end

  # def part2(path, start_point), do: find_cascading_ts(get_input(path) |> elem(1), start_point)

  def get_mask(path) do
    File.stream!(path)
    |> Enum.take(1)
    |> List.first()
    |> String.trim()
    |> String.split("=", trim: true)
    |> Enum.at(1)
    |> String.trim()
  end

  def get_value_stream(path) do
    File.stream!(path)
    |> Stream.map(&parse_value/1)
    |> Stream.chunk_while(
      nil,
      fn
        {"mask", mask}, _ -> {:cont, mask}
        val, mask -> {:cont, {mask, val}, mask}
      end,
      &{:cont, &1}
    )
  end

  def parse_value(line) do
    String.trim(line)
    |> String.split("=", trim: true)
    |> Enum.map(&String.trim/1)
    |> case do
      ["mask", mask] ->
        {"mask", mask}

      [mem, val] ->
        [_, mem] = String.split(mem, ~r([\[\]]), trim: true)
        {String.to_integer(mem), String.to_integer(val)}
    end
  end

  def unmask({mask, {mem, val}}) do
    val = Integer.to_string(val, 2) |> String.pad_leading(36, "0")

    unmasked =
      Enum.zip(String.graphemes(mask), String.graphemes(val))
      |> Enum.map(&mask_bit/1)
      |> Enum.into("")
      |> String.to_integer(2)

    {mem, unmasked}
  end

  def mask_bit({"X", bit}), do: bit
  def mask_bit({bit, _}), do: bit

  def unmask2({mask, {mem, val}}) do
    mem_s = Integer.to_string(mem, 2) |> String.pad_leading(36, "0")

    unmasked =
      Enum.zip(String.graphemes(mask), String.graphemes(mem_s))
      |> Enum.map(&mask_bit2/1)
      |> Enum.into("")
      |> String.replace_leading("0", "")

    String.graphemes(unmasked)
    |> expand()
    |> Stream.map(&Enum.join/1)
    |> Enum.map(&{String.to_integer(&1, 2), val})
  end

  def mask_bit2({"X", _}), do: "X"
  def mask_bit2({"1", _}), do: "1"
  def mask_bit2({"0", bit}), do: bit

  def expand([]), do: []

  def expand(list) when is_list(list) do
    case Enum.find_index(list, &(&1 == "X")) do
      nil ->
        [list]

      index ->
        start = Enum.take(list, index)

        case expand(Enum.drop(list, index + 1)) do
          [] ->
            [Enum.concat(start, ["0"]), Enum.concat(start, ["1"])]

          rest ->
            Enum.concat([
              Enum.map(rest, &Enum.concat([start, ["0"], expand(&1)])),
              Enum.map(rest, &Enum.concat([start, ["1"], expand(&1)]))
            ])
        end
    end
  end
end
