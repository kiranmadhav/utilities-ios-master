//
//  UIColor+JSON.swift
//  Utilities
//
//  Created by Ian Salkind on 3/13/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public extension UIColor {
    // From: http://stackoverflow.com/questions/10675390/iphone-ios-how-to-serialize-save-uicolor-to-json-file
    /**
     Retrieve a string representation of the color. Use in conjunction with String.json_color()
     - Returns: The string.
     */
    func json_stringValue() -> String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        var h: CGFloat = 0
        var s: CGFloat = 0
        var w: CGFloat = 0

        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return "rgba:\(r),\(g),\(b),\(a)"
        } else if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return "hsba:\(h),\(s),\(b),\(a)"
        } else if self.getWhite(&w, alpha: &a) {
            return "wa:\(w),\(a)"
        }

        NSLog("WARNING: unable to serialize color %@", self)
        return nil
    }
}
