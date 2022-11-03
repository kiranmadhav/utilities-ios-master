//
//  String+JSON.swift
//  Utilities
//
//  Created by Ian Salkind on 3/13/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public extension String {

    /**
     Given an object that can be serialized into json (Dictionary, Array, String, etc), create a string of the json.
     - Parameter jsonObject: object.
     */
    init?(jsonObject: AnyObject) {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.fragmentsAllowed])
            self.init(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }

    // From: http://stackoverflow.com/questions/10675390/iphone-ios-how-to-serialize-save-uicolor-to-json-file
    /**
     Return the color for this string representation. Use in conjunction with UIColor.json_stringValue()
     - Returns: the color.
     */
    func json_color() -> UIColor? {
        let comps = components(separatedBy: ":")
        let colors = comps[1].components(separatedBy: ",")
        let count = colors.count
        var values = [CGFloat]()
        for i in 0..<count {
            //Convert the color string to a CGFloat.  Fallback to 0 if the string can't be converted
            let value = CGFloat(Float(colors[i]) ?? 0)
            values.append(value)
        }
        if comps[0] == "rgba" {
            return UIColor(red: values[0], green: values[1], blue: values[2], alpha: values[3])
        } else if comps[0] == "hsba" {
            return UIColor(hue: values[0], saturation: values[1], brightness: values[2], alpha: values[3])
        } else if comps[0] == "wa" {
            return UIColor(white: values[0], alpha: values[1])
        }

        NSLog("WARNING: unable to deserialize color %@", self)
        return nil
    }
}
