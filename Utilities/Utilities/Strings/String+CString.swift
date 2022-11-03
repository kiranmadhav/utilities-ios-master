//
//  String+CString.swift
//  Utilities
//
//  Created by Chien, Arnold on 6/18/19.
//  Copyright © 2019 Chien, Arnold. All rights reserved.
//

import Foundation

public extension String {
    /**
     Given a C string, create a string.
     - Parameter cString: the C string.
     */
    init?(optionalCString cString: UnsafePointer<UnicodeCChar>?) {
        if let cString = cString {
            self.init(cString: cString)
        } else {
            return nil
        }
    }
}
