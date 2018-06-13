//
//  RoundedButton.swift
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

public class RoundedButton: UIButton {
    
    var highlightView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public var accentColor: UIColor = .black
    
    func commonInit() {
        adjustsImageWhenHighlighted = false
        
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowColor = UIColor(hue:0.60, saturation:0.10, brightness:0.60, alpha:0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.cornerRadius = 7
        layer.masksToBounds = false
        
        highlightView = UIView()
        highlightView.backgroundColor = UIColor.black
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        highlightView.alpha = 0
        highlightView.layer.cornerRadius = 7
        addSubview(highlightView)
        
        NSLayoutConstraint.activate(
            [
                highlightView.leadingAnchor.constraint(equalTo: leadingAnchor),
                highlightView.trailingAnchor.constraint(equalTo: trailingAnchor),
                highlightView.topAnchor.constraint(equalTo: topAnchor),
                highlightView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }
    
    override open var isHighlighted: Bool {
        didSet {
            highlightView.alpha = isHighlighted ? 0.1 : 0
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? accentColor : accentColor.withAlphaComponent(0.4)
            layer.shadowOpacity = isEnabled ? 1 : 0
        }
    }
}
