//
//  Collection+Shuffle.swift
//  Utilities
//
//  Created by kurtu on 3/29/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

//From http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
public extension Collection {
    /**
     Returns a copy of `self` with its elements shuffled.
     - Returns: the shuffled collection.
     */
    func shuffled() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

public extension MutableCollection where Index == Int {
    /**
     Shuffle the elements of `self` in-place.
     */
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle

        let countAsInt = self.endIndex

        if countAsInt < 2 { return }

        for i in 0..<countAsInt - 1 {
            let j = Int(arc4random_uniform(UInt32(countAsInt - i))) + i
            guard i != j else { continue }
            self.swapAt(i, j)
        }
    }
}
