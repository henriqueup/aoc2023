# Advent of Code 2023

Let's fix that freaking snow production ASAP

[AOC Home](https://adventofcode.com)

## Elixir

Elixir was chosen as an opportunity to learn functional programming

### Useful snipets

```elixir
File.stream!("file.txt")
|> Stream.map(&String.trim/1)
|> Stream.with_index
|> Stream.map(fn ({line, index}) -> IO.puts "#{index + 1} #{line}" end)
|> Stream.run
```
