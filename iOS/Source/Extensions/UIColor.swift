//
//  UIColor.swift
//  IAPKit
//
//  Copyright (c) 2018 Black Pixel.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit


// MARK: - Colors

extension UIColor {
    static let baseColor = UIColor.black
    static let labelColor = UIColor(red:0.13, green:0.11, blue:0.26, alpha:1.00)
    static let shadowColor = UIColor(red: 0.5411, green: 0.5647, blue: 0.6, alpha: 0.1)
    static let unselectedColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
    static let unselectedTitleColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00)
}



// MARK: - Helpers

extension UIColor {
    
    func darker(by value: CGFloat) -> UIColor? {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: max(r - value, 0.0),
                           green: max(g - value, 0.0),
                           blue: max(b - value, 0.0),
                           alpha: a)
        } else {
            return nil
        }
    }
}
