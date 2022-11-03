//
//  Dictionary+Data.swift
//  Utilities
//
//  Created by Chien, Arnold on 6/18/19.
//  Copyright © 2019 Chien, Arnold. All rights reserved.
//

import Foundation

public extension Dictionary {
    var asData: Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
