use rustler::{Atom, Env, ResourceArc, Term};
use trie_hard_rs::Trie;
use std::sync::Mutex;

mod atoms {
    rustler::atoms! {
        ok,
        error,
        nil,
        not_found,
    }
}

pub struct TrieResource {
    trie: Mutex<Trie<String>>,
}

impl TrieResource {
    fn new() -> Self {
        TrieResource {
            trie: Mutex::new(Trie::new()),
        }
    }
}

#[rustler::nif]
fn new_trie() -> ResourceArc<TrieResource> {
    ResourceArc::new(TrieResource::new())
}

#[rustler::nif]
fn insert(trie_resource: ResourceArc<TrieResource>, key: String, value: String) -> Atom {
    match trie_resource.trie.lock() {
        Ok(mut trie) => {
            trie.insert(&key, &value);
            atoms::ok()
        }
        Err(_) => atoms::error()
    }
}

#[rustler::nif]
fn get(trie_resource: ResourceArc<TrieResource>, key: String) -> (Atom, Option<String>) {
    match trie_resource.trie.lock() {
        Ok(trie) => {
            match trie.get(&key) {
                Some(value) => (atoms::ok(), Some(value.clone())),
                None => (atoms::not_found(), None)
            }
        }
        Err(_) => (atoms::error(), None)
    }
}

#[rustler::nif]
fn delete(trie_resource: ResourceArc<TrieResource>, key: String) -> Atom {
    match trie_resource.trie.lock() {
        Ok(mut trie) => {
            trie.delete(&key);
            atoms::ok()
        }
        Err(_) => atoms::error()
    }
}

#[rustler::nif]
fn prefix_search(trie_resource: ResourceArc<TrieResource>, prefix: String) -> (Atom, bool) {
    match trie_resource.trie.lock() {
        Ok(trie) => (atoms::ok(), trie.prefix_search(&prefix)),
        Err(_) => (atoms::error(), false)
    }
}

#[rustler::nif]
fn auto_complete(trie_resource: ResourceArc<TrieResource>, prefix: String, max_results: usize) -> (Atom, Vec<String>) {
    match trie_resource.trie.lock() {
        Ok(trie) => {
            let results = trie.auto_complete(&prefix, max_results);
            (atoms::ok(), results)
        }
        Err(_) => (atoms::error(), Vec::new())
    }
}

#[rustler::nif]
fn add_word_list(trie_resource: ResourceArc<TrieResource>, words: Vec<String>) -> Atom {
    match trie_resource.trie.lock() {
        Ok(mut trie) => {
            let word_refs: Vec<&str> = words.iter().map(|s| s.as_str()).collect();
            trie.add_word_list(&word_refs, |word| word.to_string());
            atoms::ok()
        }
        Err(_) => atoms::error()
    }
}

fn load(env: Env, _info: Term) -> bool {
    let _ = rustler::resource!(TrieResource, env);
    true
}

rustler::init!("Elixir.TrieAgain.Native", load = load);
