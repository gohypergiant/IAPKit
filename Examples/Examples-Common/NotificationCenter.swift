//
//  NotificationCenter.swift
//  Examples
//
//  Created by Jared Sinclair on 8/26/17.
//  Copyright © 2017 Black Pixel Luminance. All rights reserved.
//

import Foundation

extension NotificationCenter {
    
    @discardableResult
    static func when(_ name: Notification.Name, perform action: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: action)
    }
    
}
