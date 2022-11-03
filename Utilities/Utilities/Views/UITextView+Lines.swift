//
//  UITextView+Lines.swift
//  Utilities
//
//  Created by Chien, Arnold on 2/12/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//

import UIKit

public extension UITextView {

    /**
     Determine the line rectangles containing the text of a text view.
     - Returns: the rects, ordered from top to bottom.
     */
    func lineRects() -> [CGRect] {
        var lines: [CGRect] = []
        var lineRange: NSRange = NSRange(location: 0, length: 0)
        var lastOriginY: CGFloat = -1.0
        var lineRect: CGRect
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        while lineRange.location < NSMaxRange(glyphRange) {
            lineRect = layoutManager.lineFragmentRect(forGlyphAt: lineRange.location, effectiveRange: &lineRange)
            if lineRect.minY > lastOriginY {
                lines.append(lineRect)
            }
            lastOriginY = lineRect.minY
            lineRange.location = NSMaxRange(lineRange)
        }
        return lines
    }

    /**
     Determine the bounding rectangles of the text in the given range.
     - Returns: the rects, ordered from top to bottom.
     */
    func boundingRects(forGlyphRange glyphRange: NSRange) -> [CGRect] {
        var rects: [CGRect] = []
        var glyphsLineRange: NSRange
        var currentLocation = glyphRange.location
        var currentLineStart = glyphRange.location
        var currentLineRect = layoutManager.lineFragmentRect(forGlyphAt: currentLocation, effectiveRange: nil)
        var currentY: CGFloat = currentLineRect.minY
        var updateCurrentY = false  // We could compute this with other variables, but this is clearer.
        while currentLocation < NSMaxRange(glyphRange) {
            if currentLineRect.minY > currentY {
                // We've gone to the next line, time to generate a bounding rect for the previous.
                glyphsLineRange = NSRange(location: currentLineStart, length: currentLocation - currentLineStart)
                rects.append(layoutManager.boundingRect(forGlyphRange: glyphsLineRange, in: textContainer))
                currentLineStart = currentLocation
                updateCurrentY = true
            }
            currentLocation += 1
            currentLineRect = layoutManager.lineFragmentRect(forGlyphAt: currentLocation, effectiveRange: nil)
            if updateCurrentY {
                currentY = currentLineRect.minY
                updateCurrentY = false
            }
        }
        // End of the range, get the last bounding rect.
        glyphsLineRange = NSRange(location: currentLineStart, length: currentLocation - currentLineStart)
        rects.append(layoutManager.boundingRect(forGlyphRange: glyphsLineRange, in: textContainer))
        return rects
    }
}
