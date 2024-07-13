//
//  TrieNode.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/12.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

/// A node in the Trie data structure.
/// Each node represents a single character and contains child nodes for subsequent characters.
class TrieNode {
    /// Dictionary to store child nodes where each key is a character and the value is a TrieNode.
    var children: [Character: TrieNode] = [:]

    /// Boolean flag to indicate if the node represents the end of a word.
    var isEndOfWord: Bool = false
}
