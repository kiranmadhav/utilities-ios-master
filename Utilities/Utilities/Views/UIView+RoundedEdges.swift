//
//  UIView+RoundedEdges.swift
//  Utilities
//

import UIKit

public extension UIView {

    /**
     Round the corners of the view using the given radius, adjusting the border to the given thickness and given color.
     - Parameter radius: determines degree of roundness.
     - Parameter borderThickness: the border thickness.
     - Parameter borderColor: the border color.
     - Parameter edges: the edges to round.  Unsupported pre-iOS 11.
     */
    func roundCornersWithRadius(_ radius: CGFloat, borderThickness: CGFloat, borderColor: UIColor?, corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) {
        layer.cornerRadius = radius
        clipsToBounds = true
        if let borderColor = borderColor, borderThickness > 0 {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderThickness
        }
        layer.maskedCorners = corners
    }

    /**
     Round the corners of the view creating side bubble effect, adjusting the border to the given thickness and given color.
     - Parameter borderThickness: the border thickness.
     - Parameter borderColor: the border color.

     NOTE: This algorithm tries to determine the height of the view by searching for the first constraint setting the `.height` property, and assumes its constant is the height of the view. There are many cases where this would not be true.
     */
    func roundCornersToCreateSideBubbles(_ borderThickness: CGFloat, borderColor: UIColor?) {
        // Layout the view's frame, incase it hasn't been.
        self.setNeedsLayout()
        var height: CGFloat = 0.0
        // See if there is a height constraint for this object, if so, that will assumed to be its height after the initial layout (see note above).
        // TODO: Find a way to consistently determine what the height actual is or will be
        if let constraint = self.constraints.first(where: { $0.firstAttribute == .height }) {
            height = constraint.constant
        }
        // If no constraints assigned a height.
        if height == 0.0 {
            height = self.frame.size.height // Then use the view's current frame instead.
        }
        
        roundCornersWithRadius(height/2.0, borderThickness: borderThickness, borderColor: borderColor)
    }
    
    /**
     Round the corners of the view selectively using the given radius.  newBounds parameter can be used if desired rect is pending a layout update.
     - Parameter corners: the corners to round.
     - Parameter radius: determines degree of roundness.
     - Parameter newBounds: bounds of the view to round.
     */
    func roundCorners(corners: UIRectCorner, radius: CGFloat, newBounds: CGRect? = nil) {
        let maskPath = UIBezierPath(roundedRect: newBounds ?? bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}
