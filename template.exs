defmodule Solution do
  def foo(line) do
    IO.puts(line)
  end
end

File.stream!("input.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&Solution.foo/1)
|> Enum.to_list()
|> IO.inspect()
