//
//  DeviceMetrics.swift
//  Utilities
//
//  Created by Chien, Arnold on 5/3/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation
import CoreGraphics

open class DeviceMetrics {
    public enum ScreenSize {
        /// iPhone 4
        case small
        /// iPhone 5, SE
        case medium
        /// iPhone 6, 7, 8
        case large
        /// Plus sized phones
        case plus
        /// iPhone X
        case x
    }

    /**
     Screen height for a given iPhone screen.
     - Parameter screenSize: the screen size.
     - Returns: the height in points.
     */
    public static func screenHeight(screenSize: ScreenSize) -> CGFloat {
        switch screenSize {
        case .small:
            return 480
        case .medium:
            return 568
        case .large:
            return 667
        case .plus:
            return 736
        case .x:
            return 812
        }
    }
}
