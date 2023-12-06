defmodule Solution do
  def scan_by_regex(line, regex, index) do
    Regex.scan(regex, line, return: :index)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.map(fn x -> Tuple.append(x, index) end)
  end

  def parse_line(line, index) do
    %{
      numbers: Solution.scan_by_regex(line, ~r/\d+/, index),
      gears: Solution.scan_by_regex(line, ~r/\*/, index)
    }
  end

  def number_has_adjacent_gear(number, gears) do
    number_start = elem(number, 0)
    number_end = number_start + elem(number, 1)
    number_row = elem(number, 2)

    has_gear_left =
      Enum.any?(gears, fn gear ->
        elem(gear, 2) >= number_row - 1 and elem(gear, 2) <= number_row + 1 and
          elem(gear, 0) == number_start - 1
      end)

    has_gear_right =
      Enum.any?(gears, fn gear ->
        elem(gear, 2) >= number_row - 1 and elem(gear, 2) <= number_row + 1 and
          elem(gear, 0) == number_end
      end)

    has_gear_above =
      Enum.any?(gears, fn gear ->
        elem(gear, 2) == number_row - 1 and elem(gear, 0) >= number_start and
          elem(gear, 0) <= number_end
      end)

    has_gear_under =
      Enum.any?(gears, fn gear ->
        elem(gear, 2) == number_row + 1 and elem(gear, 0) >= number_start and
          elem(gear, 0) <= number_end
      end)

    has_gear_above or has_gear_left or has_gear_right or has_gear_under
  end

  def get_gear_numbers(gear, numbers) do
    gear_start = elem(gear, 0)
    gear_end = gear_start + elem(gear, 1)
    gear_row = elem(gear, 2)

    adjacent_numbers =
      Enum.filter(numbers, fn number ->
        (elem(number, 2) == gear_row and
           (elem(number, 0) == gear_end or elem(number, 0) + elem(number, 1) == gear_start)) or
          (elem(number, 2) == gear_row - 1 and
             (elem(number, 0) <= gear_end and elem(number, 0) + elem(number, 1) >= gear_start)) or
          (elem(number, 2) == gear_row + 1 and
             (elem(number, 0) <= gear_end and elem(number, 0) + elem(number, 1) >= gear_start))
      end)

    # IO.inspect(gear)
    # IO.inspect(adjacent_numbers)
    # IO.inspect("-------------------------------")

    if length(adjacent_numbers) == 2 do
      adjacent_numbers
    end
  end
end

lines =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)

numbers_adjacent_to_gears =
  lines
  |> Stream.with_index()
  |> Stream.map(fn {line, index} -> Solution.parse_line(line, index) end)
  |> Enum.reduce(%{numbers: [], gears: []}, fn curr, acc ->
    %{
      numbers: Enum.concat(acc[:numbers], curr[:numbers]),
      gears: Enum.concat(acc[:gears], curr[:gears])
    }
  end)
  |> then(fn data ->
    Enum.map(data[:gears], fn gear ->
      Solution.get_gear_numbers(gear, data[:numbers])
    end)
    |> Enum.filter(fn x -> not is_nil(x) end)
  end)

numbers_adjacent_to_gears
|> Enum.map(fn numbers ->
  Enum.map(numbers, fn number ->
    Enum.at(lines, elem(number, 2))
    |> String.slice(elem(number, 0), elem(number, 1))
    |> String.to_integer()
  end)
  |> Enum.reduce(1, fn curr, acc -> curr * acc end)
end)
|> Enum.reduce(fn curr, acc -> curr + acc end)
|> IO.inspect(base: :decimal)
