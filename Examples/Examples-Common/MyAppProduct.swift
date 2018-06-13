//
//  MyAppProduct.swift
//  Example-iOS
//
//  Created by Jared Sinclair on 8/26/17.
//  Copyright © 2017 Black Pixel Luminance. All rights reserved.
//

import IAP
import StoreKit

// (1) Define your app-specific product type:

enum MyAppProduct: String {
    case freeTrial = "001_01"
    case standard = "001_02"
    case pro = "001_03"
    
    static let allIdentifiers: [MyAppProduct] = [.freeTrial, .standard, .pro]
}

// (2) Extend it to conform to Purchaseable:

extension MyAppProduct: Purchaseable {
    
    static var relevantProductIdentifiers: Set<ProductIdentifier> {
        return Set(MyAppProduct.allIdentifiers.map{ $0.rawValue })
    }

    static var accentColorForStore: IAPColor {
        return UIColor(red:0.40, green:0.32, blue:0.81, alpha:1.00)
    }

    var lifetime: ProductLifetime {
        switch self {
        case .freeTrial: return .expiring(afterSeconds: Days(14))
        case .standard: return .unlimited
        case .pro: return .unlimited
        }
    }
    
    var productIdentifier: ProductIdentifier {
        return rawValue
    }
    
    var marketingMessage: String {
        switch self {
        case .freeTrial:
            return "With the 14-day free trial, you can try all the features without buying anything.  After the trial, you can continue to use the app in Free mode"
        case .standard:
            return "All collaboration features for you and one other person. "
        case .pro:
            return "All collaboration features for you and 9 other collaborators."
        }
    }
    
    var callToActionButtonText: String {
        switch self {
        case .freeTrial:
            return "Start Free Trial"
        case .standard:
            return "Buy Now"
        case .pro:
            return "Go Pro Now"
        }
    }
    
    var marketingTitle: String {
        switch self {
        case .freeTrial:
            return "Try Kaleidoscope Now"
        case .standard:
            return "Buy Kaleidoscope Now"
        case .pro:
            return "Go Pro Now"
        }
    }
    
    init?(productIdentifier: ProductIdentifier) {
        self.init(rawValue: productIdentifier)
    }
}

// (3) Extend it to conform to Comparable (required by Purchaseable):

extension MyAppProduct: Comparable {
    static func <(lhs: MyAppProduct, rhs: MyAppProduct) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
    }
    
    private var sortIndex: Int {
        switch self {
        case .freeTrial: return 1
        case .standard: return 2
        case .pro: return 3
        }
    }
}

// (4) Extend it to conform to Equatable (required by Purchaseable):

extension MyAppProduct: Equatable {
    static func ==(lhs: MyAppProduct, rhs: MyAppProduct) -> Bool {
        switch (lhs, rhs) {
        case (.freeTrial, .freeTrial):
            return true
        case (.standard, .standard):
            return true
        case (.pro, .pro):
            return true
        case (.freeTrial, _),
             (.standard, _),
             (.pro, _):
            return false
        }
    }
}

// Conveniences


fileprivate func Days(_ days: Int) -> TimeInterval {
    return TimeInterval(days * 24 * 60 * 60)
}
