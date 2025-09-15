defmodule TrieAgainTest do
  use ExUnit.Case
  doctest TrieAgain

  describe "basic operations" do
    test "creates a new trie" do
      trie = TrieAgain.new()
      assert is_reference(trie)
    end

    test "inserts and retrieves values" do
      trie = TrieAgain.new()

      assert TrieAgain.insert(trie, "hello", "world") == :ok
      assert TrieAgain.get(trie, "hello") == {:ok, "world"}
    end

    test "returns not_found for missing keys" do
      trie = TrieAgain.new()

      assert TrieAgain.get(trie, "missing") == {:not_found, nil}
    end

    test "deletes keys" do
      trie = TrieAgain.new()

      assert TrieAgain.insert(trie, "hello", "world") == :ok
      assert TrieAgain.get(trie, "hello") == {:ok, "world"}

      assert TrieAgain.delete(trie, "hello") == :ok
      assert TrieAgain.get(trie, "hello") == {:not_found, nil}
    end

    test "handles multiple key-value pairs" do
      trie = TrieAgain.new()

      assert TrieAgain.insert(trie, "cat", "feline") == :ok
      assert TrieAgain.insert(trie, "car", "vehicle") == :ok
      assert TrieAgain.insert(trie, "card", "payment") == :ok

      assert TrieAgain.get(trie, "cat") == {:ok, "feline"}
      assert TrieAgain.get(trie, "car") == {:ok, "vehicle"}
      assert TrieAgain.get(trie, "card") == {:ok, "payment"}
    end
  end

  describe "prefix operations" do
    setup do
      trie = TrieAgain.new()

      TrieAgain.insert(trie, "cat", "feline")
      TrieAgain.insert(trie, "car", "vehicle")
      TrieAgain.insert(trie, "card", "payment")
      TrieAgain.insert(trie, "care", "attention")
      TrieAgain.insert(trie, "dog", "canine")

      {:ok, trie: trie}
    end

    test "prefix search finds existing prefixes", %{trie: trie} do
      assert TrieAgain.prefix_search(trie, "ca") == {:ok, true}
      assert TrieAgain.prefix_search(trie, "car") == {:ok, true}
      assert TrieAgain.prefix_search(trie, "do") == {:ok, true}
    end

    test "prefix search returns false for non-existing prefixes", %{trie: trie} do
      assert TrieAgain.prefix_search(trie, "xyz") == {:ok, false}
      assert TrieAgain.prefix_search(trie, "bat") == {:ok, false}
    end

    test "auto complete returns matching words", %{trie: trie} do
      {:ok, results} = TrieAgain.auto_complete(trie, "ca", 10)

      # Results should contain words starting with "ca"
      assert is_list(results)
      assert length(results) >= 3  # at least "car", "card", "care", "cat"

      # All results should start with "ca"
      Enum.each(results, fn word ->
        assert String.starts_with?(word, "ca")
      end)
    end

    test "auto complete respects max results limit", %{trie: trie} do
      {:ok, results} = TrieAgain.auto_complete(trie, "ca", 2)

      assert is_list(results)
      assert length(results) <= 2
    end

    test "auto complete with empty prefix", %{trie: trie} do
      {:ok, results} = TrieAgain.auto_complete(trie, "", 10)

      # Should return all words
      assert is_list(results)
      assert length(results) == 5
    end

    test "count_prefix returns correct counts", %{trie: trie} do
      assert TrieAgain.count_prefix(trie, "ca") == {:ok, 4}  # car, card, care, cat
      assert TrieAgain.count_prefix(trie, "car") == {:ok, 3} # car, card, care
      assert TrieAgain.count_prefix(trie, "do") == {:ok, 1}  # dog
      assert TrieAgain.count_prefix(trie, "xyz") == {:ok, 0} # none
    end
  end

  describe "batch operations" do
    test "add_word_list inserts multiple words" do
      trie = TrieAgain.new()
      words = ["apple", "application", "apply", "banana", "band"]

      assert TrieAgain.add_word_list(trie, words) == :ok

      # Each word should be inserted with itself as value
      Enum.each(words, fn word ->
        assert TrieAgain.get(trie, word) == {:ok, word}
      end)
    end

    test "add_word_list with empty list" do
      trie = TrieAgain.new()

      assert TrieAgain.add_word_list(trie, []) == :ok
    end

    test "add_word_list enables autocomplete" do
      trie = TrieAgain.new()
      words = ["apple", "application", "apply", "banana", "band"]

      assert TrieAgain.add_word_list(trie, words) == :ok

      {:ok, results} = TrieAgain.auto_complete(trie, "app", 10)
      assert length(results) == 3  # apple, application, apply

      {:ok, results} = TrieAgain.auto_complete(trie, "ban", 10)
      assert length(results) == 2  # banana, band
    end
  end

  describe "edge cases and error handling" do
    test "handles empty strings" do
      trie = TrieAgain.new()

      assert TrieAgain.insert(trie, "", "empty") == :ok
      assert TrieAgain.get(trie, "") == {:ok, "empty"}

      assert TrieAgain.prefix_search(trie, "") == {:ok, true}
    end

    test "handles unicode characters" do
      trie = TrieAgain.new()

      assert TrieAgain.insert(trie, "café", "coffee") == :ok
      assert TrieAgain.insert(trie, "naïve", "innocent") == :ok
      assert TrieAgain.insert(trie, "🦀", "crab") == :ok

      assert TrieAgain.get(trie, "café") == {:ok, "coffee"}
      assert TrieAgain.get(trie, "naïve") == {:ok, "innocent"}
      assert TrieAgain.get(trie, "🦀") == {:ok, "crab"}

      {:ok, results} = TrieAgain.auto_complete(trie, "caf", 5)
      assert "café" in results
    end

    test "handles very long strings" do
      trie = TrieAgain.new()
      long_key = String.duplicate("a", 1000)
      long_value = String.duplicate("b", 1000)

      assert TrieAgain.insert(trie, long_key, long_value) == :ok
      assert TrieAgain.get(trie, long_key) == {:ok, long_value}
    end

    test "overwrites existing values" do
      trie = TrieAgain.new()

      assert TrieAgain.insert(trie, "key", "value1") == :ok
      assert TrieAgain.get(trie, "key") == {:ok, "value1"}

      assert TrieAgain.insert(trie, "key", "value2") == :ok
      assert TrieAgain.get(trie, "key") == {:ok, "value2"}
    end

    test "delete non-existing key doesn't error" do
      trie = TrieAgain.new()

      assert TrieAgain.delete(trie, "non-existing") == :ok
    end

    test "handles large datasets efficiently" do
      trie = TrieAgain.new()

      # Insert 1000 words
      words = for i <- 1..1000, do: "word#{i}"
      assert TrieAgain.add_word_list(trie, words) == :ok

      # Test random access
      assert TrieAgain.get(trie, "word500") == {:ok, "word500"}
      assert TrieAgain.get(trie, "word999") == {:ok, "word999"}

      # Test prefix search
      assert TrieAgain.prefix_search(trie, "word1") == {:ok, true}

      # Test autocomplete with limits
      {:ok, results} = TrieAgain.auto_complete(trie, "word1", 20)
      assert length(results) <= 20
    end
  end

  describe "concurrent access" do
    test "multiple processes can access same trie safely" do
      trie = TrieAgain.new()

      # Insert initial data
      TrieAgain.insert(trie, "shared", "data")

      # Spawn multiple processes to access the trie
      tasks = for i <- 1..10 do
        Task.async(fn ->
          TrieAgain.insert(trie, "process#{i}", "data#{i}")
          TrieAgain.get(trie, "shared")
        end)
      end

      # Wait for all tasks and collect results
      results = Task.await_many(tasks)

      # All should successfully read the shared data
      Enum.each(results, fn result ->
        assert result == {:ok, "data"}
      end)

      # Verify all individual inserts worked
      for i <- 1..10 do
        assert TrieAgain.get(trie, "process#{i}") == {:ok, "data#{i}"}
      end
    end
  end
end
