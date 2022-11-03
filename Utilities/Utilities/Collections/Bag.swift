//
//  Bag.swift
//  Utilities
//
//  Created by Ian Salkind on 3/12/16.
//  Copyright © 2016 MHE. All rights reserved.
//
//  From: http://www.informit.com/articles/article.aspx?p=2236037
//
//  Implementation of an counted set (NSCountedSet), a mutable, unordered collection of indistinct objects.
//
//  Each distinct object inserted into Bag object has a counter associated with it.
//  Bag keeps track of the number of times objects are inserted and requires that objects be
//  removed the same number of times. Thus, there is only one instance of an object in a Bag object
//  even if the object has been added to the set multiple times.
//

import Foundation

open class Bag<T: Hashable>: CustomStringConvertible {
    fileprivate var _storage = [T: Int]()

    /**
     Initialize with the given items.
     - Parameter items: items to bag.
     - Returns: the bag.
     */
    public init(_ items: T ...) {
        for item in items {
            self.add(item)
        }
    }

    /**
     Initialize with the given array of items.
     - Parameter items: array of items to bag.
     - Returns: the bag.
     */
    public init(_ items: [T]) {
        for item in items {
            self.add(item)
        }
    }

    /**
     Add an item to the bag, increment the count.
     - Parameter item: item to add.
     */
    private func add(_ item: T) {
        if let count = _storage[item] {
            _storage[item] = count + 1
        } else {
            _storage[item] = 1
        }
    }

    /**
     Remove an item from the bag, increment the count.
     - Parameter item: item to remove.
     */
    private func remove(_ item: T) {
        if let count = _storage[item] {
            if count > 1 {
                _storage[item] = count - 1
            } else {
                _storage.removeValue(forKey: item)
            }
        }
    }

    /**
     Retrieve a count of a specific item in the bag.
     - Parameter item: item whose count we want.
     - Returns: the count.
     */
    private func countFor(_ item: T) -> Int {
        if let count = _storage[item] {
            return count
        } else {
            return 0
        }
    }

    /**
     Retrieve the items as a map collection.
     - Returns: the map collection.
     */
    public func keys() -> Dictionary<T, Int>.Keys {
        return _storage.keys
    }

    //
    // Information about the bag
    //
    public var description: String {
        return _storage.description
    }
}

public struct BagGenerator<T: Hashable>: IteratorProtocol {
    private var backingGenerator: DictionaryIterator<T, Int>
    public init(_ backingDictionary: [T: Int]) {
        backingGenerator = backingDictionary.makeIterator()
    }
    public typealias Element = (T, Int)
    public mutating func next() -> (T, Int)? {
        return backingGenerator.next()
    }
}

//
// Allow iterations over the bag contents
//
extension Bag: Sequence {
    public typealias Iterator = BagGenerator<T>
    public func makeIterator() -> BagGenerator<T> {
        return BagGenerator<T>(_storage)
    }
}
