//
//  Dictionary+Keys.swift
//  Utilities
//
//  Created by Chien, Arnold on 6/18/19.
//  Copyright © 2019 Chien, Arnold. All rights reserved.
//

import Foundation

public extension Dictionary {
    /**
     Test for equality of self's keys with those of another dictionary.
     - Parameter other: the other dictionary.
     - Returns: boolean result.
     */
    func keysEqual<T>(keysIn other: [Key: T]) -> Bool {
        return Set(keys) == Set(other.keys)
    }
}
