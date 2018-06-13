//
//  Logging.swift
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

func Log(_ input: Any = "", level: LogLevel, file: String = #file, function: String = #function, line: Int = #line, synchronously: Bool = false) {
    if level >= LogLevel.current {
        func logIt() {
            let filename = file.split(separator: "/").last.flatMap{String($0)} ?? "(unknown file)"
            var niceInput = String(describing: input)
            niceInput = niceInput.isEmpty ? "<empty string>" : niceInput
            let text = "\(filename) \(function) Line \(line): \(niceInput)"
            NSLog(text)
        }
        if synchronously {
            logIt()
        } else {
            loggingQueue.async { logIt() }
        }
    }
}

func VerboseLog(_ input: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
    Log(input, level: .verbose, file: file, function: function, line: line)
}

func DebugLog(_ input: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
    Log(input, level: .debug, file: file, function: function, line: line)
}

func InfoLog(_ input: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
    Log(input, level: .info, file: file, function: function, line: line)
}

func WarningLog(_ input: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
    Log(input, level: .warning, file: file, function: function, line: line)
}

func ErrorLog(_ input: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
    Log(input, level: .error, file: file, function: function, line: line)
}

enum LogLevel: Int, Comparable {
    
    case verbose
    case debug
    case info
    case warning
    case error
    
    static var current: LogLevel = .default
    
    #if DEBUG
    static let `default`: LogLevel = .debug
    #else
    static let `default`: LogLevel = .warning
    #endif
    
    static func ==(lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    static func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
}

private let loggingQueue = DispatchQueue(
    label: "com.blackpixel.IAP.logs",
    qos: .background,
    target: DispatchQueue.global(qos: .background)
)
