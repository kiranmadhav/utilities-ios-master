//
//  String+Path.swift
//  Utilities
//
//  Created by jbrooks on 1/25/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

public extension String {

    /**
     Remove the last path component.
     - Returns: the resulting string.
     */
    func withLastPathComponentRemoved() -> String {
        let lastPathComponent = (self as NSString).lastPathComponent

        if let range = self.range(of: lastPathComponent, options: [.backwards]) {
            return replacingCharacters(in: range, with: "")
        }

        return self
    }

    /**
     Normalize the given path component.
     - Parameter path: the path component to normalize.
     - Returns: the resulting string.
     */
    func withNormalizedPathComponent(_ path: String) -> String {
        return ((self as NSString).appendingPathComponent(path) as NSString).standardizingPath
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    var stringByDeletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    var stringByDeletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }

    /**
     Append the given path component.
     - Parameter path: the path component to append.
     - Returns: the resulting string.
     */
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }

    /**
     Append the given path extension.
     - Parameter path: the path extension to append.
     - Returns: the resulting string.
     */
    func stringByAppendingPathExtension(ext: String) -> String? {
        return (self as NSString).appendingPathExtension(ext)
    }
}
