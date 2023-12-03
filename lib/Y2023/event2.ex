defmodule Y2023.Event2 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2023/event2/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2023/event2/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2023/event2/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2023/event2/puzzle.txt")}")
  end

  def part1(path) do
    path
    |> input_stream()
    |> Stream.filter(&possible_game?/1)
    |> Stream.map(&elem(&1,0))
    |> Enum.sum()
  end

  def part2(path) do
    path
    |> input_stream()
    |> Stream.map(&cubes_used/1)
    |> Enum.sum()
  end

  defp possible_game?({_game_id, rounds}) do
    List.flatten(rounds)
    |> Enum.any?(fn
      {count, "red"} when count > 12 -> true
      {count, "green"} when count > 13 -> true
      {count, "blue"} when count > 14 -> true
      _ -> false
    end)
    |> Kernel.not()
  end

  defp cubes_used({_game_id, rounds}) do
    List.flatten(rounds)
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Map.values()
    |> Enum.map(&Enum.max/1)
    |> Enum.product()
  end

  defp input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  defp parse_input(input) do
    [game_id_str, game_data_str] = String.trim(input) |> String.split(":")
    game_id = String.split(game_id_str, " ") |> Enum.at(1) |> String.to_integer()

    game_data =
      String.trim(game_data_str)
      |> String.split(";")
      |> Enum.map(&parse_round/1)

    {game_id, game_data}
  end

  defp parse_round(input) do
    String.trim(input)
    |> String.split(",", trim: true)
    |> Enum.map(fn hand ->
      [count, color] = String.split(hand)
      {String.to_integer(count), color}
    end)
  end
end
