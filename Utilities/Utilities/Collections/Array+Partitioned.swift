//
//  Array+Partitioned.swift
//  Utilities
//
//  Created by Brooks, Jon on 7/11/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//

import Foundation

public extension Array {
    /**
        A non-mutating version of `partition(by:)` that returns 2 array slices of the included/rejected elements.
        Refer to `partition(by:)` for specifics on the partitioning algorithm.
     */
    func partitioned(by test: (Element) throws -> Bool) rethrows -> (included: ArraySlice<Element>, rejected: ArraySlice<Element>) {
        var arr = self
        let divison = try arr.partition(by: test)

        return (included: arr[divison ..< arr.count], rejected: arr[0 ..< divison])
    }
}
