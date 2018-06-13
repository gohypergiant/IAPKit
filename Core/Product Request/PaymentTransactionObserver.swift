//
//  PaymentTransactionObserver.swift
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

protocol PaymentTransactionObserverDelegate: class {
    func didRestorePurchases()
    func didCompletePurchase(productIdentifier: String)
    func transactionDidFail(localizedErrorMessage: String)
    func transactionCancelled()
}

/// A class that responds to delegate callbacks from StoreKit.  The observer is
/// added and removed in Store.swift
public class PaymentTransactionObserver: NSObject, SKPaymentTransactionObserver {
    
    weak var delegate: PaymentTransactionObserverDelegate?
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:

                delegate?.didCompletePurchase(productIdentifier: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let transactionError = transaction.error as NSError? {
                    // Based on watching WWDC 2017 Session 303 - the speaker recommends against
                    // displaying unneccesary error messages to the user.  In the case of `paymentCancelled`,
                    // the user has already pressed the cancel button so we
                    // don't need to show them an alert that tells them they pressed cancel.
                    if transactionError.code != SKError.paymentCancelled.rawValue {
                        
                        let unknownMessage = NSLocalizedString("Unknown iTunes Store error.", tableName: nil, bundle: Bundle(for: PaymentTransactionObserver.self), value: "", comment: "an unknown error message was returned from the iTunes Store")
                        let localizedErrorMessage = transaction.error?.localizedDescription ?? unknownMessage
                        
                        delegate?.transactionDidFail(localizedErrorMessage: localizedErrorMessage)
                        
                        ErrorLog("Transaction Error: \(localizedErrorMessage)")
                    } else {
                        delegate?.transactionCancelled()
                    }
                }
            
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing:
                break
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // Check to see if the returned queue as any transactions.  If there are no
        // transactions, it means the user has not made any purchases yet, so there is
        // nothing to restore.
        guard queue.transactions.count > 0 else {
            // There were no transactions for this user
            let localizedErrorMessage = NSLocalizedString("Sorry, no purchased products were found. If you have questions, please contact support@blackpixel.com.", tableName: nil, bundle: Bundle(for: PaymentTransactionObserver.self), value: "", comment: "no previous transactions were found on the users current iTunes account error message")
            
            delegate?.transactionDidFail(localizedErrorMessage: localizedErrorMessage)
            
            return
        }
        
        delegate?.didRestorePurchases()
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        ErrorLog(error.localizedDescription)
        
        // 9/14/2017 Jamin Guy: This is currently called when a user taps the cancel button
        // and there is no way to differentiate between that and other errors. Because we
        // cannot show an error when the user cancels we will treat every error as a user
        // cancel.
        delegate?.transactionCancelled()
    }
    
    // Delegate needs to be implemented to support "Promoted IAP" from within the AppStore
    //      See technote at: https://developer.apple.com/news/?id=08292017a
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

