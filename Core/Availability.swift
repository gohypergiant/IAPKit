//
//  Availability.swift
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

/// Combination of global product state and user-specific product state.
public enum Availability {
    
    /// The product is visible on the store but the user hasn't purchased it.
    case availableForPurchase
    
    /// The product is a one-time purchase and has been purchased.
    case purchased
    
    /// The product has been purchased on a time-limited basis.
    case purchasedWillExpire(expiresOn: Date)
    
    /// The product is an auto-renewing subscription and the user is subscribed.
    case subscribed(renewsOn: Date?)
    
    /// The product was purchased but the expiration date has lapsed.
    case expired
    
    /// The product was purchased but that purchase was revoked.
    case revoked
    
    /// The product is not visible on the store anymore.
    case unavailableForPurchase
    
    /// The product's availability has not been determined yet.
    case unknown
    
}
