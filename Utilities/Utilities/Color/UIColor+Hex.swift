//
//  UIColor+Hex.swift
//  Utilities
//
//  Created by jbrooks on 1/30/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public extension UIColor {

    /**
     Creates a UIColor object using a 6 or 7 character hex string with digits 0-9, and either upper or lower cases letters a-f.
     - Parameter hexString: the hex string.  Optionally begins with "#".
     - Parameter alpha: transparency value. Default is 1.0
     - Returns: The color, or nil if the hex string is malformed in any way.
     */
    convenience init?(hexString: String, alpha: Float = 1.0) {
        let redStart: String.Index
        if hexString.hasPrefix("#") {
            guard hexString.count == 7 else { return nil }
            redStart = hexString.index(after: hexString.startIndex)
        } else {
            guard hexString.count == 6 else { return nil }
            redStart = hexString.startIndex
        }
        
        let greenStart = hexString.index(redStart, offsetBy: 2)
        let blueStart = hexString.index(greenStart, offsetBy: 2)
        let end = hexString.endIndex

        let redString = hexString[redStart ..< greenStart]
        let greenString = hexString[greenStart ..< blueStart]
        let blueString = hexString[blueStart ..< end]

        guard let redInt = Int(redString, radix: 16) else { return nil }
        guard let greenInt = Int(greenString, radix: 16) else { return nil }
        guard let blueInt = Int(blueString, radix: 16) else { return nil }

        self.init(red: (CGFloat(redInt) / 255.0),
            green: (CGFloat(greenInt) / 255.0),
            blue: (CGFloat(blueInt) / 255.0),
            alpha: CGFloat(alpha))

    }

    
    /**
     Returns a string representation in hex for this color's red, green, and blue values.
     */
    var hexString: String? {
        func floatToHexString(float: CGFloat) -> String {
            return String(format: "%02X", Int(float * 255))
        }

        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return [red, green, blue].map(floatToHexString).joined()
        }
        return nil
    }
    
    // NOTE: This is a legacy function used only for support of legacy StudyWise content.  Do not use for any other purpose.
    /**
     Creates a UIColor object from a hex string with digits 0-9, and either upper or lower cases letters a-f, representing alpha, red, green, and blue values.
     - Parameter fromARGBHex: the hex string.  Optionally begins with "#".
     - Returns: The color.
     */
    convenience init(fromARGBHex hexString: String) {
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var hexInt: UInt32 = 0
        scanner.scanHexInt32(&hexInt)
        let alpha: CGFloat = CGFloat(((hexInt & 0xFF000000) >> 24)) / 255.0
        let red: CGFloat = CGFloat(((hexInt & 0x00FF0000) >> 16)) / 255.0
        let green: CGFloat = CGFloat(((hexInt & 0x0000FF00) >> 8)) / 255.0
        let blue: CGFloat = CGFloat((hexInt & 0x000000FF)) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
