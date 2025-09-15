# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-09-15

### Added

- Initial release of TrieAgain
- Complete Trie implementation powered by trie_hard_rs Rust library
- Core operations: `new/0`, `insert/3`, `get/2`, `delete/2`
- Search operations: `prefix_search/2`, `auto_complete/3`, `count_prefix/2`
- Batch operations: `add_word_list/2` for efficient bulk insertions
- Thread-safe concurrent access with Rust's safety guarantees
- Full Unicode support including emojis
- High-performance benchmarks:
  - Insert: 0.66μs per word (individual), 0.59μs per word (batch)
  - Lookup: 2μs
  - Autocomplete: 155μs for 100 results
  - Prefix search: 4μs
- Comprehensive test suite with 30+ tests
- Complete API documentation with examples
- Memory-efficient shared prefix storage

### Technical Details

- Requires Rust nightly toolchain for edition 2024 support
- Built with Rustler for seamless Elixir-Rust integration
- Uses `trie_hard_rs` v0.1.0 for core trie functionality
- Elixir 1.18+ compatibility