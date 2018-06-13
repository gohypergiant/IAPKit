//
//  ASN1Helper.swift
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

/// A helper class to ease the reading of data from an ASN1 payload
/// Receipt validation code is based off the tutorial found at:
/// http://robin.github.io/swift/ios/2017/01/23/1-Local-Receipt-Validation-in-Swift-3/
class ASN1Helper {

    static public func readInteger(pointer ptr: inout UnsafePointer<UInt8>?, length:Int) -> Int? {
        var type : Int32 = 0
        var xclass: Int32 = 0
        var len = 0
        ASN1_get_object(&ptr, &len, &type, &xclass, length)
        guard type == V_ASN1_INTEGER else {
            return nil
        }
        let integer = c2i_ASN1_INTEGER(nil, &ptr, len)
        let result = ASN1_INTEGER_get(integer)
        ASN1_INTEGER_free(integer)
        return result
    }
    
    static public func readString(pointer ptr: inout UnsafePointer<UInt8>?, length:Int) -> String? {
        var strLength = 0
        var type : Int32 = 0
        var xclass: Int32 = 0
        ASN1_get_object(&ptr, &strLength, &type, &xclass, length)
        if type == V_ASN1_UTF8STRING {
            let p = UnsafeMutableRawPointer(mutating: ptr!)
            return String(bytesNoCopy: p, length: strLength, encoding: String.Encoding.utf8, freeWhenDone: false)
        } else if type == V_ASN1_IA5STRING {
            let p = UnsafeMutableRawPointer(mutating: ptr!)
            return String(bytesNoCopy: p, length: strLength, encoding: String.Encoding.ascii, freeWhenDone: false)
        }
        return nil
    }
    
    static public func readDate(pointer ptr: inout UnsafePointer<UInt8>?, length:Int) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let dateString = ASN1Helper.readString(pointer: &ptr, length:length) {
            return dateFormatter.date(from: dateString)
        }
        return nil
    }
}
