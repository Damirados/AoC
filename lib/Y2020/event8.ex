defmodule Y2020.Event8 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2020/event8/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2020/event8/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2020/event8/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2020/event8/puzzle.txt")}")
  end

  def part1(path) do
    input_stream(path)
    |> Enum.into([])
    |> run_code()
    |> elem(1)
  end

  def part2(path) do
    input_stream(path)
    |> Enum.into([])
    |> run_code2()
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    {operation, val} =
      input
      |> String.trim()
      |> String.split_at(3)

    {String.to_atom(operation), val |> String.trim() |> String.to_integer()}
  end

  def run_code(code, {acc, index, seen_indexes} \\ {0, 0, []}) do
    cond do
      index in seen_indexes ->
        {:seen, acc}

      index == length(code) ->
        {:end, acc}

      true ->
        {acc, new_index} = run_operation(acc, index, Enum.at(code, index))
        run_code(code, {acc, new_index, [index | seen_indexes]})
    end
  end

  def run_code2(code, {acc, index, seen_indexes} \\ {0, 0, []}) do
    cond do
      index in seen_indexes ->
        repeated_op_index = Enum.find_index(seen_indexes, &(&1 == index))
        # History since repeat happened
        Stream.take(seen_indexes, repeated_op_index)
        # Possible broken operation codepoints
        |> Stream.flat_map(fn i ->
          (elem(Enum.at(code, i), 0) in [:nop, :jmp] && [i]) || []
        end)
        # Possible new codes
        |> Stream.map(fn broken_op_index ->
          List.update_at(code, broken_op_index, fn {key, val} -> {fix_operation(key), val} end)
        end)
        |> Enum.find_value(fn code ->
          {exit_code, acc} = run_code(code)
          if exit_code == :end, do: acc
        end)

      true ->
        {acc, new_index} = run_operation(acc, index, Enum.at(code, index))
        run_code2(code, {acc, new_index, [index | seen_indexes]})
    end
  end

  def run_operation(acc, index, {:nop, _val}), do: {acc, index + 1}
  def run_operation(acc, index, {:acc, val}), do: {acc + val, index + 1}
  def run_operation(acc, index, {:jmp, val}), do: {acc, index + val}

  def fix_operation(:nop), do: :jmp
  def fix_operation(:jmp), do: :nop
end
