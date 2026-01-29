//
//  EPrintEntry.swift
//  EPrint - Enhanced Print Debugging
//
//  A lightweight, protocol-based print debugging library with configurable output.
//
//  Created: 2025
//  License: MIT
//  Author: @thomaah
//

import Foundation

/// Represents a single print statement with all captured metadata.
///
/// EPrintEntry is an immutable data structure that captures everything about a print
/// statement at the moment it's called. This separation between capture and display
/// allows for flexible output formatting while preserving all information.
///
/// ## Design Philosophy
/// - **Capture Everything**: All metadata is always captured, regardless of display settings
/// - **Immutable**: Thread-safe by design - once created, never modified
/// - **Display Independent**: What's captured vs what's displayed are separate concerns
///
/// ## Example
/// ```swift
/// let entry = EPrintEntry(
///     message: "🏁 Starting render",
///     file: "PDFRenderer.swift",
///     line: 42,
///     function: "render(page:)",
///     timestamp: Date(),
///     thread: "main"
/// )
/// ```
public struct EPrintEntry: Sendable {
    
    // MARK: - Core Properties
    
    /// The user's message, including any emojis or formatting
    ///
    /// This is the raw string passed to EPrint, preserved exactly as provided.
    /// Users can include emojis, formatting, or any other content.
    ///
    /// Example: `"🏁 Starting render for page 5"`
    public let message: String
    
    /// The source file where EPrint was called
    ///
    /// Captured from `#file` or `#fileID` compiler directive.
    /// Typically includes the full path, but display can show just the filename.
    ///
    /// Example: `"/Users/tom/Projects/PDFViewer/PDFRenderer.swift"`
    public let file: String
    
    /// The line number where EPrint was called
    ///
    /// Captured from `#line` compiler directive.
    ///
    /// Example: `42`
    public let line: Int
    
    /// The function or method where EPrint was called
    ///
    /// Captured from `#function` compiler directive.
    /// Includes the full function signature.
    ///
    /// Example: `"render(page:at:zoom:)"` or `"viewDidLoad()"`
    public let function: String
    
    /// The exact timestamp when EPrint was called
    ///
    /// Useful for performance debugging, sequencing events, or time-based filtering.
    ///
    /// Example: `2025-01-29 14:23:45.123`
    public let timestamp: Date
    
    /// Information about the thread where EPrint was called
    ///
    /// Useful for debugging concurrency issues or understanding execution context.
    ///
    /// Example: `"main"` or `"com.apple.root.default-qos"`
    public let thread: String
    
    // MARK: - Initialization
    
    /// Creates a new print entry with all metadata
    ///
    /// This initializer is typically called by the EPrint class, not directly by users.
    /// All parameters are required to ensure complete capture of context.
    ///
    /// - Parameters:
    ///   - message: The user's debug message
    ///   - file: Source file path (from #file)
    ///   - line: Line number (from #line)
    ///   - function: Function name (from #function)
    ///   - timestamp: When the print occurred
    ///   - thread: Thread information
    public init(
        message: String,
        file: String,
        line: Int,
        function: String,
        timestamp: Date,
        thread: String
    ) {
        self.message = message
        self.file = file
        self.line = line
        self.function = function
        self.timestamp = timestamp
        self.thread = thread
    }
    
    // MARK: - Convenience Properties
    
    /// Extracts just the filename from the full file path
    ///
    /// This is useful for display purposes where the full path would be too verbose.
    ///
    /// Example:
    /// - Input: `"/Users/tom/Projects/PDFViewer/PDFRenderer.swift"`
    /// - Output: `"PDFRenderer.swift"`
    public var fileName: String {
        // Extract just the filename from the full path
        let components = file.split(separator: "/")
        return String(components.last ?? "")
    }
    
    /// A short, human-readable representation of the thread
    ///
    /// Simplifies thread names for cleaner display while preserving full info in `thread`.
    ///
    /// Example:
    /// - Main thread: `"main"`
    /// - Background: `"bg-qos"`
    public var threadName: String {
        // If it's the main thread, just say "main"
        if thread.contains("main") || thread.contains("<NSThread: 0x") && thread.contains("main") {
            return "main"
        }
        
        // For GCD queues, extract the meaningful part
        if thread.contains("com.apple.root") {
            let components = thread.split(separator: ".")
            if let last = components.last {
                return String(last)
            }
        }
        
        // Default: return as-is
        return thread
    }
}

// MARK: - CustomStringConvertible

extension EPrintEntry: CustomStringConvertible {
    /// A human-readable description of the entry
    ///
    /// This provides a default string representation that includes all captured information.
    /// Individual outputs can choose to format differently based on their configuration.
    ///
    /// Example output:
    /// ```
    /// [PDFRenderer.swift:42 render(page:at:zoom:)] [2025-01-29 14:23:45] [main] 🏁 Starting render
    /// ```
    public var description: String {
        let timestamp = ISO8601DateFormatter().string(from: self.timestamp)
        return "[\(fileName):\(line) \(function)] [\(timestamp)] [\(threadName)] \(message)"
    }
}

// MARK: - Equatable

extension EPrintEntry: Equatable {
    /// Compares two entries for equality
    ///
    /// Two entries are equal if all their properties match.
    /// Note: Timestamp comparison uses exact equality, which may be too strict for some use cases.
    public static func == (lhs: EPrintEntry, rhs: EPrintEntry) -> Bool {
        return lhs.message == rhs.message &&
               lhs.file == rhs.file &&
               lhs.line == rhs.line &&
               lhs.function == rhs.function &&
               lhs.timestamp == rhs.timestamp &&
               lhs.thread == rhs.thread
    }
}