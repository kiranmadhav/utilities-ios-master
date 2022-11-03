//
//  ISOJSONCodable.swift
//  Utilities
//
//  Created by Brooks, Jon on 4/21/21.
//  Copyright © 2021 Chien, Arnold. All rights reserved.
//

import Foundation

/// ISOJSONDecoder simply changes the default date decodlng strategy to ISO-8601 (supporting up to 3 fractions of a second)
public class ISOJSONDecoder: JSONDecoder {
    public override init() {
        super.init()
        dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            let decoded =
                    Time.iso8601Formatter_3MS.date(from: dateStr) ??
                    Time.iso8601Formatter_2MS.date(from: dateStr) ??
                    Time.iso8601Formatter_1MS.date(from: dateStr) ??
                    Time.iso8601Formatter_0MS.date(from: dateStr)

            guard let date = decoded else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
            }
            return date
        })

    }
}

/// ISOJSONEncoder simply changes the default date encoding strategy to ISO-8601
public class ISOJSONEncoder: JSONEncoder {
    public override init() {
        super.init()
        dateEncodingStrategy = .formatted(Time.iso8601Formatter)
    }
}
