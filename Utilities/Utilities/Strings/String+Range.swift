//
//  String+Range.swift
//  Utilities
//
//  Created by Chien, Arnold on 7/23/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//
//  Based on https://stackoverflow.com/questions/36865443/get-all-ranges-of-a-substring-in-a-string-in-swift
//

import Foundation

extension String {
    /**
    Find the range for each occurrence of a substring. 
    - Returns: the ranges.
    */
    public func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        // Iterate for as long as we haven't ruled out finding a first or an additional substring occurrence.
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}
