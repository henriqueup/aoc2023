day = IO.gets("Enter day number:\n")
dir = String.trim("day#{day}")
template_file = "template.exs"
solution_file = "#{dir}/solution.exs"
input_file = "#{dir}/input.txt"
sample_file = "#{dir}/sample.txt"

File.mkdir(dir)
File.touch(input_file, System.os_time(:second))
File.touch(sample_file, System.os_time(:second))

template_content =
  File.read(template_file)
  |> elem(1)

File.touch(solution_file, System.os_time(:second))
File.write(solution_file, template_content)
