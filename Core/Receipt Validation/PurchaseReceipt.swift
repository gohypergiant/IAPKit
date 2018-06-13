//
//  IAPurchaseReceipt.swift
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

import OpenSSL.asn1
import OpenSSL.pkcs7
import OpenSSL.x509
import OpenSSL.sha


/// A general pupose object that contains the values parsed out of an ASN1 payload
/// for a purchased product.  The properties are optionals as the PurchaseReceipt encapsulates
/// 4 possible types of IAP product types (Consumable, Non-Consumable, Auto-Renewable Subscription and
/// Non-Renewing Subscription.  The ASN1 payload does not include any metadata as to which type
/// of purchase it is so there could be any combination of fields in the ASN1 payload depending on the type.
class PurchaseReceipt {
    var quantity: Int? = nil
    var productIdentifier: String? = nil
    var transactionIdentifier: String? = nil
    var originalTransactionIdentifier: String? = nil
    var purchaseDate: Date? = nil
    var originalPurchaseDate: Date? = nil
    var subscriptionExpirationDate: Date? = nil
    var cancellationDate: Date? = nil
    var webOrderLineItemID: Int? = nil
    
    init(with asn1Data: UnsafePointer<UInt8>, len: Int) {
        var ptr: UnsafePointer<UInt8>? = asn1Data
        let end = asn1Data.advanced(by: len)
        var type: Int32 = 0
        var xclass: Int32 = 0
        var length = 0
        ASN1_get_object(&ptr, &length, &type, &xclass, Int(len))
        guard type == V_ASN1_SET else {
            return
        }
        while ptr! < end {
            ASN1_get_object(&ptr, &length, &type, &xclass, ptr!.distance(to: end))
            guard type == V_ASN1_SEQUENCE else {
                return
            }
            
            guard let attrType = ASN1Helper.readInteger(pointer: &ptr, length: ptr!.distance(to: end)) else {
                return
            }
            
            guard let _ = ASN1Helper.readInteger(pointer: &ptr, length: ptr!.distance(to: end)) else {
                return
            }
            
            ASN1_get_object(&ptr, &length, &type, &xclass, ptr!.distance(to: end))
            guard type == V_ASN1_OCTET_STRING else {
                return
            }
            
            switch attrType {
            case 1701:
                var p = ptr
                self.quantity = ASN1Helper.readInteger(pointer: &p, length: length)
            case 1702:
                var p = ptr
                self.productIdentifier = ASN1Helper.readString(pointer: &p, length: length)
            case 1703:
                var p = ptr
                self.transactionIdentifier = ASN1Helper.readString(pointer: &p, length: length)
            case 1705:
                var p = ptr
                self.originalTransactionIdentifier = ASN1Helper.readString(pointer: &p, length: length)
            case 1704:
                var p = ptr
                self.purchaseDate = ASN1Helper.readDate(pointer: &p, length: length)
            case 1706:
                var p = ptr
                self.originalPurchaseDate = ASN1Helper.readDate(pointer: &p, length: length)
            case 1708:
                var p = ptr
                self.subscriptionExpirationDate = ASN1Helper.readDate(pointer: &p, length: length)
            case 1712:
                var p = ptr
                self.cancellationDate = ASN1Helper.readDate(pointer: &p, length: length)
            case 1711:
                var p = ptr
                self.webOrderLineItemID = ASN1Helper.readInteger(pointer: &p, length: length)
            default:
                break
            }
            ptr = ptr?.advanced(by: length)
        }
    }
}
