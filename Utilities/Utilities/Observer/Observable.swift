//
//  Observable.swift
//  Utilities
//
//  Created by kurtu on 3/2/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

public protocol Observable {
    associatedtype T
    func addObserver(_ observer: T)
    func removeObserver(_ observer: T)
}
