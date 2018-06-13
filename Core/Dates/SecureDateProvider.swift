//
//  SecureDateProvider.swift
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


extension Notification.Name {

    /// The clock offset was refreshed.
    static let SecureDateProviderOffsetRefreshed = Notification.Name(
        rawValue: "com.blackpixel.SecureDateProviderOffsetRefreshed"
    )

    /// The clock offset was not successfully refreshed.
    static let SecureDateProviderOffsetRefreshError = Notification.Name(
        rawValue: "com.blackpixel.SecureDateProviderOffsetRefreshError"
    )

}

class SecureDateProvider {

    static let `default` = SecureDateProvider()

    private let consecutiveRefreshFailuresPermitted: Int

    init(consecutiveRefreshFailuresPermitted: Int = 5) {
        self.consecutiveRefreshFailuresPermitted = consecutiveRefreshFailuresPermitted
    }

    /// Returns the current date if one can be securely provided or `nil` if not.
    var date: Date? {
        if Keychain.consecutiveRefreshFailures > consecutiveRefreshFailuresPermitted {
            return nil
        }
        else {
            return Date().addingTimeInterval(Keychain.clockOffset)
        }
    }

    /// Use `HTTPDateClient` to refresh the clock offset.
    func refresh() {
        HTTPDateClient.fetchDate { (result) in
            switch result {
            case .success(let date):
                Keychain.clockOffset = date.timeIntervalSinceNow
                Keychain.consecutiveRefreshFailures = 0
                NotificationCenter.default.post(name: .SecureDateProviderOffsetRefreshed, object: self)

            case .error(_):
                Keychain.consecutiveRefreshFailures += 1
                NotificationCenter.default.post(name: .SecureDateProviderOffsetRefreshError, object: self)
            }
        }
    }

}
