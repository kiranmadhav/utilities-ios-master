//
//  UIButton+Alignment.swift
//  Utilities
//
//  Created by Chien, Arnold on 11/21/18.
//  Copyright © 2018 McGraw-Hill Education. All rights reserved.
//

import UIKit

public extension UIButton {
    
    /**
     Set the button image centered with title underneath, using vertical padding.
     - Parameter image: the image.
     - Parameter title: the title.
     - Parameter padding: the padding.
     */
    func set(withImage image: UIImage?, andTitle title: String, padding: CGFloat = 2.0) {
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        guard  let imageSize = self.imageView?.frame.size,
            let labelSize = self.titleLabel?.frame.size,
            let titleSize = self.titleLabel?.sizeThatFits(labelSize) else {
                return
        }
        let totalHeight = imageSize.height + titleSize.height + padding
        imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
}

// Another approach, from https://stackoverflow.com/questions/4201959/label-under-image-in-uibutton

open class CenteredButton: UIButton {
    public var padding: CGFloat = 5
    
    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)

        return CGRect(x: 0, y: contentRect.height - rect.height + padding,
            width: contentRect.width, height: rect.height)
    }

    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)

        return CGRect(x: contentRect.width/2.0 - rect.width/2.0,
            y: (contentRect.height - titleRect.height)/2.0 - rect.height/2.0,
            width: rect.width, height: rect.height)
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize

        if let image = imageView?.image {
            var labelHeight: CGFloat = 0.0

            if let size = titleLabel?.sizeThatFits(CGSize(width: self.contentRect(forBounds: self.bounds).width, height: CGFloat.greatestFiniteMagnitude)) {
                labelHeight = size.height
            }

            return CGSize(width: size.width, height: image.size.height + labelHeight + 5)
        }

        return size
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }

    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .center
    }
}
