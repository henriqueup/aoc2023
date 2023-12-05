# Advent of Code 2023

Let's fix that freaking snow production ASAP

[AOC Home](https://adventofcode.com)

## Elixir

Elixir was chosen as an opportunity to learn functional programming

### Initiating new challenge

There is a script called `init.exs` which can be executed to create a folder and templates for a new challenge, as follows:

```bash
elixir init.exs
#then just type the number of the day for the challenge
```

### Useful snipets

Reading a file per line

```elixir
File.stream!("file.txt")
|> Stream.map(&String.trim/1)
|> Stream.with_index
|> Stream.map(fn ({line, index}) -> IO.puts "#{index + 1} #{line}" end)
|> Stream.run
```
