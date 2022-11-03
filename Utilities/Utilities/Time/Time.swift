//
//  Time.swift
//  Utilities
//
// Created by kurtu on 5/15/17.
// Copyright (c) 2017 mhe. All rights reserved.
//

import Foundation

private extension TimeZone {
    static let utc = TimeZone(identifier: "UTC")
}

private extension Locale {
    static let posix = Locale(identifier: "en_US_POSIX")
}

open class Time {
    public static var gmtOffsetFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //formats to +/-HH:mm
        formatter.dateFormat = "ZZZZZ"
        return formatter
    }()
    
    public static var iso8601Formatter: DateFormatter = iso8601Formatter_3MS
    public static var iso8601Formatter_0MS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = .utc
        formatter.locale = .posix
        return formatter
    }()
    public static var iso8601Formatter_1MS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZZZZZ"
        formatter.timeZone = .utc
        formatter.locale = .posix
        return formatter
    }()
    public static var iso8601Formatter_2MS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZZZZZ"
        formatter.timeZone = .utc
        formatter.locale = .posix
        return formatter
    }()
    public static var iso8601Formatter_3MS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = .utc
        formatter.locale = .posix
        return formatter
    }()
    public static var iso86010ZFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        formatter.timeZone = .utc
        formatter.locale = .posix
        return formatter
    }()
    
    public static var iso8601ZFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = .utc
        formatter.locale = .posix
        return formatter
    }()
    
    public static var gmtOffsetFormatted: String {
        return gmtOffsetFormatter.string(from: Date())
    }
    
    public static var iso8601Formatted: String {
        return iso8601Formatter.string(from: Date())
    }
    
    public static var iso8601ZFormatted: String {
        return iso8601ZFormatter.string(from: Date())
    }

    public static func formatted(duration: TimeInterval, withUnits units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration)
    }
}
