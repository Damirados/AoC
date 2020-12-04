defmodule Event4 do
  import Ecto.Changeset
  @required_fields ~w(ecl pid eyr hcl byr iyr hgt)
  @required_fields_a ~w(ecl pid eyr hcl byr iyr hgt)a

  def run do
    IO.puts("Test part1: #{part1("input/event4/test.txt")}")
    IO.puts("Puzzle part1: #{part1("input/event4/puzzle.txt")}")
    IO.puts("Test part2: #{part2("input/event4/test.txt")}")
    IO.puts("Test part2 valid: #{part2("input/event4/valid.txt")}")
    IO.puts("Puzzle part2: #{part2("input/event4/puzzle.txt")}")
  end

  def part1(path) do
    input_stream(path)
    |> Stream.concat([nil])
    |> Stream.transform(%{}, &collect_passport/2)
    |> Stream.filter(&validate_password_required/1)
    |> Enum.count()
  end

  def part2(path) do
    input_stream(path)
    |> Stream.concat([nil])
    |> Stream.transform(%{}, &collect_passport/2)
    |> Stream.filter(&validate_passport/1)
    |> Enum.count()
  end

  def collect_passport(nil, acc) when map_size(acc) == 0, do: {[nil], %{}}
  def collect_passport(nil, acc), do: {[acc], %{}}

  def collect_passport(passport_part, acc) do
    new_acc = Map.merge(acc, passport_part)
    {[nil], new_acc}
  end

  def validate_password_required(nil), do: false

  def validate_password_required(passport),
    do: Enum.all?(@required_fields, &(&1 in Map.keys(passport)))

  def validate_passport(nil), do: false

  def validate_passport(passport) do
    types = %{
      byr: :integer,
      iyr: :integer,
      eyr: :integer,
      hgt: :string,
      hcl: :string,
      ecl: :string,
      pid: :string,
      cid: :integer
    }

    changeset =
      {%{}, types}
      |> cast(passport, Map.keys(types))
      |> validate_required(@required_fields_a)
      |> validate_number(:byr, greater_than_or_equal_to: 1920, less_than_or_equal_to: 2020)
      |> validate_number(:iyr, greater_than_or_equal_to: 2010, less_than_or_equal_to: 2020)
      |> validate_number(:eyr, greater_than_or_equal_to: 2020, less_than_or_equal_to: 2030)
      |> validate_change(:hgt, fn :hgt, hgt ->
        case Integer.parse(hgt) do
          {h, "in"} -> if h >= 59 and h <= 76, do: [], else: [hgt: "invalid"]
          {h, "cm"} -> if h >= 150 and h <= 193, do: [], else: [hgt: "invalid"]
          _ -> [hgt: "invalid"]
        end
      end)
      |> validate_format(:hcl, ~r/^#[0-9a-f]{6}$/)
      |> validate_inclusion(:ecl, ~w(amb blu brn gry grn hzl oth))
      |> validate_format(:pid, ~r/^[0-9]{9}$/)

    changeset.valid?
  end

  def input_stream(path), do: path |> File.stream!() |> Stream.map(&parse_input/1)

  def parse_input(input) do
    String.trim(input)
    |> String.split(" ", trim: true)
    |> case do
      [] ->
        nil

      pairs ->
        Enum.map(pairs, &(String.split(&1, ":", trim: true) |> List.to_tuple())) |> Enum.into(%{})
    end
  end
end
