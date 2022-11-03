//
//  UIView+Constraints.swift
//  Utilities
//
//  Created by kurtu on 12/22/15.
//

import UIKit

public extension NSLayoutConstraint {
    convenience init(view: UIView, atHeight: CGFloat) {
        self.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: atHeight)
    }
    
    // It may have been the intention for this and following functions to be internal, as implementing the public interfaces in the UIView extension below.
    // But there is client code that calls this directly (and same for constraintsEqualSuperviewSize).  I've chosen to to enable this code by making this function public, and for consistency I've made the others in this extension as well.  If we wish alternatively to rewrite the client code and restore internal access for these functions, we can revisit.
    class func constraintsEqualSuperviewWidth(_ view: UIView) -> [NSLayoutConstraint] {
        let views: [String: AnyObject] = ["view": view]
        
        return self.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views)
    }
    
    class func constraintForEqualWidths(_ view1: UIView, view2: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view1,
                                  attribute: .width,
                                  relatedBy: .equal,
                                  toItem: view2,
                                  attribute: .width,
                                  multiplier: 1.0,
                                  constant: 0)
    }
    
    class func constraintForEqualHeights(_ view1: UIView, view2: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view1,
                                  attribute: .height,
                                  relatedBy: .equal,
                                  toItem: view2,
                                  attribute: .height,
                                  multiplier: 1.0,
                                  constant: 0)
    }
    
    class func constraintsEqualSuperviewHeight(_ view: UIView) -> [NSLayoutConstraint] {
        let views: [String: AnyObject] = ["view": view]
        
        return self.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views)
    }
    
    class func constraintsEqualSuperviewSize(_ view: UIView) -> [NSLayoutConstraint] {
        return constraintsEqualSuperviewWidth(view) + constraintsEqualSuperviewHeight(view)
    }
    
    class func constraintsForVerticalStack(_ views: [AnyObject]) -> [NSLayoutConstraint] {
        
        var viewDict: [String: AnyObject] = [:]
        var visualFormatString = "V:"
        
        for i in 0..<views.count {
            let viewKey = "v\(i)"
            
            viewDict[viewKey] = views[i]
            
            visualFormatString += "[\(viewKey)]"
            
        }
        
        return NSLayoutConstraint.constraints(withVisualFormat: visualFormatString, options: [], metrics: nil, views: viewDict)
    }
    
}

public extension UIView {
    /**
     Constrains the view to the superview's size and activates it.
     - Returns: The constraint.
     */
    func constrainToSuperview() {
        let constraints = NSLayoutConstraint.constraintsEqualSuperviewSize(self)
        NSLayoutConstraint.activate(constraints)
    }
    
    /**
     Constrains the view to the superview's width and activates it.
     - Returns: The constraint.
     */
    func constrainToSuperviewWidth() {
        let constraints = NSLayoutConstraint.constraintsEqualSuperviewWidth(self)
        NSLayoutConstraint.activate(constraints)
    }
    
    /**
     Constrains the view to the superview's height and activates it.
     - Returns: The constraint.
     */
    func constrainToSuperviewHeight() {
        let constraints = NSLayoutConstraint.constraintsEqualSuperviewHeight(self)
        NSLayoutConstraint.activate(constraints)
    }
    
    /**
     Constrains the view to the height provided and activates it
     - Parameter height: the height to constrain to
     - Parameter multiplier: proportion of the other view's height. Default is 1
     - Returns: The constraint.
     */
    @discardableResult
    func constrain(height: CGFloat, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: multiplier,
                                            constant: height)
        
        constraint.isActive = true
        
        return constraint
    }
    
    /**
     Constrains the view to the width provided and activates it
     - Parameter width: the width to constrain to
     - Parameter multiplier: proportion of the other view's width. Default is 1
     - Returns: The constraint.
     */
    @discardableResult
    func constrain(width: CGFloat, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: multiplier,
                                            constant: width)
        
        constraint.isActive = true
        
        return constraint
    }
    
    /**
     Creates a constraint that locks the view to another view's width and activates it.
     - Parameter toView: view to constrain to
     - Parameter multiplier: proportion of the other view's width. Default is 1
     - Parameter constant: width offset. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainEqualWidth(toView otherView: UIView, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: constant)
        constraint.isActive = true
        
        return constraint
    }
    
    /**
     Creates a constraint that lock the view to another view's height and activates it.
     - Parameter toView: view to constrain to
     - Parameter multiplier: proportion of the other view's height. Default is 1
     - Parameter constant: height offset. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainEqualHeight(toView otherView: UIView, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: .height,
                                            multiplier: multiplier,
                                            constant: constant)
        constraint.isActive = true
        
        return constraint
    }
    
    /**
     Creates constraints that lock the view's edges to its superview's edges with a 0 constant and activates them. Does nothing if the superview is nil.
     - Parameter margin: how many pts the subview should be away. Default is 0
     - Returns: Array of the constraints.
     */
    @discardableResult
    func constrainToSuperviewEdges(margin: CGFloat = 0) -> [NSLayoutConstraint]? {
        if superview != nil {
            return [constrainToSuperviewEdge(edge: .top, margin: margin)!,
                    constrainToSuperviewEdge(edge: .bottom, margin: margin)!,
                    constrainToSuperviewEdge(edge: .leading, margin: margin)!,
                    constrainToSuperviewEdge(edge: .trailing, margin: margin)!]
        }
        return nil
    }

    /**
     Creates a constraint that locks the view's edge to its superview's edge with the provided margin (or 0 if no margin is provided) and activates it. Does nothing if the superview is nil.
     - Parameter edge: NSLayoutAttribute to constrain to
     - Parameter margin: how many pts the subview should be away. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainToSuperviewEdge(edge edgeAttribute: NSLayoutConstraint.Attribute, margin: CGFloat = 0) -> NSLayoutConstraint? {
        if let superview = superview {
            return constrainEdge(edge: edgeAttribute, toOtherView: superview, otherViewEdge: edgeAttribute, margin: margin)
        }
        return nil
    }
    
    /**
     Creates a constraint that locks the view's edge to its superview's bottom. Does nothing if the superview is nil.
     - Parameter margin: how many pts the subview should be away. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainToSuperviewBottom(margin: CGFloat = 0) -> NSLayoutConstraint? {
        if superview != nil {
            let constraint = NSLayoutConstraint(item: self,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: superview,
                                                attribute: .bottom,
                                                multiplier: 1.0,
                                                constant: margin)
            constraint.isActive = true
        }
        return nil
    }

    /**
     Creates a constraint that locks the view's supplied edge to another view's supplied edge with the provided margin (or 0 if no margin is provided) and activates it.
     - Parameter edge: NSLayoutAttribute to constrain to
     - Parameter toOtherView: view to constrain to
     - Parameter otherViewEdge: the edge attribute on otherView to constrain to
     - Parameter margin: how many pts the subview should be away. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainEdge(edge edgeAttribute: NSLayoutConstraint.Attribute, toOtherView otherView: UIView, otherViewEdge otherViewAttribute: NSLayoutConstraint.Attribute, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: edgeAttribute,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: otherViewAttribute,
                                            multiplier: 1.0,
                                            constant: margin)

        constraint.isActive = true

        return constraint
    }

    /**
     Creates a constraint that locks the view to another view's vertical center and activates it.
     - Parameter view: view to constrain to
     - Parameter multiplier: proportion of the other view's horizontal center. Default is 1
     - Parameter constant: offset from horizontal center. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainToHorizontalCenter(_ otherView: UIView, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: .centerX,
                                            multiplier: multiplier,
                                            constant: constant)

        constraint.isActive = true

        return constraint
    }
    
    /**
     Creates a constraint that locks the view to another view's vertical center and activates it.
     - Parameter view: view to constrain to
     - Parameter multiplier: proportion of the other view's vertical center. Default is 1
     - Parameter constant: offset from vertical center. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainToVerticalCenter(_ otherView: UIView, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: .centerY,
                                            multiplier: multiplier,
                                            constant: constant)
        
        constraint.isActive = true
        
        return constraint
    }

    /**
     Creates a constraint that lock the view to its superview's vertical center and activates it. Does nothing if the superview is nil.
     - Parameter multiplier: proportion of the superview's vertical center. Default is 1
     - Parameter constant: offset from the superview's vertical center. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainToSuperviewVerticalCenter(multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint? {
        if let superview = superview {
            return constrainToVerticalCenter(superview, multiplier: multiplier, constant: constant)
        }
        return nil
    }
    
    /**
     Creates a constraint that lock the view to its superview's horizontal center and activates it. Does nothing if the superview is nil.
     - Parameter multiplier: proportion of the superview's horizontal center. Default is 1
     - Parameter constant: offset from the superview's horizontal center. Default is 0
     - Returns: The constraint.
     */
    @discardableResult
    func constrainToSuperviewHorizontalCenter(multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint? {
        if let superview = superview {
            let constraint = NSLayoutConstraint(item: self,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: superview,
                                                attribute: .centerX,
                                                multiplier: multiplier,
                                                constant: constant)
            
            constraint.isActive = true
            return constraint
        }
        return nil
    }
    
    /**
     Creates constraints that lock the view to its superview's center and activates them. Does nothing if the superview is nil.
     - Returns: The constraints.
     */
    @discardableResult
    func constrainToSuperviewCenter() -> [NSLayoutConstraint]? {
        var constraints: [NSLayoutConstraint] = []
        if superview != nil {
            constraints.append(constrainToSuperviewHorizontalCenter()!)
            constraints.append(constrainToSuperviewVerticalCenter()!)
            return constraints
        }
        return nil
    }

    /**
     Creates a constraint that lock the view to another view's size and activates it.
     - Parameter toView: view to constrain to
     - Returns: The constraint.
     */
    @discardableResult
    func constrainEqualSize(toView otherView: UIView) -> [NSLayoutConstraint] {
        return [constrainEqualWidth(toView: otherView), constrainEqualHeight(toView: otherView)]
    }
    
    
    /**
     Creates a constraint that sizes the view to the aspect ratio defined by the given size activates it.
     - Parameter size: size defining the aspect ratio.
     - Returns: The constraint.
     */
    @discardableResult
    func constrainToAspectRatio(_ size: CGSize) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .height,
                                            multiplier: size.width/size.height,
                                            constant: 1.0)
        constraint.isActive = true
        
        return constraint
    }
}
