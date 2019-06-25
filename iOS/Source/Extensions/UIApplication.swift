//
//  UIApplication.swift
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

extension UIApplication {
    
    enum FuzzySplitScreenWidth {
        case oneThird
        case oneHalf
        case twoThirds
        case full
    }
    
    /// Approximates the current size of the overall app view relative to the window width.
    static func splitScreenWidth() -> FuzzySplitScreenWidth {
        let windowWidth = UIApplication.shared.keyWindow!.bounds.size.width
        let screenWidth = UIScreen.main.bounds.size.width
        
        guard windowWidth > 0, screenWidth > 0 else {
            return .full
        }        
        
        switch windowWidth / screenWidth {
        case 0.0..<0.42:
            return .oneThird
            
        case 0.42..<0.6:
            return .oneHalf
            
        case 0.6..<1.0:
            return .twoThirds
            
        default:
            return .full
        }
    }
    
    static func isMultitasking() -> Bool {
        let screenBounds = UIScreen.main.bounds
        let windowBounds = UIApplication.shared.keyWindow?.bounds
        
        return screenBounds != windowBounds
    }
    
    static func isLandscape() -> Bool {
        // Use the status bar orientation as it has proven to be a more reliable way to get the orientation for this purpose.
        // Using UIDevice orientation won't work if the device is in face up for face down orientation.
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation.isLandscape {
            return true
        }
        else if orientation.isPortrait {
            return false
        }
        else {
            assertionFailure()
            return false
        }
    }
    
    static func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func isiPhone5() -> Bool {
        return !isIPad() && UIScreen.main.nativeBounds.height <= 1136
    }
    
    static func isIPadPro12_9() -> Bool {
        let mainScreen = UIScreen.main
        let size = mainScreen.bounds.size
        let maxBoundsSizeValue = max(size.height, size.width)
        
        return isIPad() && maxBoundsSizeValue == 1366
    }
    
    static func isBackgrounded() -> Bool {
        return UIApplication.shared.applicationState == .background 
    }
    
    static var shouldShowCompactView: Bool {
        guard UIApplication.isIPad() else { return true }
        
        switch UIApplication.splitScreenWidth() {
        case .full,
             .twoThirds where UIApplication.isLandscape():
            return false
        case .twoThirds, .oneHalf, .oneThird:
            return true
        }
    }
}

extension Dictionary where Key == UIApplication.LaunchOptionsKey {
    var url: URL? {
        return self[.url] as? URL
    }    
}
