//
//  GradientScrollView.swift
//  Utilities
//
//  Created by Brooks, Jon on 7/31/18.
//  Copyright © 2018 mhe. All rights reserved.
//

import UIKit

// A scroll view whose content starts to gradually dim as the bottom is approached.
open class GradientScrollView: UIScrollView {
    func addGradientMask() {
        let gradientMask = CAGradientLayer()

        gradientMask.frame = bounds

        //At what percentage of viewHeight does the fade gradient start
        let fadeBegin: CGFloat = 0.75

        //What percentage of viewHeight does it take to get to fully transparent (starting from fadeBegin)
        let fadeLength: CGFloat = 0.20

        let fadeEnd = fadeBegin + fadeLength

        gradientMask.locations = [
            NSNumber(value: Float(fadeBegin)),
            NSNumber(value: Float(fadeEnd))
        ]

        //As we near the bottom of the content, we gradually fade out the gradient by making the final color closer and closer to full alpha
        let viewHeight = bounds.height
        let fadeHeight = viewHeight * (1 - fadeBegin)
        let amountOfContentOffscreen = contentSize.height - (contentOffset.y + viewHeight)
        var finalAlpha: CGFloat = 0
        if amountOfContentOffscreen < fadeHeight, fadeHeight != 0 {
            finalAlpha = 1 - (amountOfContentOffscreen / fadeHeight)
        }

        let finalGradientColor = UIColor.black.withAlphaComponent(finalAlpha).cgColor

        gradientMask.colors = [UIColor.black.cgColor, finalGradientColor]

        let maskView = UIView()
        maskView.layer.addSublayer(gradientMask)

        mask = maskView
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        addGradientMask()
    }
}
