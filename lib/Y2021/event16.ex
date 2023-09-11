defmodule Y2021.Event16 do
  @test1 "D2FE28"
  @test2 "38006F45291200"
  @test3 "8A004A801A8002F478"
  @test4 "C0015000016115A2E0802F182340"
  @test5 "A0016C880162017C3686B18A3D4780"

  @test6 "C200B40A82"
  @test7 "04005AC33890"
  @test8 "CE00C43D881120"
  @test9 "D8005AC2A8F0"
  @test10 "F600BC2D8F"
  @test11 "9C005AC2F8F0"
  @test12 "9C0141080250320F1802104A08"
  def run do
    # solve1(@test1) |> IO.inspect()
    # solve1(@test2) |> IO.inspect()
    # solve1(@test3) |> IO.inspect()
    # solve1(@test4) |> IO.inspect()
    # solve1(@test5) |> IO.inspect()
    ## IO.puts("Test part1: #{part1("input/Y2021/event11/test.txt", 100)}")
    # IO.puts("Puzzle part1: #{part1("input/Y2021/event16/puzzle.txt")}")

    solve2(@test6) |> IO.inspect()
    solve2(@test7) |> IO.inspect()
    solve2(@test8) |> IO.inspect()
    solve2(@test9) |> IO.inspect()
    solve2(@test10) |> IO.inspect()
    solve2(@test11) |> IO.inspect()
    solve2(@test12) |> IO.inspect()

    IO.puts("Puzzle part2: #{part2("input/Y2021/event16/puzzle.txt")}")
    # IO.puts("Test part2: #{part2("input/Y2021/event11/test.txt")}")
    # IO.puts("Puzzle part2: #{part2("input/Y2021/event11/puzzle.txt")}")
  end

  def part1(path) do
    get_input(path) |> solve1()
  end

  def part2(path) do
    get_input(path) |> solve2()
  end

  def solve1(hexstring) do
    bin = to_bin(hexstring)
    {packet, _leftover} = parse_packet(bin) |> IO.inspect()
    get_versions(packet) |> Enum.sum()
  end

  def solve2(hexstring) do
    bin = to_bin(hexstring)
    {packet, _leftover} = parse_packet(bin) |> IO.inspect()
    do_calculation(packet)
  end

  def parse_packet(bin) do
    {version, tail} = Enum.split(bin, 3)
    version = to_int(version)
    {type, tail} = Enum.split(tail, 3)
    type = to_int(type)

    case type do
      4 ->
        {value, leftover} = parse_value(tail)
        {{version, type, value}, leftover}

      _ ->
        {value, leftover} = parse_subpackets(tail)
        {{version, type, value}, leftover}
    end
  end

  def parse_value(bitlist) do
    {digits, [leftover]} =
      bitlist
      |> Enum.chunk_every(5)
      |> Enum.chunk_while(
        {1, []},
        fn
          [1 | digits], {1, _} -> {:cont, digits, {1, []}}
          [0 | digits], {1, _} -> {:cont, digits, {0, []}}
          trail, {0, acc} -> {:cont, {0, acc ++ trail}}
        end,
        fn {_, acc} -> {:cont, acc, []} end
      )
      |> Enum.split(-1)

    {List.flatten(digits) |> to_int(), leftover}
  end

  def parse_subpackets([_l_type = 0 | bitlist]) do
    {sub_length, tail} = Enum.split(bitlist, 15)
    {packets, leftover} = Enum.split(tail, to_int(sub_length))

    packets = parse_packetlist(packets)

    {packets, leftover}
  end

  def parse_subpackets([_l_type = 1 | bitlist]) do
    {n_packets, tail} = Enum.split(bitlist, 11)
    parse_n_packets(tail, to_int(n_packets))
  end

  def parse_packetlist(data, acc \\ []) do
    {packet, leftover} = parse_packet(data)

    if Enum.count(leftover) < 11,
      do: Enum.reverse([packet | acc]),
      else: parse_packetlist(leftover, [packet | acc])
  end

  def parse_n_packets(data, n, acc \\ [])

  def parse_n_packets(data, n, acc) when length(acc) == n, do: {Enum.reverse(acc), data}

  def parse_n_packets(data, n, acc) do
    {packet, leftover} = parse_packet(data)
    parse_n_packets(leftover, n, [packet | acc])
  end

  def get_versions({v, 4, _}), do: [v]

  def get_versions({v, _, subpacks}),
    do: [v | Enum.map(subpacks, &get_versions/1) |> List.flatten()]

  def do_calculation({_, 0, subpacks}), do: Enum.map(subpacks, &do_calculation/1) |> Enum.sum()
  def do_calculation({_, 1, subpacks}), do: Enum.reduce(subpacks, 1, &(do_calculation(&1) * &2))
  def do_calculation({_, 2, subpacks}), do: Enum.map(subpacks, &do_calculation/1) |> Enum.min()
  def do_calculation({_, 3, subpacks}), do: Enum.map(subpacks, &do_calculation/1) |> Enum.max()
  def do_calculation({_, 4, val}), do: val
  def do_calculation({_, 5, [a, b]}), do: (do_calculation(a) > do_calculation(b) && 1) || 0
  def do_calculation({_, 6, [a, b]}), do: (do_calculation(a) < do_calculation(b) && 1) || 0
  def do_calculation({_, 7, [a, b]}), do: (do_calculation(a) == do_calculation(b) && 1) || 0

  def get_input(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Enum.at(0)
  end

  def to_bin(hexstring) do
    hexstring
    |> String.graphemes()
    |> Enum.map(&(&1 |> String.to_integer(16) |> Integer.digits(2) |> pad_l_4()))
    |> List.flatten()
  end

  def pad_l_4(list) do
    missing = 4 - length(list)
    pads = Stream.repeatedly(fn -> 0 end) |> Enum.take(missing)
    pads ++ list
  end

  def to_int(bitlist), do: Integer.undigits(bitlist, 2)
end
