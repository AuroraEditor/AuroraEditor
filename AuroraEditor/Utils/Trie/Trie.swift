//
//  Trie.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/12.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

/// A Trie data structure for storing and searching strings.
/// A Trie is an efficient information retrieval data structure, typically used for searching
/// words in a dictionary, auto-completion, and spell checking.
class Trie {
    /// Root node of the Trie. The root does not store any character and serves as the starting point.
    private let root = TrieNode()

    /// Inserts a word into the Trie.
    /// - Parameter word: The word to be inserted into the Trie.
    /// - Complexity: O(n), where n is the length of the word.
    ///
    /// This function iterates over each character in the word. If the character
    /// does not exist in the current node's children,
    /// a new TrieNode is created. This process continues until all characters in 
    /// the word are inserted. The last node is then
    /// marked as the end of a word.
    func insert(_ word: String) {
        var current = root
        // Iterate through each character in the word.
        for char in word {
            // Check if the character already exists in the current node's children.
            if let nextNode = current.children[char] {
                current = nextNode
            } else {
                // If the character does not exist, create a new TrieNode.
                let newNode = TrieNode()
                current.children[char] = newNode
                current = newNode
            }
        }
        // Mark the last node as the end of the word.
        current.isEndOfWord = true
    }

    /// Searches for a word in the Trie.
    /// - Parameter word: The word to search for in the Trie.
    /// - Returns: True if the word exists in the Trie, false otherwise.
    /// - Complexity: O(n), where n is the length of the word.
    ///
    /// This function iterates over each character in the word. If any character
    /// does not exist in the current node's children,
    /// the function returns false. If all characters are found, it checks if the last 
    /// node is marked as the end of a word and
    /// returns true or false accordingly.
    func search(_ word: String) -> Bool {
        var current = root
        // Iterate through each character in the word.
        for char in word {
            // If the character does not exist in the current node's children, return false.
            guard let nextNode = current.children[char] else {
                return false
            }
            current = nextNode
        }
        // Return true if the current node is marked as the end of a word.
        return current.isEndOfWord
    }

    /// Searches for a prefix in the Trie.
    /// - Parameter prefix: The prefix to search for in the Trie.
    /// - Returns: True if the prefix exists in the Trie, false otherwise.
    /// - Complexity: O(n), where n is the length of the prefix.
    ///
    /// This function iterates over each character in the prefix. If any character
    /// does not exist in the current node's children, the function returns false.
    /// If all characters are found, it returns true.
    func startsWith(_ prefix: String) -> Bool {
        var current = root
        // Iterate through each character in the prefix.
        for char in prefix {
            // If the character does not exist in the current node's children, return false.
            guard let nextNode = current.children[char] else {
                return false
            }
            current = nextNode
        }
        // Return true if the prefix exists in the Trie.
        return true
    }
}
