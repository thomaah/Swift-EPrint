//
//  EPrint.swift
//  EPrint
//
//  Created on [Date]
//

import Foundation

/// A comprehensive debug printing library
public struct EPrint {
    
    /// Print a debug message
    /// - Parameter message: The message to print
    public static func print(_ message: String) {
        #if DEBUG
        Swift.print("[EPrint] \(message)")
        #endif
    }
    
    /// Print a debug message with a custom prefix
    /// - Parameters:
    ///   - prefix: Custom prefix for the message
    ///   - message: The message to print
    public static func print(prefix: String, _ message: String) {
        #if DEBUG
        Swift.print("[\(prefix)] \(message)")
        #endif
    }
}

