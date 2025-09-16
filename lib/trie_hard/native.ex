defmodule TrieHard.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links]["GitHub"]

  use RustlerPrecompiled,
    otp_app: :trie_hard,
    crate: "trie_hard_native",
    base_url: "#{github_url}/releases/download/v#{version}",
    force_build: System.get_env("TRIE_HARD_BUILD") in ["1", "true"],
    version: version

  # Placeholder functions that will be replaced by NIF implementations
  def new_trie, do: :erlang.nif_error(:nif_not_loaded)
  def insert(_trie, _key, _value), do: :erlang.nif_error(:nif_not_loaded)
  def get(_trie, _key), do: :erlang.nif_error(:nif_not_loaded)
  def delete(_trie, _key), do: :erlang.nif_error(:nif_not_loaded)
  def prefix_search(_trie, _prefix), do: :erlang.nif_error(:nif_not_loaded)
  def auto_complete(_trie, _prefix, _max_results), do: :erlang.nif_error(:nif_not_loaded)
  def add_word_list(_trie, _words), do: :erlang.nif_error(:nif_not_loaded)
end
