//
//  UIView+ConstraintBased.swift
//  Utilities
//
//  Created by Brooks, Jon on 7/5/17.
//  Copyright © 2017 McGraw-Hill Education. All rights reserved.
//

import UIKit

public extension UIView {

    /**
     Create view to be based on layout constraints or not.
     - Parameter constraintBased: whether or not the view should be constraint based.
     */
    convenience init(constraintBased: Bool) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = !constraintBased
    }
}
