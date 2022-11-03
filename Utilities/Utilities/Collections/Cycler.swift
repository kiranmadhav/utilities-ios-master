//
//  Cycler.swift
//  Utilities
//
//  Created by Brooks, Jon on 4/2/18.
//  Copyright © 2018 MHE. All rights reserved.
//

import Foundation

// A Cycler takes an array of items, and provides methods to iterate
// forward or backward through them in an endless loop.
public struct Cycler<T> {
    // May have been intended as private or internal, but there is client code that uses this directly.
    public let items: [T]
    private var curIndex = 0
    private var indexOfNext: Int {
        return (curIndex + 1) % items.count
    }
    private var indexOfPrevious: Int {
        return (curIndex + items.count - 1) % items.count
    }

    /**
     Initialize cycler from an array of items..
     - Parameter items: the array.
     */
    public init(items: [T]) {
        self.items = items
    }

    public mutating func increment() {
        curIndex = indexOfNext
    }

    public mutating func decrement() {
        curIndex = indexOfPrevious
    }

    public var current: T {
        return items[curIndex]
    }

    public var next: T {
        return items[indexOfNext]
    }

    public var previous: T {
        return items[indexOfPrevious]
    }

    public func forEach(_ body: (T) throws -> Void) rethrows {
        try items.forEach(body)
    }
}
