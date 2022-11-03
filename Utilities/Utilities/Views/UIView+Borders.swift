//
//  UIView+Borders.swift
//  Utilities
//
//  Created by Brooks, Jon on 3/30/18.
//  Copyright © 2018 MHE. All rights reserved.
//

import UIKit

//From https://stackoverflow.com/questions/17355280/how-to-add-a-border-just-on-the-top-side-of-a-uiview
public extension UIView {

    /**
     Add borders at the given edges with the given color and given thickness.  Note: This adds views to the view.  Calling this over and over again will continue to add views.  Clients should take care to track and remove added views via the returned array if they plan on calling this method more than once.
     - Parameter edges: the edges.
     - Parameter color: the color.
     - Parameter thickness: the thickness.
     - Parameter inset: the amount to inset the border from the edge of the view
     - Returns: the borders.
     */
    @discardableResult
    func addBorders(edges: UIRectEdge, color: UIColor = .black, thickness: CGFloat = 1.0, inset: CGFloat = 0.0) -> [UIView] {

        var borders = [UIView]()
        var constraints: [NSLayoutConstraint] = []

        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }

        let metrics = [
            "inset": inset,
            "thickness": thickness
        ]

        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(inset)-[top(==thickness)]",
                                               options: [],
                                               metrics: metrics,
                                               views: ["top": top]))
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(inset)-[top]-(inset)-|",
                                               options: [],
                                               metrics: metrics,
                                               views: ["top": top]))
            borders.append(top)
        }

        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(inset)-[left(==thickness)]",
                                               options: [],
                                               metrics: metrics,
                                               views: ["left": left]))
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(inset)-[left]-(inset)-|",
                                               options: [],
                                               metrics: metrics,
                                               views: ["left": left]))
            borders.append(left)
        }

        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)

            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(inset)-|",
                                               options: [],
                                               metrics: metrics,
                                               views: ["right": right]))
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(inset)-[right]-(inset)-|",
                                               options: [],
                                               metrics: metrics,
                                               views: ["right": right]))
            borders.append(right)
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(inset)-|",
                                               options: [],
                                               metrics: metrics,
                                               views: ["bottom": bottom]))
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(inset)-[bottom]-(inset)-|",
                                               options: [],
                                               metrics: metrics,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        NSLayoutConstraint.activate(constraints)

        return borders
    }
}
