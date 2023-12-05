defmodule Solution do
  @red_total 12
  @green_total 13
  @blue_total 14

  def parse_game_id(game_string) do
    String.replace(game_string, ~r/[^\d]/, "")
    |> String.to_integer()
  end

  def parse_draw(draw_string) do
    String.split(draw_string, ",")
    |> Enum.map(&String.split/1)
    |> Map.new(fn [count, color] -> {color, String.to_integer(count)} end)
  end

  def parse_draws(draws_string) do
    String.split(draws_string, ";")
    |> Enum.map(&Solution.parse_draw/1)
  end

  def parse_game(line) do
    String.split(line, ":")
    |> then(fn line_parts ->
      %{
        id: Solution.parse_game_id(Enum.at(line_parts, 0)),
        draws: Solution.parse_draws(Enum.at(line_parts, 1))
      }
    end)
  end

  def is_possible_game(game) do
    Enum.all?(game[:draws], fn draw ->
      (draw["red"] == nil or draw["red"] <= @red_total) and
        (draw["green"] == nil or draw["green"] <= @green_total) and
        (draw["blue"] == nil or draw["blue"] <= @blue_total)
    end)
  end

  def get_game_power(game) do
    Enum.reduce(game[:draws], %{red: 0, green: 0, blue: 0}, fn draw, acc ->
      %{
        red: if(draw["red"] != nil and draw["red"] > acc[:red], do: draw["red"], else: acc[:red]),
        green:
          if(draw["green"] != nil and draw["green"] > acc[:green],
            do: draw["green"],
            else: acc[:green]
          ),
        blue:
          if(draw["blue"] != nil and draw["blue"] > acc[:blue],
            do: draw["blue"],
            else: acc[:blue]
          )
      }
    end)
    |> Map.values()
    |> Enum.reduce(1, fn v, acc -> v * acc end)
  end
end

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&Solution.parse_game/1)
|> Enum.map(&Solution.get_game_power/1)
|> Enum.reduce(0, fn v, acc -> v + acc end)
|> IO.inspect()
