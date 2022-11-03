//
//  UIColor+Contrast.m
//  Utilities
//
//  Created by Ian Salkind on 3/11/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public extension UIColor {
    //
    // From: http://stackoverflow.com/questions/1855884/determine-font-color-based-on-background-color
    //
    typealias RGBATuple = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    /**
     Compute a contrasting color to this color
     - Returns: The string.
     */
    func contrastColor() -> RGBATuple {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Counting the perceptive luminance - human eye favors green color...
        let pl = 1 - (0.299 * r + 0.587 * g + 0.114 * b)
        let color: CGFloat = (pl < 0.5 ? 0.0 : 1.0)
        return (color, color, color, 1.0)
    }
}
