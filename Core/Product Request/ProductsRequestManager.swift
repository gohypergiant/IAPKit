//
//  ProductsRequestManager.swift
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

/// The result of an In-App Purchase operation.
public enum IAPResult<T, U> {
    case success(T)
    case error(U)
}

enum ProductRequestError: Error {
    case noProducts
    case userCancelled
    case unknown
}


/// A class that manages the lifecycle of an SKProductsRequest
class ProductsRequestManager: NSObject, SKProductsRequestDelegate {
    
    private var completion: ((IAPResult<[SKProduct], Error>) -> Void)?
    private var productsRequest:SKProductsRequest?
    
    func requestProducts(productIdentifiers: Set<String>, completion: @escaping (IAPResult<[SKProduct], Error>) -> Void) {
        guard productIdentifiers.count > 0 else {
            assertionFailure("Error: No product identifiers to request")
            return
        }
        
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
        
        self.productsRequest = productsRequest
        self.completion = completion
    }

    /// Support cancellation of the request
    public func cancel() {
        productsRequest?.cancel()
        
        // The docs for `SKRequest` indicate that once cancelling a request:
        //
        // "When you cancel a request, the delegate is not called with an error."
        //
        // This is false - unless I `nil` the delegate here, the
        // `request:didFailWithError` fires with an unknown error
        productsRequest?.delegate = nil
        
        self.completion?(.error(ProductRequestError.userCancelled))
    }
    
    // MARK: - SKProductsRequestDelegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        guard response.products.count > 0 else {
            VerboseLog("No products found")
            self.completion?(.error(ProductRequestError.noProducts))
            return
        }
    
        self.completion?(.success(response.products))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        ErrorLog("Failed to load list of products with error: \(error.localizedDescription)")
        completion?(.error(error))
    }
}
