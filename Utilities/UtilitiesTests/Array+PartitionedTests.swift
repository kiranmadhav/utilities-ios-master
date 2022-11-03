//
//  Array+PartitionedTests.swift
//  UtilitiesTests
//
//  Created by Brooks, Jon on 7/11/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//

import XCTest

class Array_PartitionedTests: XCTestCase {



    func testBasic() {
        let (even, odd) = [1, 2, 3, 4, 5, 6].partitioned { $0 % 2 == 0 }

        XCTAssertEqual(Set(even), Set([2, 4, 6]))
        XCTAssertEqual(Set(odd), Set([1, 3, 5]))
    }

    func testEmpty1() {
        let (all, none) = [1, 2, 3, 4, 5, 6].partitioned { _ in true }

        XCTAssertEqual(Set(all), Set([1, 2, 3, 4, 5, 6]))
        XCTAssertEqual(none, [])
    }

    func testEmpty2() {
        let (none, all) = [1, 2, 3, 4, 5, 6].partitioned { _ in false }

        XCTAssertEqual(Set(all), Set([1, 2, 3, 4, 5, 6]))
        XCTAssertEqual(none, [])
    }
}
