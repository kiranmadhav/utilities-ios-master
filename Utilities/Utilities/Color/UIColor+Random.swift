//
//  UIColor+Random.swift
//  Utilities
//
//  Created by Chien, Arnold on 5/24/19.
//  Copyright © 2019 Chien, Arnold. All rights reserved.
//

import UIKit

public extension UIColor {
    /**
     Creates a random UIColor object from a seed and optional alpha value.
     - Parameter fromSeed: the seed for randomization.
     - Parameter withAlpha: the alpha value.
     - Returns: The color.
     */
    convenience init(fromSeed seed: String, withAlpha alpha: CGFloat = 1) {
        var total = 0
        seed.unicodeScalars.forEach({ total += Int(UInt32($0)) })
        srand48(total)
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
