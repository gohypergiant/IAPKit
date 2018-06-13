//
//  HTTPDateClient.swift
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


enum HTTPDateClientError: Error {
    case invalidURLScheme
    case invalidResponse
    case missingDateField
    case dateParse
}

struct HTTPDateClient {

    enum Result {
        case success(Date)
        case error(Error)
    }

    private static let defaultHTTPURL = URL(string: "https://blackpixel.com")!

    private enum HTTPScheme: String {
        case http = "http"
        case https = "https"
    }

    private static let HTTPMethod = "HEAD"
    private static let dateField = "Date"

    typealias FetchDateCompletion = (_ result: Result) -> Void

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"

        // See: https://developer.apple.com/library/content/qa/qa1480/_index.html
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter
    }()

    /// Fetches the current date from an HTTP server by making a HEAD request.
    ///
    /// - Parameters:
    ///   - url: provide an HTTP `URL` or use the default of [https://blackpixel.com](https://blackpixel.com)
    ///   - completion: an async completion block which calls you back with `.success(Date)` or `.error(Error)`
    static func fetchDate(url: URL = defaultHTTPURL, completion: @escaping FetchDateCompletion) {
        guard let scheme = url.scheme, let _ = HTTPScheme(rawValue: scheme) else {
            completion(.error(HTTPDateClientError.invalidURLScheme))
            return
        }

        let request: URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod
            return request
        }()

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.error(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.error(HTTPDateClientError.invalidResponse))
                return
            }

            guard let dateString = response.allHeaderFields[dateField] as? String else {
                completion(.error(HTTPDateClientError.missingDateField))
                return
            }

            guard let date = dateFormatter.date(from: dateString) else {
                completion(.error(HTTPDateClientError.dateParse))
                return
            }

            completion(.success(date))
        }

        task.resume()
    }

}
