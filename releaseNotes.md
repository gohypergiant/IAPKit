# Release Notes

### 1.3
* Adding support for the iPhone

### 1.2
* Adding purchase information to user info object of `.IAPStoreDidRefresh` notification for analytics purposes.

### 1.1.3
* Fixed memory leak in ReceiptValidator

### 1.1.2
* Fixed HTTP date parsing for non-English locales

### 1.1.1
* Fixed issue where `didRestorePurchases` delegate called twice
* Fixed where IAPDialogViewController would get stuck when repurchasing the trial
* Fixed a Hockey Crash Report
* Added broadcasting of user initated events via a Notification

### 1.1
* Adding marketingTitle to `Purchaseable`


### 1.0.2
* Fixed issue with retrieving product list failure
* Following Apple guidance on purchaseDate receipt fields

### 1.0.1
* Fixed IAP Activity View
* Posting notification on successful purchase
* Implemented new SKTransactionObserverDelegate method
* Refactored IAP dialog presentation completion handler

### 1.0
* Initial release

