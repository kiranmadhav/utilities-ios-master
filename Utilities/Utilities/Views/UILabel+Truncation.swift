//
//  UILabel+Truncation.swift
//  Utilities
//
//  Created by Beyer, Zachary on 1/30/20.
//  Copyright © 2020 MHE. All rights reserved.
//

import UIKit

public extension UILabel {
    /**
     Bool Returns true if the `numberOfLines` argument is causing the `UILabel` to truncate text
     - Returns: true or false if `systemLayoutSize` is affected by current `numberOfLines`
     */
    var isTruncated: Bool {
        let origNumLines = numberOfLines
        guard origNumLines != 0 else {
            return false
        }
        let truncatedSize = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        numberOfLines = 0
        let fullSize = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        numberOfLines = origNumLines

        return fullSize.height > truncatedSize.height
    }
}
