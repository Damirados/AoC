defmodule Y2021.Event4 do
  def run do
    IO.puts("Test part1: #{part1("input/Y2021/event4/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/Y2021/event4/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/Y2021/event4/test.txt")}")
    IO.puts("Puzzle part2: #{part2("input/Y2021/event4/puzzle.txt")}")
  end

  def part1(path) do
    {numbers, boards} = get_input(path)

    boards = Enum.map(boards, &mark_board(&1, nil))

    Enum.reduce_while(numbers, boards, fn n, boards ->
      boards = Enum.map(boards, &mark_board(&1, n))

      check_boards(boards)
      |> case do
        {true, board} -> {:halt, calculate_score(board, n)}
        _ -> {:cont, boards}
      end
    end)
  end

  def part2(path) do
    {numbers, boards} = get_input(path)

    boards = Enum.map(boards, &mark_board(&1, nil))

    Enum.reduce_while(numbers, boards, fn n, boards ->
      boards = Enum.map(boards, &mark_board(&1, n))

      check_boards2(boards)
      |> case do
        {true, board} -> {:halt, calculate_score(board, n)}
        {false, boards} -> {:cont, boards}
      end
    end)
  end

  def get_input(path) do
    input_blocks =
      File.stream!(path)
      |> Stream.map(&String.trim/1)
      |> Stream.chunk_by(&(&1 == ""))
      |> Enum.reject(&(&1 == [""]))

    numbers =
      input_blocks
      |> List.first()
      |> List.first()
      |> parse_numbers()

    boards =
      input_blocks
      |> Enum.drop(1)
      |> Enum.map(&parse_board/1)

    {numbers, boards}
  end

  def parse_numbers(numbers),
    do: String.split(numbers, ",") |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)

  def parse_board(board), do: board |> Enum.map(&String.split/1) |> Enum.map(&parse_row/1)
  def parse_row(row), do: Enum.map(row, &String.to_integer/1)

  def mark_board(board, number) do
    Enum.map(board, fn row ->
      Enum.map(row, fn
        {num, true} -> {num, true}
        {num, false} -> {num, num == number}
        num -> {num, num == number}
      end)
    end)
  end

  def check_boards(boards), do: Enum.map(boards, &check_board/1) |> Enum.find(&elem(&1, 0))

  def check_board(board) do
    ((Enum.any?(board, fn row -> Enum.all?(row, &elem(&1, 1)) end) ||
        Enum.any?(get_columns(board), fn row -> Enum.all?(row, &elem(&1, 1)) end)) &&
       {true, board}) ||
      {false, board}
  end

  def check_boards2([board]) do
    case check_board(board) do
      {true, board} -> {true, board}
      {false, board} -> {false, [board]}
    end
  end

  def check_boards2(boards), do: {false, Enum.filter(boards, &(not elem(check_board(&1), 0)))}

  def calculate_score(board, n) do
    unmarked_sum =
      Enum.flat_map(board, fn row ->
        Enum.flat_map(row, fn
          {num, false} -> [num]
          _ -> []
        end)
      end)
      |> Enum.sum()

    unmarked_sum * n
  end

  def get_columns(board) do
    for x <- 0..4 do
      for y <- 0..4 do
        Enum.at(board, y) |> Enum.at(x)
      end
    end
  end
end
