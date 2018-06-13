# IAPKit
A simple approach to Apple In App Purchases (IAP) that handles the presentation of products, purchasing, receipt validation, and timed free trials.

IAPKit is used by [Kaleidoscope 2](https://www.kaleidoscopeapp.com) and [Pixelboard](https://www.getpixelboardapp.com) on iPad.

### Requirements
- An app running iOS 11+
- StoreKit


### Features
- Supports SafeArea Layout
- Supports Multitasking on iPad


## Release Notes
[Release notes](releaseNotes.md)


## Examples
![iPhone Portrait](/ReadMeImages/iPhonePortrait.png)
![iPhone Landscape](/ReadMeImages/iPhoneLandscape.png)
![iPad Portrait](/ReadMeImages/iPadPortrait.png)
![iPad Split Screen](/ReadMeImages/iPadSplitScreen.png)

## Installation
Simply grab the framework (either via git submodule or another package manager).

Add the `IAP.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `IAP.framework` to your "Link Binary with Libraries" phase.

## Configuration
First thing is to define your app-specific product types by creating a new string typed enum that reference your IAP products in iTunes Connect. Be sure to import `IAP` and `StoreKit`.

```swift
enum IAPProducts: String {
    case freeTrial = "001"
    case standard = "002"
    case pro = "003"
    
    static let allIdentifiers: [IAPProducts] = [.freeTrial,
                                                 .standard,
                                                 .pro]
}

```

Then, extend your products to conform to `Purchaseable`

```swift
extension IAPProducts: Purchaseable {
    
    static var relevantProductIdentifiers: Set<ProductIdentifier> {
        return Set(IAPProducts.allIdentifiers.map{ $0.rawValue })
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
            return "Description of your free trial."
        case .standard:
            return "Description of your standard features."
        case .pro:
            return "Description of your pro features."
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
            return "Try [App Name] Now"
        case .standard:
            return "Buy [App Name] Now"
        case .pro:
            return "Go Pro Now"
        }
    }
    
    init?(productIdentifier: ProductIdentifier) {
        self.init(rawValue: productIdentifier)
    }
}


// Conveniences

fileprivate func Days(_ days: Int) -> TimeInterval {
    return TimeInterval(days * 24 * 60 * 60)
}
```

Last, extend your products to conform to `Comparable` (required by `Purchaseable`)

```swift
extension IAPProducts: Comparable {
    static func <(lhs: IAPProducts, rhs: IAPProducts) -> Bool {
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
```

## Usage
Import IAPKit

```swift
import IAP
```

Create a store object

```swift
private let store = Store<IAPProducts>()
```

Then, utilize the many options publicly available with the store object:

### Check for purchased products
```swift
store.purchasedProducts // `[PurchasedProduct]?`
```

### Check to see if purchases are available
```swift
store.hasPurchasesAvailable // `Bool`
```

### Determine if any receipts are of type Availability.purchased
```swift
store.isAppPurchased // `Bool`
```

### Restore purchases
```swift
store.restorePurchases()
```

### Check for availability of a product
```swift
store.availability(for product: ) // -> `Availability`
```

### Present available purchases
```swift
store.presentAvailablePurchases(from presentingViewController: completion:)
```

### Store delegate methods
```swift
func didRestorePurchases()
func didCompletePurchase(productIdentifier: )
func transactionDidFail(localizedErrorMessage: )
func transactionCancelled()
```


## OpenSSL
This framework has a dependency on OpenSSL.  OpenSSL is required for receipt validation of the receipt delivered by Apple via the AppStore.  **Note**: *For the time being, the OpenSSL static libraries have only been incorporated into the iOS target.*

The static library was built from the repo and instructions for [OpenSSL-for-iPhone](https://github.com/x2on/OpenSSL-for-iPhone)

The integration of the OpenSSL libraries vary somewhat from the instructions for OpenSSL-for-iPhone for the reason that their sample project shows how to integrate the library into a single target app.  Because the BPXL IAP Framework is distributed as a "framework" we must follow a different procedure as we cannot import the OpenSSL headers in a `bridging-header.h` file.  Instead we must integrate the library using a `module.modulemap`.  You will find this file in `iOS/ProjectModule/module.modulemap`.

Some specific build settings need to be set in order to facilitate this:

`HEADER_SEARCH_PATHS = $(PROJECT_DIR)/iOS/OpenSSL/include` 
`LIBRARY_SEARCH_PATHS = $(inherited) $(PROJECT_DIR)/iOS/OpenSSL/lib/`
`SWIFT_INCLUDE_PATHS = $(SRCROOT)/iOS/ProjectModules`

Receipt validation code is based off [this tutorial](http://robin.github.io/swift/ios/2017/01/23/1-Local-Receipt-Validation-in-Swift-3/)

**IMPORTANT:**

In order to fully integrate OpenSSL into our Swift Framework, I had to modify the OpenSSL header files and remove the `openssl/` prefix from ALL `#import <openssl/{file}.h>` references (nb: Jim Rutherford)