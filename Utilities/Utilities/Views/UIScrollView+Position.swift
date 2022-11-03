//
//  UIScrollView+Position.swift
//  Utilities
//
//  Created by jbrooks on 2/2/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public extension UIScrollView {
    var maxYOffset: CGFloat {
        return max(contentSize.height - frame.height, 0)
    }

    func setToMaxOffset() {
        let newOffset = CGPoint(x: contentOffset.x, y: maxYOffset)

        if newOffset != contentOffset {
            contentOffset = newOffset
        }
    }

    var pctScrolled: CGFloat {
        return (maxYOffset == 0) ? 0 : contentOffset.y / maxYOffset
    }

    var verticalOffsetForTop: CGFloat {
        return -contentInset.top
    }

    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.size.height
        let contentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom

        return contentSizeHeight + bottomInset - scrollViewHeight
    }

    var isPastTop: Bool {
        return Int(round(contentOffset.y)) < Int(round(verticalOffsetForTop))
    }

    var isAtBottom: Bool {
        return Int(round(contentOffset.y)) >= Int(round(verticalOffsetForBottom))
    }

    var contentRect: CGRect {
        var offset = contentOffset
        offset.y = -offset.y

        let contentOrigin = offset + CGPoint(x: contentInset.left, y: contentInset.top)

        return CGRect(origin: contentOrigin, size: contentSize)
    }
}
