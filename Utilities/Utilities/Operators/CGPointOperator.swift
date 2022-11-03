//
//  CGPointOperator.swift
//  Utilities
//
//  Created by Chien, Arnold on 6/18/19.
//  Copyright © 2019 Chien, Arnold. All rights reserved.
//

import Foundation
import CoreGraphics

//Plus/Minus Operators operate on CGPoint by adding/subtracting the x and y components
public func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

//swiftlint:disable shorthand_operator
public func += (lhs:inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
}

public func -= (lhs:inout CGPoint, rhs: CGPoint) {
    lhs = lhs - rhs
}
