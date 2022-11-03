//
//  UIImage+Combine.swift
//  Utilities
//
//  Created by jbrooks on 1/25/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public extension UIImage {
    /**
     Combine two images by drawing both from common origin in a new context.
     - Parameter firstImage: the first image.
     - Parameter secondImage: the second image.
     - Returns: The combined image.
     */
    class func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage? {
        let newImageWidth  = max(firstImage.size.width, secondImage.size.width )
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width: newImageWidth, height: newImageHeight)
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        firstImage.draw(at: .zero)
        secondImage.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
