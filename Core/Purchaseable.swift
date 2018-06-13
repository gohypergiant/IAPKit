//
//  IAPPurchaseable.swift
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

import Foundation
import StoreKit

/// Host applications must provide a concrete type which conforms to this. It is
/// suggested that apps use an enum since that encourages compile-time safety.
///
/// Any and all app-specific information that Store may need in order to
/// present a purchase UI and conduct a payment request **must** become a
/// requirement of Purchaseable.
///
/// Comparable conformance is required in order for the Store to know how to
/// sort the products. If a flat sorting isn't sufficient, the Purchaseable
/// protocol can be revised to require a more nuanced sorting routine.
public protocol Purchaseable: Comparable {
    
    /// Returns all the product identifiers that the host application cares about.
    static var relevantProductIdentifiers: Set<ProductIdentifier> { get }
    
    /// Returns the accent color the Store should use when building UI.
    static var accentColorForStore: IAPColor { get }
    
    /// Equivalent to SKProduct.productIdentifier
    var productIdentifier: ProductIdentifier { get }

    /// The lifetime of the product (unlimited, expiring, subscription).
    var lifetime: ProductLifetime { get }
    
    /// Returns a localized string suitable for displaying the product title in the Store's UI.
    var marketingTitle: String { get }
    
    /// Returns a localized string suitable for displaying the product description in the Store's UI.
    var marketingMessage: String { get }
    
    /// Returns a localized string suitable for displaying in the Store's UI.
    var callToActionButtonText: String { get }
    
    /// Required initializer.
    init?(productIdentifier: ProductIdentifier)
}
