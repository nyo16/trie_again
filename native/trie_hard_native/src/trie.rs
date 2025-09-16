use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct TrieNode<T> {
    pub value: Option<T>,
    pub children: HashMap<char, TrieNode<T>>,
}

impl<T> TrieNode<T> {
    pub fn new() -> Self {
        TrieNode {
            value: None,
            children: HashMap::new(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct Trie<T> {
    root: TrieNode<T>,
}

impl<T: Clone> Trie<T> {
    pub fn new() -> Self {
        Trie {
            root: TrieNode::new(),
        }
    }

    pub fn insert(&mut self, key: &str, value: &T) {
        let mut current = &mut self.root;
        for ch in key.chars() {
            current = current.children.entry(ch).or_insert_with(TrieNode::new);
        }
        current.value = Some(value.clone());
    }

    pub fn get(&self, key: &str) -> Option<&T> {
        let mut current = &self.root;
        for ch in key.chars() {
            match current.children.get(&ch) {
                Some(node) => current = node,
                None => return None,
            }
        }
        current.value.as_ref()
    }

    pub fn delete(&mut self, key: &str) {
        Trie::delete_recursive(&mut self.root, key, 0);
    }

    fn delete_recursive(node: &mut TrieNode<T>, key: &str, index: usize) -> bool {
        if index == key.len() {
            if node.value.is_some() {
                node.value = None;
                return node.children.is_empty();
            }
            return false;
        }

        let ch = key.chars().nth(index).unwrap();
        if let Some(child) = node.children.get_mut(&ch) {
            let should_delete_child = Trie::delete_recursive(child, key, index + 1);
            if should_delete_child {
                node.children.remove(&ch);
            }
        }

        node.value.is_none() && node.children.is_empty()
    }

    pub fn prefix_search(&self, prefix: &str) -> bool {
        let mut current = &self.root;
        for ch in prefix.chars() {
            match current.children.get(&ch) {
                Some(node) => current = node,
                None => return false,
            }
        }
        true
    }

    pub fn auto_complete(&self, prefix: &str, max_results: usize) -> Vec<String> {
        let mut current = &self.root;
        for ch in prefix.chars() {
            match current.children.get(&ch) {
                Some(node) => current = node,
                None => return Vec::new(),
            }
        }

        let mut results = Vec::new();
        self.collect_words(current, prefix.to_string(), &mut results, max_results);
        results
    }

    fn collect_words(
        &self,
        node: &TrieNode<T>,
        prefix: String,
        results: &mut Vec<String>,
        max_results: usize,
    ) {
        if results.len() >= max_results {
            return;
        }

        if node.value.is_some() {
            results.push(prefix.clone());
        }

        for (ch, child) in &node.children {
            if results.len() >= max_results {
                break;
            }
            let mut new_prefix = prefix.clone();
            new_prefix.push(*ch);
            self.collect_words(child, new_prefix, results, max_results);
        }
    }

    pub fn add_word_list<F>(&mut self, words: &[&str], value_mapper: F)
    where
        F: Fn(&str) -> T,
    {
        for word in words {
            let value = value_mapper(word);
            self.insert(word, &value);
        }
    }
}