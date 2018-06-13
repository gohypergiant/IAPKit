//
//  OpenSSLObjectWrappers.swift
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

/// Wrapper classes to assist with reading data from
/// an iTunes Purchases Receipt.  The receipts are stored in a PKCS #7 container and
/// encoded using ASN.1.   We use C API to parse the data.
/// These wrappers for the C structs are to simplify the memory management.
/// Receipt validation code is based off the tutorial found at:
/// http://robin.github.io/swift/ios/2017/01/23/1-Local-Receipt-Validation-in-Swift-3/
class BIOWrapper {
    let bio = BIO_new(BIO_s_mem())
    init(data:NSData) {
        BIO_write(bio, data.bytes, Int32(data.length))
    }
    
    init() {}
    
    deinit {
        BIO_free(bio)
    }
}

class X509StoreWrapper {
    let store = X509_STORE_new()
    deinit {
        X509_STORE_free(store)
    }
    
    func addCert(x509:X509Wrapper) {
        X509_STORE_add_cert(store, x509.x509)
    }
}

class X509Wrapper {
    let x509 : UnsafeMutablePointer<X509>!
    init(data:NSData){
        let certBIO = BIOWrapper(data: data)
        x509 = d2i_X509_bio(certBIO.bio, nil)
    }
    
    deinit {
        X509_free(x509)
    }
}
