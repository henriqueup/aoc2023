defmodule Solution do
  @spelled_digits ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

  def parse_spelled_digit(spelled_digit) do
    digit = Enum.find_index(@spelled_digits, fn elem -> elem == spelled_digit end)

    if digit != nil do
      "#{Integer.to_string(digit + 1)}"
    else
      spelled_digit
    end
  end

  def parse_calibration_value(line) do
    regexString =
      Enum.map(@spelled_digits, fn spelled_digit -> "(#{spelled_digit})" end)
      |> Enum.join("|")

    regex =
      Regex.compile("\\d|(?=#{regexString})")
      |> elem(1)

    Regex.scan(regex, line)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.filter(fn x -> String.length(x) > 0 end)
    |> Enum.map(&Solution.parse_spelled_digit/1)
    |> then(fn digits -> "#{Enum.at(digits, 0)}#{Enum.at(digits, -1)}" end)
    |> String.to_integer()
  end
end

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&Solution.parse_calibration_value/1)
|> Enum.reduce(fn elem, acc -> acc + elem end)
|> IO.puts()
