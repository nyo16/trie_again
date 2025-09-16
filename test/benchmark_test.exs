defmodule TrieHard.BenchmarkTest do
  use ExUnit.Case

  @moduletag :benchmark

  describe "performance benchmarks" do
    @tag timeout: :infinity
    test "benchmark insert operations" do
      trie = TrieHard.new()

      # Benchmark inserting 10,000 words
      word_count = 10_000
      words = for i <- 1..word_count, do: "word_#{:rand.uniform(1_000_000)}_#{i}"

      {insert_time, _} =
        :timer.tc(fn ->
          Enum.each(words, fn word ->
            TrieHard.insert(trie, word, "value_#{word}")
          end)
        end)

      # Benchmark batch insert
      {batch_time, _} =
        :timer.tc(fn ->
          trie2 = TrieHard.new()
          TrieHard.add_word_list(trie2, words)
        end)

      # Benchmark autocomplete
      {autocomplete_time, results} =
        :timer.tc(fn ->
          TrieHard.auto_complete(trie, "word_", 100)
        end)

      # Benchmark lookup
      test_word = Enum.random(words)

      {lookup_time, _} =
        :timer.tc(fn ->
          TrieHard.get(trie, test_word)
        end)

      IO.puts("\n=== TrieHard Performance Benchmarks ===")
      IO.puts("Words inserted: #{word_count}")

      IO.puts(
        "Individual insert time: #{insert_time / 1000} ms (#{insert_time / word_count} μs per word)"
      )

      IO.puts(
        "Batch insert time: #{batch_time / 1000} ms (#{batch_time / word_count} μs per word)"
      )

      IO.puts("Autocomplete time (#{length(elem(results, 1))} results): #{autocomplete_time} μs")
      IO.puts("Lookup time: #{lookup_time} μs")
      IO.puts("==========================================\n")

      # Performance assertions (generous to account for different hardware)
      assert insert_time < 5_000_000, "Insert should be under 5 seconds"
      assert batch_time < 2_000_000, "Batch insert should be under 2 seconds"
      assert autocomplete_time < 100_000, "Autocomplete should be under 100ms"
      assert lookup_time < 10_000, "Lookup should be under 10ms"
    end

    @tag timeout: :infinity
    test "memory efficiency with shared prefixes" do
      trie = TrieHard.new()

      # Insert many words with shared prefixes
      prefixes = ["application", "appreciate", "approach", "appropriate"]

      words =
        for prefix <- prefixes,
            suffix <- 1..1000,
            do: "#{prefix}_#{suffix}"

      {time, _} =
        :timer.tc(fn ->
          TrieHard.add_word_list(trie, words)
        end)

      # Test prefix search performance
      {prefix_time, {_, found}} =
        :timer.tc(fn ->
          TrieHard.prefix_search(trie, "app")
        end)

      # Test autocomplete performance
      {complete_time, {_, results}} =
        :timer.tc(fn ->
          TrieHard.auto_complete(trie, "application", 50)
        end)

      IO.puts("\n=== Memory Efficiency Test ===")
      IO.puts("Words with shared prefixes: #{length(words)}")
      IO.puts("Insert time: #{time / 1000} ms")
      IO.puts("Prefix search time: #{prefix_time} μs (found: #{found})")
      IO.puts("Autocomplete time: #{complete_time} μs (#{length(results)} results)")
      IO.puts("===============================\n")

      assert found == true
      assert length(results) <= 50
      assert prefix_time < 10_000, "Prefix search should be very fast"
      assert complete_time < 50_000, "Autocomplete should be under 50ms"
    end
  end
end
