//
//  String+Capitalization.swift
//  Utilities
//
//  Created by Chien, Arnold on 5/28/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//
//  from https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
//

import Foundation

extension String {
    /**
     Capitalize the first letter of the string
     - Returns: the resulting string.
     */
    public func capitalizedFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    /**
     Capitalize the first letter of the string.  Mutating version of the above.
     */
    public mutating func capitalizeFirstLetter() {
        self = capitalizedFirstLetter()
    }
}
