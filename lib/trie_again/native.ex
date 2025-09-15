defmodule TrieAgain.Native do
  @moduledoc false

  use Rustler, otp_app: :trie_again, crate: "trie_again_native"

  # Placeholder functions that will be replaced by NIF implementations
  def new_trie, do: :erlang.nif_error(:nif_not_loaded)
  def insert(_trie, _key, _value), do: :erlang.nif_error(:nif_not_loaded)
  def get(_trie, _key), do: :erlang.nif_error(:nif_not_loaded)
  def delete(_trie, _key), do: :erlang.nif_error(:nif_not_loaded)
  def prefix_search(_trie, _prefix), do: :erlang.nif_error(:nif_not_loaded)
  def auto_complete(_trie, _prefix, _max_results), do: :erlang.nif_error(:nif_not_loaded)
  def add_word_list(_trie, _words), do: :erlang.nif_error(:nif_not_loaded)
end