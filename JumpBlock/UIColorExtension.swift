//
//  UIColorExtension.swift
//  ios_game_test
//
//  Created by Weiheng Ni on 2014-12-17.
//  Copyright (c) 2014 whni. All rights reserved.
//

import UIKit

// Define some color generators
public extension UIColor {

    // Convert hex color to UIColor
    class func UIColorFromHex(hex: Int) -> UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class func UIColorFromHexString(str: String?) -> UIColor {
        if str == nil {
            UIColor.grayColor()
        }
        
        var hexString:String = str!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (hexString.hasPrefix("#")) {
            hexString = hexString.substringFromIndex(hexString.startIndex.advancedBy(1))
        }
        
        if (hexString.characters.count != 6) {
            return grayColor()
        }
        
        let rString = hexString.substringToIndex(hexString.startIndex.advancedBy(2))
        let gString = hexString.substringWithRange(Range(start: hexString.startIndex.advancedBy(2), end: hexString.startIndex.advancedBy(4)))
        let bString = hexString.substringWithRange(Range(start: hexString.startIndex.advancedBy(4), end: hexString.startIndex.advancedBy(6)))
        
        var red:CUnsignedInt = 0, green:CUnsignedInt = 0, blue:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&red)
        NSScanner(string: gString).scanHexInt(&green)
        NSScanner(string: bString).scanHexInt(&blue)
        
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    
    // Lighten color
    class func lightenUIColor(color: UIColor) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b / 0.6, alpha: a)
    }
    
    // Darken color
    class func darkenUIColor(color: UIColor) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.6, alpha: a)
    }
    
}

// Self-defined colors
struct UIColorPlatte {
    
    static let red600 = UIColor.UIColorFromHex(0xEA404E) //E53935
    static let red500 = UIColor.UIColorFromHex(0xF44336)
    static let pink200 = UIColor.UIColorFromHex(0xFCE4EC)
    
}


extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}