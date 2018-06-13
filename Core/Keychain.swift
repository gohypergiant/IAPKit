//
//  Keychain.swift
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


struct Keychain {

    static var consecutiveRefreshFailures: Int {
        get {
            return secureDateProviderDictionary?[.consecutiveRefreshFailures] as? Int ?? 0
        }

        set {
            var currentDict = secureDateProviderDictionary ?? [:]
            currentDict[.consecutiveRefreshFailures] = newValue
            secureDateProviderDictionary = currentDict
        }
    }

    static var clockOffset: TimeInterval {
        get {
            return secureDateProviderDictionary?[.clockOffset] as? TimeInterval ?? 0
        }

        set {
            var currentDict = secureDateProviderDictionary ?? [:]
            currentDict[.clockOffset] = newValue
            secureDateProviderDictionary = currentDict
        }
    }

    // MARK: - Private

    private static let secureDateProviderService: String = "SecureDateProvider"

    private enum SecureDateProviderKey: String {
        case consecutiveRefreshFailures = "consecutiveRefreshFailures"
        case clockOffset = "clockOffset"
    }

    private static var secureDateProviderDictionary: [SecureDateProviderKey : Any]? {
        get {
            let query: [String : Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: secureDateProviderService,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnAttributes as String: kCFBooleanTrue,
                kSecReturnData as String: kCFBooleanTrue
            ]

            var queryResult: AnyObject?
            let status = withUnsafeMutablePointer(to: &queryResult) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }

            guard status != errSecItemNotFound || status == noErr else {
                return nil
            }

            guard let existingItem = queryResult as? [String : AnyObject],
                let data = existingItem[kSecValueData as String] as? Data,
                let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any] else {
                    return nil
            }

            var returnValue = [SecureDateProviderKey: Any]()

            for (key, value) in dictionary {
                if let newKey = SecureDateProviderKey(rawValue: key) {
                    returnValue[newKey] = value
                }
            }

            return returnValue
        }

        set {
            var newDictionary = [String : Any]()

            if let newValue = newValue {
                for (key, value) in newValue {
                    newDictionary[key.rawValue] = value
                }
            }

            let data = NSKeyedArchiver.archivedData(withRootObject: newDictionary)

            if secureDateProviderDictionary != nil {
                let query: [String : Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: secureDateProviderService
                ]

                let attributesToUpdate: [String : Any] = [
                    kSecValueData as String: data
                ]

                let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

                if status != noErr {
                    ErrorLog("Error updating keychain")
                }
            }
            else {
                let query: [String : Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: secureDateProviderService,
                    kSecValueData as String: data
                ]

                let status = SecItemAdd(query as CFDictionary, nil)

                if status != noErr {
                    ErrorLog("Error saving to keychain: \(status)")
                }
            }
        }
    }

}
