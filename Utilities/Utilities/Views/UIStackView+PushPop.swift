//
//  UIStackView+PushPop.swift
//  Utilities
//
//  Created by Brooks, Jon on 12/15/17.
//  Copyright © 2017 McGraw-Hill Education. All rights reserved.
//

import UIKit

public extension UIStackView {

    /**
     Remove the visually last subview in the stack view.
     */
    func removeLastSubview() {
        if let subview = arrangedSubviews.last {
            removeArrangedSubview(subview)
        }
    }
}
