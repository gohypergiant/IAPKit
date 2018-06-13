# Release Notes

### 1.3
* Adding support for the iPhone [PR](https://github.com/blackpixel/iap/pull/73)

### 1.2
* Adding purchase information to user info object of `.IAPStoreDidRefresh` notification for analytics purposes. [PR](https://github.com/blackpixel/iap/pull/71)

### 1.1.3
* Fixed memory leak in ReceiptValidator

### 1.1.2
* Fixed HTTP date parsing for non-English locales

### 1.1.1
* Fixed issue where `didRestorePurchases` delegate called twice [PR](https://github.com/blackpixel/iap/pull/54)
* Fixed where IAPDialogViewController would get stuck when repurchasing the trial [PR](https://github.com/blackpixel/iap/pull/56)
* Fixed a Hockey Crash Report [PR](https://github.com/blackpixel/iap/pull/52)
* Added broadcasting of user initated events via a Notification

### 1.1
* Adding marketingTitle to `Purchaseable` [PR](https://github.com/blackpixel/iap/pull/37)


### 1.0.2
* Fixed issue with retrieving product list failure [PR](https://github.com/blackpixel/iap/pull/34)
* Following Apple guidance on purchaseDate receipt fields [PR](https://github.com/blackpixel/iap/pull/33)

### 1.0.1
* Fixed IAP Activity View [PR](https://github.com/blackpixel/iap/pull/29)
* Posting notification on successful purchase [PR](https://github.com/blackpixel/iap/pull/30)
* Implemented new SKTransactionObserverDelegate method [PR](https://github.com/blackpixel/iap/pull/27)
* Refactored IAP dialog presentation completion handler [PR](https://github.com/blackpixel/iap/pull/26)

### 1.0
* Initial release

