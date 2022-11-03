//
//  UTF8CString.swift
//  Utilities
//
//  Created by jbrooks on 1/25/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

public typealias UnicodeCChar = CChar
public typealias CStringPointer = UnsafePointer<UnicodeCChar>
public typealias UTF8CString = ContiguousArray<UnicodeCChar>
