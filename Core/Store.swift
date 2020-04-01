//
//  Store.swift
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

/// A generic class which provides in-app-purchase utilities. Host applications
/// provide a concrete type conforming to IAPPurchaseable so that IAPStore can
/// conduct the full payment workflow, including presenting appropriate UI.
public class Store<Product: Purchaseable> {
    
    private let productsRequestManager = ProductsRequestManager()
    private let paymentTransactionObserver = PaymentTransactionObserver()
    
    private var modalViewController: IAPDialogViewController?
    private var observers: [NSObjectProtocol] = []
    
    private var modalDismissalCompletion: IAPCompletionHandler?
    
    /// The list of unpurchased products returned by a products request.
    private var availableProducts: [SKProduct] = []
    
    /// The list of all purchased products.
    public var purchasedProducts: [PurchasedProduct]? {
        
        guard ReceiptValidator.hasReceipt else {
            return nil
        }
        
        return ReceiptValidator.validatedProducts
    }
    
    
    /// Designated Initializer
    public init() {
        // Add the SKPaymentObserver
        paymentTransactionObserver.delegate = self
        SKPaymentQueue.default().add(paymentTransactionObserver)

        configureSecureDateProviderRefresh()
    }
    
    deinit {
        // Remove the SKPaymentObserver
        paymentTransactionObserver.delegate = nil
        SKPaymentQueue.default().remove(paymentTransactionObserver)
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    
    /// A property to determine if the app bundle
    /// contains any purchases.  This is done by
    /// checking for the existence of a receipt in the
    /// apps bundle
    public var hasPurchasesAvailable: Bool {
        return ReceiptValidator.hasReceipt
    }
    
    // A property to determine if any of the purchase receipts
    // are of type `Availablity.purchased`.
    public var isAppPurchased: Bool {
        guard hasPurchasesAvailable,
            let purchasedProducts = ReceiptValidator.validatedProducts else { return false }
        
        for purchase in purchasedProducts {
            guard let product = Product(productIdentifier: purchase.productIdentifier) else {
                continue
            }
            
            if case Availability.purchased = availability(for: product) {
                return true
            }
        }
        
        return false
    }
    
    /// Refreshes the list of products and their availabilities.
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /// Checks the known availability for `product`.
    public func availability(for product: Product) -> Availability {
        
        guard let purchasedProduct = ReceiptValidator.purchasedProduct(for: product.productIdentifier) else {
            return .unknown
        }
        
        switch product.lifetime {
        case .unlimited:
            return .purchased
        
        case .expiring(let interval):
            let purchaseDate = purchasedProduct.purchaseDate
            let expiryDate = purchaseDate.addingTimeInterval(interval)

            guard let currentDate = SecureDateProvider.default.date else {
                return .unknown
            }
            
            if expiryDate < currentDate {
                return .expired
            }
            
            return .purchasedWillExpire(expiresOn: expiryDate)

        case .subscription:
            return .unknown
        }
    }
    
    
    
    /// Walks the user through a purchase of one or more products.
    ///
    /// - Parameters:
    ///   - presentingViewController: ViewController to present the modal view above
    ///   - completion: When StoreKit dismisses the modal view controller or the user dismisses the modal view controller by hitting the close button
    public func presentAvailablePurchases(from presentingViewController: IAPViewController, completion: IAPCompletionHandler? = nil) {
        
        modalDismissalCompletion = completion
        
        let modalViewController = IAPDialogViewController.make(accentColor: Product.accentColorForStore,
                                                               cancellationHandler: {
                                                                self.dismissAvailablePurchasesModal(wasCancelled: true)
        })
        
        presentingViewController.present(modalViewController, animated: true, completion: nil)
        self.modalViewController = modalViewController
        refreshProductsList()
        
    }
    
    
    private func refreshProductsList() {
        productsRequestManager.requestProducts(productIdentifiers: Product.relevantProductIdentifiers) { [weak self] result in
            guard let this = self,
                let modalViewController = this.modalViewController else { return }
            
            switch result {
            case .success(let products):
                
                if let purchasedProducts = this.purchasedProducts {
                    let purchasedProductIds = purchasedProducts.map({ $0.productIdentifier })
                    
                    // leaving this here for testing as it's a total pain to work with
                    // sandbox accounts.  Once a product has been purchased on an account,
                    // it is there forever.
                    //let purchasedProductIds = [String]()
                    
                    // Filter out the purchased products
                    this.availableProducts = products.filter({ !purchasedProductIds.contains($0.productIdentifier) })
                } else {
                    this.availableProducts = products
                }
                
                var storeProducts = [StoreProduct]()
                for skProduct in this.availableProducts {
                    guard let product = Product(productIdentifier: skProduct.productIdentifier) else { continue }
                    let storeProduct = StoreProduct(skProduct: skProduct,
                                                    marketingTitle: product.marketingTitle,
                                                    marketingMessage: product.marketingMessage,
                                                    callToActionButtonText: product.callToActionButtonText)
                    storeProducts.append(storeProduct)
                }
                
                modalViewController.products = storeProducts
                
            case .error(let error):
                
                if case ProductRequestError.userCancelled = error {
                    // The user cancelled this - we don't need to show them
                    // any alert messages
                    return
                }
                
                let errorTitle = NSLocalizedString("Error", tableName: nil, bundle: Bundle(for: Store.self), value: "",
                                                   comment: "A title for an error message alert")
                
                let alertController = UIAlertController(title: errorTitle, message: error.localizedDescription, preferredStyle: .alert)
                
                let okActionTitle = NSLocalizedString("OK", tableName: nil, bundle: Bundle(for: Store.self), value: "",
                                                      comment: "OK button text.  All is right.  Everything is good")
                let okAction = UIAlertAction(title: okActionTitle, style: .default, handler: { [weak self] _ in
                    self?.dismissAvailablePurchasesModal()
                })
                
                let retryActionTitle = NSLocalizedString("Retry", tableName: nil, bundle: Bundle(for: Store.self), value: "",
                                                      comment: "Try again")
                let retryAction = UIAlertAction(title: retryActionTitle, style: .default, handler: { [weak self] _ in
                    self?.refreshProductsList()
                })
                
                alertController.addAction(retryAction)
                alertController.addAction(okAction)
                modalViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func dismissAvailablePurchasesModal(wasCancelled: Bool = false, completion: (()-> Void)? = nil) {
        guard let modalViewController = modalViewController else { return }
        
        if wasCancelled {
            productsRequestManager.cancel()
            
            let userInfo = [UserEvent.transaction.rawValue : UserEvent.TransactionType.userCancelledIAPKit.rawValue]
            logUserEvent(info: userInfo)
        }
        
        modalViewController.dismiss(animated: true, completion: {
            self.modalDismissalCompletion?(wasCancelled)
            self.modalDismissalCompletion = nil
            self.modalViewController = nil
            completion?()
        })
    }
}

// MARK: - Private

extension Store {

    /// Refresh the system clock offset only if the app isn't purchased.
    fileprivate func secureDateProviderRefreshIfNotPurchased() {
        if !isAppPurchased {
            SecureDateProvider.default.refresh()
        }
    }

    fileprivate func configureSecureDateProviderRefresh() {
        secureDateProviderRefreshIfNotPurchased()

        observers.append(NotificationCenter.when(UIApplication.willEnterForegroundNotification) { [weak self] _ in
            self?.secureDateProviderRefreshIfNotPurchased()
        })
        
        observers.append(NotificationCenter.when(.SecureDateProviderOffsetRefreshed) { (_) in
            NotificationCenter.default.post(name: Notification.Name.IAPStoreDidRefresh, object: nil)
        })
        
        observers.append(NotificationCenter.when(.SecureDateProviderOffsetRefreshError) { (_) in
            NotificationCenter.default.post(name: Notification.Name.IAPStoreDidRefresh, object: nil)
        })
    }

}

// MARK: - PaymentTransactionObserverDelegate
extension Store: PaymentTransactionObserverDelegate {
    func didRestorePurchases() {
        let title = NSLocalizedString("Your purchases were restored.", tableName: nil, bundle: Bundle(for: Store.self), value: "",
                                      comment: "an alert message that is displayed when a users' in-app-purchases are restored.")
        showAlert(title: title, message: nil)
        
        let userInfo = [UserEvent.transaction.rawValue : UserEvent.TransactionType.restoredPurchases.rawValue]
        NotificationCenter.default.post(name: Notification.Name.IAPUserEvent, object: nil, userInfo: userInfo)
    }
    
    func didCompletePurchase(productIdentifier: String) {
        dismissAvailablePurchasesModal() {
            // Post this notification after the IAPDialogViewController has been completely dismissed
            // in case the client needds to present it's own modal/alert upon responding to `.IAPStoreDidRefresh`

            var notificationUserInfo: [String : Any]? = nil
            if let product = self.availableProducts.filter({ $0.productIdentifier == productIdentifier }).first {
                let revenueEventProduct = RevenueEventProduct(title: product.localizedTitle,
                                                              price: product.price,
                                                              priceLocale: product.priceLocale,
                                                              productIdentifier: product.productIdentifier)
                notificationUserInfo = [IAPNotificationUserInfoKeys.purchasedProduct.rawValue : revenueEventProduct]
            }
            NotificationCenter.default.post(name: Notification.Name.IAPStoreDidRefresh, object: nil, userInfo: notificationUserInfo)
            
            let userInfo = [UserEvent.transaction.rawValue : UserEvent.TransactionType.purchase.rawValue,
                            UserEvent.InformationField.productId.rawValue : productIdentifier]
            self.logUserEvent(info: userInfo)
        }
    }
    
    func transactionDidFail(localizedErrorMessage: String) {
        let title = NSLocalizedString("iTunes Store Error", tableName: nil, bundle: Bundle(for: Store.self), value: "",
                                      comment: "an alert title that is displayed when there was an error returned from the iTunes store.")
        
        showAlert(title: title, message: localizedErrorMessage)
        
        let userInfo = [UserEvent.transaction.rawValue : UserEvent.TransactionType.failed.rawValue,
                        UserEvent.InformationField.reason.rawValue : localizedErrorMessage]
        logUserEvent(info: userInfo)
    }
    
    func transactionCancelled() {
        dismissAvailablePurchasesModal() {
            let userInfo = [UserEvent.transaction.rawValue : UserEvent.TransactionType.userCancelledStoreKit.rawValue]
            self.logUserEvent(info: userInfo)
        }
    }
    
    private func showAlert(title: String?, message: String?) {
        guard let modalViewController = modalViewController else { return }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okActionTitle = NSLocalizedString("OK", tableName: nil, bundle: Bundle(for: Store.self), value: "",
                                      comment: "OK button text.  All is right.  Everything is good")
        let action = UIAlertAction(title: okActionTitle, style: .default, handler: { [weak self] _ in
            self?.dismissAvailablePurchasesModal() {
                NotificationCenter.default.post(name: Notification.Name.IAPStoreDidRefresh, object: nil)
            }
        })
        
        alertController.addAction(action)
        modalViewController.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Logging User Events

extension Store {
    private func logUserEvent(info: [String:String]) {
        NotificationCenter.default.post(name: Notification.Name.IAPUserEvent, object: nil, userInfo: info)
    }
}


struct StoreProduct {
    var skProduct: SKProduct
    var marketingTitle: String
    var marketingMessage: String
    var callToActionButtonText: String
}

// An object used to log purchases in IAPStore refresh notifications.
public struct RevenueEventProduct {
    public let title: String
    public let price: NSDecimalNumber
    public let priceLocale: Locale
    public let productIdentifier: String
}
