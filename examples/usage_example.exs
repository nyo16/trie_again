# TrieAgain Usage Examples
# Run with: elixir -r lib/trie_again.ex -r lib/trie_again/native.ex examples/usage_example.exs

defmodule UsageExample do
  def run do
    IO.puts("=== TrieAgain Usage Examples ===\n")

    # Basic operations
    basic_operations()

    # Autocomplete example
    autocomplete_example()

    # Batch operations
    batch_operations_example()

    # Unicode support
    unicode_example()

    # Large dataset example
    large_dataset_example()

    IO.puts("\n=== Examples completed! ===")
  end

  defp basic_operations do
    IO.puts("1. Basic Operations:")

    trie = TrieAgain.new()

    # Insert some key-value pairs
    TrieAgain.insert(trie, "cat", "A small domesticated carnivorous mammal")
    TrieAgain.insert(trie, "car", "A road vehicle with an engine")
    TrieAgain.insert(trie, "card", "A piece of stiff paper")

    # Retrieve values
    {:ok, cat_definition} = TrieAgain.get(trie, "cat")
    IO.puts("  cat: #{cat_definition}")

    # Check if keys exist
    case TrieAgain.get(trie, "dog") do
      {:ok, value} -> IO.puts("  dog: #{value}")
      {:not_found, _} -> IO.puts("  dog: not found")
    end

    IO.puts("")
  end

  defp autocomplete_example do
    IO.puts("2. Autocomplete Feature:")

    trie = TrieAgain.new()

    # Insert programming language names
    languages = ["JavaScript", "Java", "Python", "PHP", "Ruby", "Rust",
                 "Go", "Swift", "Kotlin", "Scala", "Perl", "Pascal"]

    Enum.each(languages, fn lang ->
      TrieAgain.insert(trie, String.downcase(lang), lang)
    end)

    # Autocomplete suggestions
    {:ok, java_suggestions} = TrieAgain.auto_complete(trie, "ja", 5)
    IO.puts("  Suggestions for 'ja': #{inspect(java_suggestions)}")

    {:ok, p_suggestions} = TrieAgain.auto_complete(trie, "p", 3)
    IO.puts("  Suggestions for 'p': #{inspect(p_suggestions)}")

    # Check prefix existence
    {:ok, has_rust} = TrieAgain.prefix_search(trie, "ru")
    IO.puts("  Has words starting with 'ru': #{has_rust}")

    {:ok, count} = TrieAgain.count_prefix(trie, "p")
    IO.puts("  Number of words starting with 'p': #{count}")

    IO.puts("")
  end

  defp batch_operations_example do
    IO.puts("3. Batch Operations:")

    trie = TrieAgain.new()

    # Common English words
    words = ["the", "be", "to", "of", "and", "a", "in", "that", "have",
             "it", "for", "not", "on", "with", "he", "as", "you", "do", "at"]

    # Batch insert
    start_time = System.monotonic_time(:microsecond)
    TrieAgain.add_word_list(trie, words)
    end_time = System.monotonic_time(:microsecond)

    IO.puts("  Inserted #{length(words)} words in #{end_time - start_time} μs")

    # Verify some insertions
    {:ok, _} = TrieAgain.get(trie, "the")
    {:ok, _} = TrieAgain.get(trie, "have")
    IO.puts("  Verified insertions successful")

    IO.puts("")
  end

  defp unicode_example do
    IO.puts("4. Unicode Support:")

    trie = TrieAgain.new()

    # Insert words in different languages
    unicode_words = [
      {"café", "French: coffee"},
      {"naïve", "French: innocent"},
      {"piñata", "Spanish: party decoration"},
      {"jalapeño", "Spanish: hot pepper"},
      {"🦀", "Emoji: crab"},
      {"🚀", "Emoji: rocket"},
      {"мир", "Russian: world"},
      {"こんにちは", "Japanese: hello"}
    ]

    Enum.each(unicode_words, fn {word, description} ->
      TrieAgain.insert(trie, word, description)
    end)

    # Test retrieval
    {:ok, cafe_def} = TrieAgain.get(trie, "café")
    IO.puts("  café: #{cafe_def}")

    {:ok, crab_def} = TrieAgain.get(trie, "🦀")
    IO.puts("  🦀: #{crab_def}")

    # Test prefix search with unicode
    {:ok, spanish_words} = TrieAgain.auto_complete(trie, "ja", 2)
    IO.puts("  Words starting with 'ja': #{inspect(spanish_words)}")

    IO.puts("")
  end

  defp large_dataset_example do
    IO.puts("5. Large Dataset Performance:")

    trie = TrieAgain.new()

    # Generate a larger dataset
    word_count = 5_000
    words = for i <- 1..word_count, do: "word_#{String.pad_leading("#{i}", 6, "0")}"

    # Measure batch insert time
    {insert_time, _} = :timer.tc(fn ->
      TrieAgain.add_word_list(trie, words)
    end)

    # Measure autocomplete performance
    {complete_time, {:ok, results}} = :timer.tc(fn ->
      TrieAgain.auto_complete(trie, "word_0001", 10)
    end)

    # Measure lookup performance
    test_word = "word_002500"
    {lookup_time, {:ok, _}} = :timer.tc(fn ->
      TrieAgain.get(trie, test_word)
    end)

    IO.puts("  Inserted #{word_count} words in #{insert_time/1000} ms")
    IO.puts("  Autocomplete (#{length(results)} results) in #{complete_time} μs")
    IO.puts("  Lookup time: #{lookup_time} μs")

    # Test prefix counting
    {:ok, prefix_count} = TrieAgain.count_prefix(trie, "word_00")
    IO.puts("  Words with prefix 'word_00': #{prefix_count}")

    IO.puts("")
  end
end

# Run the examples
UsageExample.run()