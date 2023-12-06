defmodule Solution do
  def parse_cards(line) do
    String.split(line, ":")
    |> Enum.at(1)
    |> String.split("|")
    |> Enum.map(fn s -> String.split(s) end)
    |> then(fn card -> %{winners: Enum.at(card, 0), rolls: Enum.at(card, 1)} end)
  end

  def get_winners(card) do
    Enum.filter(card[:rolls], fn n -> Enum.member?(card[:winners], n) end)
  end

  def process_game_copies(games) do
    Enum.with_index(games)
    |> Enum.reduce(games, fn {_, curr_index}, acc ->
      curr_game = Enum.at(acc, curr_index)

      if curr_game[:winners] > 0 do
        Enum.with_index(acc)
        |> Enum.map(fn {next_game, next_index} ->
          if next_index > curr_index and next_index <= curr_index + curr_game[:winners] do
            %{count: next_game[:count] + curr_game[:count], winners: next_game[:winners]}
          else
            next_game
          end
        end)
      else
        acc
      end
    end)
  end
end

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&Solution.parse_cards/1)
|> Enum.map(&Solution.get_winners/1)
|> Enum.map(fn winners -> %{winners: length(winners), count: 1} end)
|> then(&Solution.process_game_copies/1)
|> Enum.reduce(0, fn curr, acc -> curr[:count] + acc end)
|> IO.inspect()
