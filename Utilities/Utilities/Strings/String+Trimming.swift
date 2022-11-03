//
//  String+Trimming.swift
//  Utilities
//
//  Created by Brooks, Jon on 8/23/18.
//  Copyright © 2018 McGraw-Hill Education. All rights reserved.
//

import Foundation

public extension String {
    
    /**
     Remove prefix from the string.
     - Parameter prefix: the prefix to remove.
     - Returns: the resulting string.
     */
    func withPrefixRemoved(_ prefix: String) -> String {
        if let range = self.range(of: prefix, options: [.anchored]) {
            return replacingCharacters(in: range, with: "")
        }
        
        return self
    }

    /**
     Remove trailing spaces.
     - Returns: the resulting string.
     */
    func trimmingTrailingSpaces() -> String {
        var t = self
        while t.hasSuffix(" ") {
            t = "" + t.dropLast()
        }
        return t
    }
}
