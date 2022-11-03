//
//  UIImage+Colors.m
//  Utilities
//
//  Created by Ian Salkind on 3/10/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

extension UIImage {

    /**
     Creates an image of the given color.  Useful for setting the background image of a UIButton (as a workaround to not being able to set the background color).
     - Parameter color: image color.
     - Parameter size: image size.
     - Parameter round: true for an elliptical image, false for rectangular.
     - Parameter borderThickness: line thickness.
     - Parameter borderColor: line color.
     */
    public convenience init?(
        color: UIColor,
        size: CGSize = CGSize(width: 1, height: 1),
        round: Bool = false,
        borderThickness: CGFloat? = nil,
        borderColor: UIColor? = nil) {
        
        let scale = UIScreen.main.scale
        
        var image: UIImage?
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let isOpaque = !round //If we're round, we want transparency in the corners
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
        if let context = UIGraphicsGetCurrentContext() {
            
            if round {
                context.addEllipse(in: rect)
                context.clip()
                context.addEllipse(in: rect)
            } else {
                context.addRect(rect)
            }
            
            context.setFillColor(color.cgColor)
            context.fillPath()
            
            if let borderColor = borderColor, let borderThickness = borderThickness {
                if round {
                    context.addEllipse(in: rect)
                } else {
                    context.addRect(rect)
                }
                
                context.setStrokeColor(borderColor.cgColor)
                context.setLineWidth(borderThickness)
                context.strokePath()
            }
            
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        UIGraphicsEndImageContext()
        
        if let cgImage = image?.cgImage {
            self.init(cgImage: cgImage, scale: scale, orientation: .up)
        } else {
            return nil
        }
        
    }
    
    public func asMaskColored(_ color: UIColor) -> UIImage? {
        
        var ret: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        if let cgImage = self.cgImage,
            let context = UIGraphicsGetCurrentContext() {
            color.setFill()
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            ret = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        
        return ret
    }


    private func determineColors(at dimension: CGFloat) -> [[Int]] {
        var colors = [[Int]]()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let size = Int(dimension * dimension) * 4
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let buffer = UnsafeMutableBufferPointer(start: data, count: size)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(dimension)
        let bitsPerComponent = 8

        guard
            let context = CGContext(
                data: data,
                width: Int(dimension),
                height: Int(dimension),
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ),
            let imageRef = self.cgImage
            else {
                return []
        }

        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: dimension, height: dimension))

        for offset in stride(from: buffer.startIndex, to: buffer.endIndex, by: 4) {
            let red = Int(buffer[offset])
            let green = Int(buffer[offset + 1])
            let blue = Int(buffer[offset + 2])
            let alpha = Int(buffer[offset + 3])
            let a = [red, green, blue, alpha]
            colors.append(a)
        }

        data.deallocate()

        return colors
    }

    private func addFlexibility(with colors: [[Int]], at flexibility: Float, withDimension dimension: CGFloat) -> [String] {
        let copyColours = [[Int]](colors)
        var flexibleColors = [String]()
        let flexFactor: Float = flexibility * 2 + 1
        let factor: Float = flexFactor * flexFactor * 3
        //(r,g,b) == *3
        for n in 0..<Int(dimension * dimension) {
            let pixelColours = copyColours[n]
            var reds = [Int]()
            var greens = [Int]()
            var blues = [Int]()
            for p in 0..<3 {
                let rgbVal = pixelColours[p]
                for f in Int(-flexibility)..<Int(flexibility + 1) {
                    var newRGB = rgbVal + f
                    if newRGB < 0 {
                        newRGB = 0
                    }
                    if p == 0 {
                        reds.append(newRGB)
                    } else if p == 1 {
                        greens.append(newRGB)
                    } else if p == 2 {
                        blues.append(newRGB)
                    }
                }
            }
            var r: Int = 0
            var g: Int = 0
            var b: Int = 0
            for _ in 0..<Int(factor) {
                let red = reds[r]
                let green = greens[g]
                let blue = blues[b]
                let rgbString = "\(red),\(green),\(blue)"
                flexibleColors.append(rgbString)
                b += 1
                if b == Int(flexFactor) {
                    b = 0
                    g += 1
                }
                if g == Int(flexFactor) {
                    g = 0
                    r += 1
                }
            }
        }

        return flexibleColors
    }

    //
    // From: http://stackoverflow.com/questions/13694618/objective-c-getting-least-used-and-most-used-color-in-a-image
    //

    //
    // Compute information about the colors in the image. Return a tuple containing an
    // ordered list of colors (most to least) and a dictionary containing a count of colors.
    //
    private func processColors(detail: Int, withAlpha alpha: CGFloat) -> ([String], [String: Int]) {
        //1. determine detail vars (0==low,1==default,2==high)
        //default detail
        var dimension: CGFloat = 10
        var flexibility: Float = 2
        var range: Float = 60
        //low detail
        if detail == 0 {
            dimension = 4
            flexibility = 1
            range = 100
            //high detail (patience!)
        } else if detail == 2 {
            dimension = 100
            flexibility = 10
            range = 20
        }

        //2. determine the colours in the image
        let colors = determineColors(at: dimension)

        //3. add some colour flexibility (adds more colours either side of the colours in the image)
        let flexibleColours = addFlexibility(with: colors, at: flexibility, withDimension: dimension)

        //4. distinguish the colours
        //orders the flexible colours by their occurrence
        //then keeps them if they are sufficiently disimilar
        var colourCounter = [String: Int]()
        //count the occurences in the array
        let countedSet = Bag(flexibleColours)
        for (item, count) in countedSet {
            colourCounter[item] = count
        }

        //sort keys highest occurrence to lowest
        let orderedKeys = colourCounter
            .sorted { $0.value > $1.value }
            .map { $0.key }

        //checks if the colour is similar to another one already included
        var ranges = [String]()
        for key: String in orderedKeys {
            let rgb = key.components(separatedBy: ",")
            let r = Int(rgb[0])!
            let g = Int(rgb[1])!
            let b = Int(rgb[2])!
            var exclude: Bool = false
            for ranged_key: String in ranges {
                let ranged_rgb = ranged_key.components(separatedBy: ",")
                let ranged_r = Int(ranged_rgb[0])!
                let ranged_g = Int(ranged_rgb[1])!
                let ranged_b = Int(ranged_rgb[2])!
                if r >= ranged_r - Int(range) && r <= ranged_r + Int(range) {
                    if g >= ranged_g - Int(range) && g <= ranged_g + Int(range) {
                        if b >= ranged_b - Int(range) && b <= ranged_b + Int(range) {
                            exclude = true
                        }
                    }
                }
            }
            if !exclude {
                ranges.append(key)
            }
        }

        return (ranges, colourCounter)
    }

    //
    // Return a list of sufficiently disimilar colors that make up the
    // image. Sorted for most to least common color.
    //
    public func colors(atDetailLevel detail: Int, withAlpha alpha: CGFloat = 1.0) -> [UIColor] {
        let (ranges, _) = processColors(detail: detail, withAlpha: alpha)

        //return ranges array here if you just want the ordered colours high to low
        var colourArray = [UIColor]()
        for key: String in ranges {
            let rgb = key.components(separatedBy: ",")
            let r = Int(rgb[0])!
            let g = Int(rgb[1])!
            let b = Int(rgb[2])!
            let colour: UIColor = UIColor(red: (CGFloat(r) / CGFloat(255.0)), green: (CGFloat(g) / CGFloat(255.0)), blue: (CGFloat(b) / CGFloat(255.0)), alpha: alpha)
            colourArray.append(colour)
        }
        //if you just want an array of images of most common to least, return here
        return colourArray
    }

    //
    // Return a dictionary of sufficiently disimilary colors that make up the image and
    // include the percent usage.
    //
    public func colorPercentsAtDetailLevel(_ detail: Int, withAlpha alpha: CGFloat = 1.0) -> [NSObject: AnyObject] {
        let (ranges, colourCounter) = processColors(detail: detail, withAlpha: alpha)

        //if you want percentages to colours continue below
        var temp = [String: Int]()
        var totalCount: Float = 0.0
        for rangeKey: String in ranges {
            let count = colourCounter[rangeKey]!
            totalCount += Float(count)
            temp[rangeKey] = count
        }
        //set percentages
        var colourDictionary = [UIColor: Int]()
        for (key, count) in temp {
            let percentage: Float = Float(count) / totalCount
            let rgb = key.components(separatedBy: ",")
            let r = Int(rgb[0])!
            let g = Int(rgb[1])!
            let b = Int(rgb[2])!
            let colour: UIColor = UIColor(red: (CGFloat(r) / CGFloat(255.0)), green: (CGFloat(g) / CGFloat(255.0)), blue: (CGFloat(b) / CGFloat(255.0)), alpha: alpha)
            colourDictionary[colour] = Int(percentage)
        }

        return colourDictionary as [NSObject: AnyObject]
    }

    //
    // From: http://stackoverflow.com/questions/1354811/how-can-i-take-an-uiimage-and-give-it-a-black-border
    //

    //
    // Add a (white) border to the image
    //
    public func addBorder(_ color: UIColor.RGBATuple) -> UIImage {
        let size = self.size
        UIGraphicsBeginImageContext(size)
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.draw(in: rect, blendMode: .normal, alpha: 1.0)
        var finalImage: UIImage?

        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(3.0)
            context.setStrokeColor(red: color.r, green: color.g, blue: color.b, alpha: color.a)
            context.stroke(rect)
            finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        return finalImage ?? self
    }
    
}
