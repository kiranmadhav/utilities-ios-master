//
//  CGRect+Point.swift
//  Utilities
//
//  Created by jbrooks on 2/6/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGRect {
    //Returns the CGPoint in the center of the the rect
    var center: CGPoint {
        return origin + CGPoint(x: width / 2, y: height / 2)
    }
}
