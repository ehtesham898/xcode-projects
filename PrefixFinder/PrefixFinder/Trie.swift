//
//  Trie.swift
//  PrefixFinder
//
//  Created by Rachel Schifano on 9/8/15.
//  Copyright (c) 2015 schifano. All rights reserved.
//

import UIKit
import Foundation

class Trie {
    
    var root: TrieNode!
    
    init() {
        root = TrieNode()
    }
    
    // Build recursive tree of dictionary content
    func addWord(keyword: String) {
        
        // Base case
        if keyword.length == 0 {
            return;
        }
        
        var current: TrieNode = root
        var searchKey: String!
        
        while (keyword.length != current.level) {
            var childToUse: TrieNode!
            var searchKey = keyword.substringToIndex(current.level + 1)
            
            // Iterate through Node children
            for child in current.children {
                if child.key == searchKey {
                    childToUse = child
                    break
                }
            }
            
            // Create a new Node
            if childToUse == nil {
                childToUse = TrieNode()
                childToUse.key = searchKey
                childToUse.level = current.level+1
                current.children.append(childToUse)
            }
            
            println("childToUse.key: \(childToUse.key)") // TEST
            println("childToUse.level: \(childToUse.level)") // TEST
            println("childToUse: \(childToUse)") // TEST
            
            current = childToUse
        }
        
        // Add final end of word check
        if (keyword.length == current.level) {
            current.isFinal = true
            println("End of word reached") // TEST
            return
        }
    }
    
    // FIXME: Why are words I added not being found?
    // Find words based on a prefix
    func findWord(keyword: String) -> Array<String>! {
        
        // Base case
        if keyword.length == 0 {
            return nil
        }
        
        var current: TrieNode = root
        var searchKey: String!
        var wordList: Array<String>! = Array<String>()
        
        while (keyword.length != current.level) {
            var childToUse: TrieNode!
            var searchKey = keyword.substringToIndex(current.level + 1)
            
            // Iterate through any children
            for child in current.children {
                if child.key == searchKey {
                    childToUse = child
                    current = childToUse
                    break
                }
            }
            
            // Prefix not found
            if childToUse == nil {
                return nil
            }
        }
        
        // Retrieve keyword and any descendants
        if ((current.key == keyword) && (current.isFinal)) {
            wordList.append(current.key)
        }
        
        // Add children that are words
        for child in current.children {
            if (child.isFinal == true) {
                wordList.append(child.key)
                println("child.key: \(child.key)") // TEST
            }
        }
  
        println(wordList) // TEST
        
        return wordList
    }
}