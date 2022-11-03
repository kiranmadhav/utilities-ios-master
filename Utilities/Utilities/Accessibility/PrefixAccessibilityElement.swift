//
//  PrefixAccessibilityElement.swift
//  Utilities
//
//  Created by Brooks, Jon on 3/15/18.
//  Copyright © 2018 mhe. All rights reserved.
//

import UIKit
import CoreGraphics

/// This class provides a way to prefix an existing accessibility element with
/// another one that will always appear just before the existing one.
open class PrefixAccessibilityElement: UIAccessibilityElement {
    public weak var otherElement: NSObject?

    /**
     Designated initializer
     - Parameter accessibilityContainer: typically the same accessibility container that contains pairedElement.
     - Parameter pairedElement: the accessibility element that this element should precede.  It is typically either a UIView subclass or a UIAccessibilityElement instance, but the `UIAccessibilityElement` informal protocol allows for any `NSObject` to be an accessibilityElement.
     - Returns: the accessibilityElement.
     */
    public required init(accessibilityContainer container: Any, pairedElement: NSObject) {
        super.init(accessibilityContainer: container)
        otherElement = pairedElement
        isAccessibilityElement = true
    }

    open override var accessibilityFrame: CGRect {
        get {
            var thisFrame = otherElement?.accessibilityFrame ?? CGRect.zero

            if thisFrame == .zero, let otherView = otherElement as? UIView {
                thisFrame = UIAccessibility.convertToScreenCoordinates(otherView.bounds, in: otherView)
            }

            thisFrame.origin.x -= 1
            thisFrame.size.width = 1

            return thisFrame
        }
        //swiftlint:disable:next unused_setter_value
        set {
            // ignore it
        }
    }
}
