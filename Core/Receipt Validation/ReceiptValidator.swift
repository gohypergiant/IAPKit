//
//  ReceiptValidator.swift
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

import UIKit

import OpenSSL.asn1
import OpenSSL.pkcs7
import OpenSSL.x509
import OpenSSL.sha

/// A class that validates and reads purchases from an IAP receipt
/// Receipt validation code is based off the tutorial found at:
/// http://robin.github.io/swift/ios/2017/01/23/1-Local-Receipt-Validation-in-Swift-3/
class ReceiptValidator {
    
    static var hasReceipt: Bool {
        guard let _ = Bundle.main.appStoreReceiptURL else {
            return false
        }
        
        return true
    }

    static var validatedProducts: [PurchasedProduct]? {
        
        var opaqueData: NSData?
        var bundleIdData: NSData?
        var hashData: NSData?
        
        // The Apple Root Certificate is in the framework bundle
        let frameworkBundle = Bundle(for: ReceiptValidator.self)

        guard let certificateURL = frameworkBundle.url(forResource: "AppleIncRootCertificate", withExtension: "cer"),
            let certificateData = NSData(contentsOf: certificateURL) else {
                assertionFailure("Apple Root Certificate not available")
                return nil
        }
        
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
            let receiptData = NSData(contentsOf: receiptURL) else {
                VerboseLog("Invalid receipt")
                return nil
        }
        
        let bio = BIOWrapper(data: receiptData)
        let p7OrNil: UnsafeMutablePointer<PKCS7>? = d2i_PKCS7_bio(bio.bio, nil)
        guard let p7 = p7OrNil else {
            VerboseLog("Unable to find PKCS7 payload")
            return nil
        }
        
        defer {
            PKCS7_free(p7)
        }
        
        OpenSSL_add_all_digests()
        
        let x509Store = X509StoreWrapper()
        let certificate = X509Wrapper(data: certificateData)
        x509Store.addCert(x509: certificate)
        let payload = BIOWrapper()
        guard PKCS7_verify(p7, nil, x509Store.store, nil, payload.bio, 0) == 1 else {
            VerboseLog("Unable to verify PKCS7 payload")
            return nil
        }

        var iapReceipts = [PurchaseReceipt]()
        // Parse the contents of our PKCS7 Payload
        if let contents = p7.pointee.d.sign.pointee.contents,
            OBJ_obj2nid(contents.pointee.type) == NID_pkcs7_data ,
            let octets = contents.pointee.d.data {
            var ptr : UnsafePointer? = UnsafePointer(octets.pointee.data)
            let end = ptr!.advanced(by: Int(octets.pointee.length))
            var type : Int32 = 0
            var xclass: Int32 = 0
            var length = 0
            ASN1_get_object(&ptr, &length, &type, &xclass,Int(octets.pointee.length))
            guard type == V_ASN1_SET else {
                VerboseLog("Unable to verify ASN1 payload")
                return nil
            }
            while ptr! < end {
                ASN1_get_object(&ptr, &length, &type, &xclass, ptr!.distance(to: end))
                guard type == V_ASN1_SEQUENCE else {
                    VerboseLog("Unable to verify ASN1 payload")
                    return nil
                }
                
                guard let attrType = ASN1Helper.readInteger(pointer: &ptr, length: ptr!.distance(to: end)) else {
                    VerboseLog("Unable to verify ASN1 payload")
                    return nil
                }
                
                guard let _ = ASN1Helper.readInteger(pointer: &ptr, length: ptr!.distance(to: end)) else {
                    VerboseLog("Unable to verify ASN1 payload")
                    return nil
                }
                
                ASN1_get_object(&ptr, &length, &type, &xclass, ptr!.distance(to: end))
                guard type == V_ASN1_OCTET_STRING else {
                    VerboseLog("Unable to verify ASN1 payload")
                    return nil
                }
                
                switch attrType {
                case 2:
                    let strPtr = ptr
                    bundleIdData = NSData(bytes: strPtr, length: length)
                case 4:
                    opaqueData = NSData(bytes: ptr!, length: length)
                case 5:
                    hashData = NSData(bytes: ptr!, length: length)
                case 17:
                    let p = ptr
                    let iapReceipt = PurchaseReceipt(with: p!, len: length)
                    iapReceipts.append(iapReceipt)
                default:
                    break
                }
                ptr = ptr?.advanced(by: length)
            }
        }
        
        let computedData = self.computedHashData(opaqueData: opaqueData, bundleIdData: bundleIdData)
        
        guard let safeHashData = hashData,
            safeHashData ==  computedData else {
                VerboseLog("Hash data from receipt does not meet computed hash values of device")
                return nil
        }
        
        var purchasedProducts = [PurchasedProduct]()
        for purchase in iapReceipts {
            
            guard let productIdentifier = purchase.productIdentifier,
                let purchaseDate = purchase.originalPurchaseDate else {
                    continue
            }

            let purchasedProduct = PurchasedProduct(productIdentifier: productIdentifier, purchaseDate: purchaseDate)
            purchasedProducts.append(purchasedProduct)

        }

        return purchasedProducts.count > 0 ? purchasedProducts : nil
    }
    
    static func purchasedProduct(for productIdentifier: ProductIdentifier) -> PurchasedProduct? {
        guard let allProducts = self.validatedProducts else {
            return nil
        }
        
        return allProducts.filter({$0.productIdentifier == productIdentifier}).first
    }
    
    static private func computedHashData(opaqueData: NSData?, bundleIdData: NSData?) -> NSData {
        let device = UIDevice.current
        var uuid = device.identifierForVendor?.uuid
        let address = withUnsafePointer(to: &uuid) {UnsafeRawPointer($0)}
        let data = NSData(bytes: address, length: 16)
        var hash = Array<UInt8>(repeating: 0, count: 20)
        var ctx = SHA_CTX()
        SHA1_Init(&ctx)
        SHA1_Update(&ctx, data.bytes, data.length)
        SHA1_Update(&ctx, opaqueData!.bytes, opaqueData!.length)
        SHA1_Update(&ctx, bundleIdData!.bytes, bundleIdData!.length)
        SHA1_Final(&hash, &ctx)
        return NSData(bytes: &hash, length: 20)
    }
}
