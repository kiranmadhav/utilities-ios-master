//
//  Array+Random.swift
//  Utilities
//
//  Created by Brooks, Jon on 2/2/18.
//  Copyright © 2018 McGraw-Hill Education. All rights reserved.
//

import Foundation

private extension CountableRange where Bound == Int {
    var random: Bound? {
        if lowerBound == upperBound {
            return nil
        }

        var a = lowerBound
        var b = upperBound - 1
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
}


public extension Array {
    var randomElement: Element? {
        if let randomIndex = indices.random {
            return self[randomIndex]
        }

        return nil
    }
}
