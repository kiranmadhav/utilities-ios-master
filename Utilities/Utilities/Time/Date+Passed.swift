//
//  Date+Passed.swift
//  Utilities
//
//  Created by Brooks, Jon on 3/18/19.
//  Copyright © 2019 MHE. All rights reserved.
//

import Foundation

public extension Date {
    
    var isLessThan24HoursAgo: Bool {
        return timeIntervalSinceNow > -(60 * 60 * 24)
    }

    var hasPassed: Bool {
        return timeIntervalSinceNow < 0
    }

    var isInFuture: Bool {
        return timeIntervalSinceNow > 0
    }

    /**
     Whether this date is after the given date.
     - Parameter date: the other date.
     - Returns: the boolean result.
     */
    func isAfter(_ date: Date) -> Bool {
        return timeIntervalSince(date) > 0
    }

    /**
     Whether this date is before the given date.
     - Parameter date: the other date.
     - Returns: the boolean result.
     */
    func isBefore(_ date: Date) -> Bool {
        return timeIntervalSince(date) < 0
    }

    /**
     Whether this date is the same as the given date.
     - Parameter date: the other date.
     - Returns: the boolean result.
     */
    func isSame(_ date: Date) -> Bool {
        return timeIntervalSince(date) == 0
    }

    func isOlderThan(_ timeInterval: TimeInterval) -> Bool {
        return -timeIntervalSinceNow > timeInterval
    }
}
