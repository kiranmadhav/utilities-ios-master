//
//  AccessibilitySwitchable.swift
//  Utilities
//
//  Created by kurtu on 9/27/17.
//  Copyright © 2017 mhe. All rights reserved.
//

import Foundation

public protocol AccessibilitySwitchable: AnyObject {
    var accessibilityEnabled: Bool { get set }
}
