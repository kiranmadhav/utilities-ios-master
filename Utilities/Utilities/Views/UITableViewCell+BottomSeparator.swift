//
//  UITableViewCell+bottomSeperator.swift
//  Utilities
//
//  Created by Arum_Kumar on 10/24/18.
//  Copyright © 2018 MHE. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    /**
     Add a bottom separator to the table view cell.
     - Parameter color: color of the separator.
     */
    func addBottomSeparator(color: UIColor) {
        let additionalSeparator = UIView(constraintBased: true)
        additionalSeparator.backgroundColor = color
        addSubview(additionalSeparator)
        additionalSeparator.constrainToSuperviewWidth()
        additionalSeparator.constrain(height: 1)
        additionalSeparator.constrainToSuperviewBottom()
    }
}
