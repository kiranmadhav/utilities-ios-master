//
//  LoadingOverlay.swift
//  Utilities
//
//  Created by jbrooks on 9/23/15.
//  Copyright © 2015 MHE. All rights reserved.
//

import UIKit

open class LoadingOverlay: UIView {

    // MARK: - Overlay Constants
    //The overlay is initially just a black overlay, but after this many seconds, a spinner is presented
    static let pauseBeforeShowingSpinner = 0.0

    //If we show a spinner, it must stay shown for at least this many seconds before being dismissed
    static let minimumSpinnerDuration = 0.7

    static let fadeInDuration = 0.5
    static let fadeOutDuration = 0.5
    static let overlayAlpha: CGFloat = 0.6

    // MARK: - Initializers
    public required override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Implementation

    fileprivate var spinnerShowDate: Date?

    /**
     Functions as a class initializer and presents the overlay on the parent view
     - Parameter parentView: the parent view.
     - Parameter message: the message to display under the spinner.
     - Parameter animated: whether or not to animate the overlay opacity.
     - Parameter absoluteCenter: whether or not to center the overlay in the root view.
     - Parameter opaque: whether or not the loading view is fully opaque.
     - Returns: the overlay
     */
    open class func presentOnView(_ parentView: UIView, withMessage message: String? = nil, animated: Bool = false, absoluteCenter: Bool = true, opaque: Bool = false) -> Self {
        let overlayAlphaAmount = overlayAlpha
        let loadingView = self.init(frame: parentView.bounds)
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingView.alpha = 0.0
        loadingView.backgroundColor = opaque ? UIColor.darkGray : UIColor.black

        parentView.addSubview(loadingView)

        if animated {
            UIView.animate(withDuration: fadeInDuration, animations: {
                loadingView.alpha = opaque ? 1.0 : overlayAlphaAmount
            })
        } else {
            loadingView.alpha = opaque ? 1.0 : overlayAlphaAmount
        }

        DispatchQueue.delayed(pauseBeforeShowingSpinner) {
            let indicator = UIActivityIndicatorView(style: .whiteLarge)
            indicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]

            var viewForCenterIn: UIView = loadingView

            if absoluteCenter {
                viewForCenterIn = parentView.window?.rootViewController?.view ?? loadingView
            }

            indicator.center = loadingView.convert(viewForCenterIn.center, from: viewForCenterIn.superview)

            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            loadingView.addSubview(indicator)
            loadingView.spinnerShowDate = Date()
            
            if let message = message {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
                
                label.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                label.text = message
                
                label.sizeToFit()
                
                var newCenter = indicator.center
                
                newCenter.y += (indicator.frame.size.height / 2.0) + 20
                
                label.center = newCenter
                label.textAlignment = .center
                loadingView.addSubview(label)
            }

        }

        return loadingView
    }

    //Note: This method might not dismiss the view immediately.  It ensures that if a spinner is shown
    //the spinner is at least shown for minimumSpinnerDuration seconds
    open func dismiss() {
        var dismissInterval: TimeInterval = 0

        if let spinnerHideDate = spinnerShowDate?.addingTimeInterval(LoadingOverlay.minimumSpinnerDuration) {
            dismissInterval = max(spinnerHideDate.timeIntervalSince(Date()), 0)
        }

        DispatchQueue.delayed(dismissInterval) {
            if self.subviews.count == 1 {
                if let indicator = self.subviews[0] as? UIActivityIndicatorView {
                    indicator.stopAnimating()
                }
            }

            UIView.animate(withDuration: LoadingOverlay.fadeOutDuration, animations: {
                self.alpha = 0.0; return
                }, completion: { (_) in
                    self.removeFromSuperview()
            })

        }
    }
}
