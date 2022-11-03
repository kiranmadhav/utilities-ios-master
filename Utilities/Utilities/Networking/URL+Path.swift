//
//  URL+Path.swift
//  Utilities
//
//  Created by jbrooks on 1/29/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

public extension URL {
    /**
     Returns new url with given path appended to the receiver, preserving any fragment on `path`.
     - Parameter path: the path to append.
     - Returns: the new url.
     */
    func withAppendedURLString(_ path: String) -> URL? {
        guard let baseComponents = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let inputComps = URLComponents(string: path) else {
                return nil
        }
        let appendTrailingSlash = path.hasSuffix("/")
        var newComponents = inputComps

        let pathComponents = baseComponents.path.split(separator: "/") +
                             newComponents.path.split(separator: "/")

        var newPath = "/" + pathComponents.joined(separator: "/")
        if appendTrailingSlash {
            newPath.append(contentsOf: "/")
        }
        newComponents.path = newPath
        newComponents.scheme = baseComponents.scheme
        newComponents.host = baseComponents.host
        newComponents.port = baseComponents.port

        return newComponents.url
    }


}
