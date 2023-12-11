defmodule Solution do
  def get_map_from_range(range) do
    Enum.map(range, fn range_part ->
      [dest, src, count] =
        String.split(range_part)
        |> Enum.map(fn n -> String.to_integer(n) end)

      srcs = {src, src + count - 1}
      dests = {dest, dest + count - 1}

      {srcs, dests}
    end)
  end

  def get_range_diff(ranges, range_to_remove) do
    # IO.inspect("-----------------------------------------------------------")

    filtered_ranges =
      Enum.filter(ranges, fn range ->
        range_start = elem(range, 0)
        range_end = elem(range, 1)

        range_start < elem(range_to_remove, 0) or range_end > elem(range_to_remove, 1)
      end)

    range_with_start_index =
      Enum.find_index(filtered_ranges, fn range ->
        elem(range, 0) >= elem(range_to_remove, 0) and elem(range, 0) <= elem(range_to_remove, 1)
      end)

    range_with_end_index =
      Enum.find_index(filtered_ranges, fn range ->
        elem(range, 1) <= elem(range_to_remove, 1) and elem(range, 1) >= elem(range_to_remove, 0)
      end)

    ranges_without_start =
      if not is_nil(range_with_start_index) do
        List.update_at(filtered_ranges, range_with_start_index, fn range ->
          {elem(range_to_remove, 1) + 1, elem(range, 1)}
        end)
      else
        filtered_ranges
      end

    ranges_without_end =
      if not is_nil(range_with_end_index) do
        List.update_at(ranges_without_start, range_with_end_index, fn range ->
          {elem(range, 0), elem(range_to_remove, 0) - 1}
        end)
      else
        ranges_without_start
      end

    # IO.inspect("get_range_diff")
    # IO.inspect(ranges)
    # IO.inspect(range_to_remove)
    # IO.inspect(ranges_without_end)
    # IO.inspect(ranges_without_end)
    # IO.inspect(ranges_without_end)
    ranges_without_end
  end

  def my_dumb_overengineered_way(original_seed_range, maps) do
    Enum.reduce(maps, [original_seed_range], fn map, seed_ranges ->
      Enum.reduce(seed_ranges, [], fn seed_range, acc_dests ->
        {mapping_dests, unmapped_seed_ranges} =
          Enum.reduce(map, {[], [seed_range]}, fn mapping, acc ->
            {acc_mapping_dests, acc_unmapped_seed_ranges} = acc
            mapping_src_range = elem(mapping, 0)
            mapping_src_start = elem(mapping_src_range, 0)
            mapping_src_end = elem(mapping_src_range, 1)
            mapping_dest_range = elem(mapping, 1)
            mapping_dest_start = elem(mapping_dest_range, 0)
            mapping_dest_end = elem(mapping_dest_range, 1)
            seed_start = elem(seed_range, 0)
            seed_end = elem(seed_range, 1)
            mapping_diff = mapping_dest_start - mapping_src_start

            cond do
              seed_start >= mapping_src_start and seed_end <= mapping_src_end ->
                {Enum.concat(acc_mapping_dests, [
                   {seed_start + mapping_diff, seed_end + mapping_diff}
                 ]), []}

              seed_start >= mapping_src_start and seed_start <= mapping_src_end ->
                seed_dest = {seed_start + mapping_diff, mapping_dest_end}
                seed_src = {seed_start, mapping_src_end}

                {Enum.concat(acc_mapping_dests, [
                   seed_dest
                 ]), Solution.get_range_diff(acc_unmapped_seed_ranges, seed_src)}

              seed_end <= mapping_src_end and seed_end >= mapping_src_start ->
                seed_dest = {mapping_dest_start, seed_end + mapping_diff}
                seed_src = {mapping_src_start, seed_end}

                {Enum.concat(acc_mapping_dests, [
                   seed_dest
                 ]), Solution.get_range_diff(acc_unmapped_seed_ranges, seed_src)}

              true ->
                {acc_mapping_dests, acc_unmapped_seed_ranges}
            end
          end)

        # IO.inspect("map")
        # IO.inspect(map)
        # IO.inspect("srcs")
        # IO.inspect(seed_range)
        # IO.inspect("dests")
        # IO.inspect(mapping_dests)
        # IO.inspect("unmapped_seed_ranges")
        # IO.inspect(unmapped_seed_ranges)

        Enum.concat(acc_dests, mapping_dests)
        |> Enum.concat(unmapped_seed_ranges)
      end)
    end)
  end

  def smart_way(original_seed_range, maps) do
    # credits to midouest at https://github.com/midouest/advent-of-code-2023/blob/main/notebooks/day05.livemd

    Enum.reduce(maps, [original_seed_range], fn map, seed_ranges ->
      Enum.reduce(map, {[], seed_ranges}, fn mapping, {curr_mapped, curr_unmapped} ->
        {new_mapped, new_unmapped} =
          Enum.reduce(curr_unmapped, {[], []}, fn seed, acc ->
            {acc_mapped, acc_unmapped} = acc
            mapping_src = elem(mapping, 0)
            mapping_src_start = elem(mapping_src, 0)
            mapping_src_end = elem(mapping_src, 1)
            mapping_dest = elem(mapping, 1)
            mapping_dest_start = elem(mapping_dest, 0)
            mapping_dest_end = elem(mapping_dest, 1)
            seed_start = elem(seed, 0)
            seed_end = elem(seed, 1)
            mapping_diff = mapping_dest_start - mapping_src_start

            cond do
              seed_start >= mapping_src_start and seed_end <= mapping_src_end ->
                mapped = {seed_start + mapping_diff, seed_end + mapping_diff}
                {acc_mapped ++ [mapped], acc_unmapped}

              seed_start >= mapping_src_start and seed_start <= mapping_src_end ->
                mapped = {seed_start + mapping_diff, mapping_dest_end}
                unmapped = {mapping_src_end + 1, seed_end}

                {acc_mapped ++ [mapped], acc_unmapped ++ [unmapped]}

              seed_end <= mapping_src_end and seed_end >= mapping_src_start ->
                mapped = {mapping_dest_start, seed_end + mapping_diff}
                unmapped = {seed_start, mapping_src_start - 1}

                {acc_mapped ++ [mapped], acc_unmapped ++ [unmapped]}

              true ->
                {acc_mapped, acc_unmapped ++ [seed]}
            end
          end)

        # IO.inspect(map)
        # IO.inspect(mapping)
        # IO.inspect(curr_mapped)
        # IO.inspect(curr_unmapped)
        # IO.inspect(new_mapped)
        # IO.inspect(new_unmapped)

        {curr_mapped ++ new_mapped, new_unmapped}
      end)
      |> Tuple.to_list()
      |> List.flatten()
    end)
  end
end

input_rows =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.chunk_while(
    [],
    fn n, acc ->
      if String.length(n) > 0 do
        {:cont, Enum.concat(acc, [n])}
      else
        {:cont, acc, []}
      end
    end,
    fn
      [] -> {:cont, []}
      acc -> {:cont, acc, []}
    end
  )

seed_ranges =
  input_rows
  |> Enum.at(0)
  |> Enum.at(0)
  |> String.split(":")
  |> Enum.drop(1)
  |> Enum.at(0)
  |> String.trim()
  |> String.split()
  |> Enum.chunk_every(2)
  |> Enum.map(fn range ->
    range_start = String.to_integer(Enum.at(range, 0))
    range_end = range_start + String.to_integer(Enum.at(range, 1)) - 1
    {range_start, range_end}
  end)

ranges =
  input_rows
  |> Enum.drop(1)
  |> Enum.map(fn map -> Enum.drop(map, 1) end)

maps =
  ranges
  |> Enum.map(fn range -> Solution.get_map_from_range(range) end)

seed_ranges
|> Enum.map(fn seed_range -> Solution.my_dumb_overengineered_way(seed_range, maps) end)
# |> Enum.map(fn seed_range -> Solution.smart_way(seed_range, maps) end)
|> Enum.flat_map(fn ranges -> Enum.map(ranges, fn range -> elem(range, 0) end) end)
|> Enum.min()
|> IO.inspect(charlists: :as_lists)
