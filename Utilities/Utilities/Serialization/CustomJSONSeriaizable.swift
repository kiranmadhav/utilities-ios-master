//
//  CustomJSONSeriaizable.swift
//  Utilities
//
//  Created by kurtu on 3/30/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

public protocol CustomJSONSeriaizable {
    var dictionaryValue: [String: Any] { get }
}

public extension CustomJSONSeriaizable {
    var utcFormatter: DateFormatter {
        let formatter = DateFormatter()
        // Prevent format from being overridden by user preference.
        // https://developer.apple.com/library/content/qa/qa1480/_index.html
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }
}
