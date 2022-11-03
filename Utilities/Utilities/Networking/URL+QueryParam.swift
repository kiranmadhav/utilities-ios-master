//
//  URL+QueryParam.swift
//  Utilities
//
//  Created by jbrooks on 3/27/17.
//  Copyright © 2017 MHE. All rights reserved.
//

import Foundation

public extension URL {

    /**
     Returns the query component of a url string.
     - Parameter name: the url string.
     - Returns: the query string.
     */
    func queryParam(withName name: String) -> String? {
        let comps = URLComponents(url: self, resolvingAgainstBaseURL: false)

        let queryItem = comps?.queryItems?.first { $0.name == name }

        return queryItem?.value
    }

    /**
     Returns a url with the given query params added.
     - Parameter params: a dictionary of parameter key-value pairs.
     - Returns: the url.
     */
    func withQueryParams(_ params: [String: String]) -> URL? {
        guard let inputComps = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        var components = inputComps
        
        components.queryItems = params.map { (key, value) in
            return URLQueryItem(name: key, value: value)
        }
        
        return components.url
    }
}
