//
//  EPrintOutput.swift
//  EPrint - Enhanced Print Debugging
//
//  Protocol-based output system for flexible print destinations.
//
//  Created: 2025
//  License: MIT
//  Author: @thomaah
//

import Foundation

/// Protocol defining how print entries are written to an output destination.
///
/// EPrintOutput is the core extension point of the EPrint system. By conforming to this
/// protocol, you can send debug output anywhere: console, files, databases, network, etc.
///
/// ## Design Philosophy
/// - **Single Responsibility**: Each output handles one destination
/// - **Configuration Aware**: Outputs respect display settings
/// - **Thread Safe**: Implementations must be thread-safe
/// - **Simple to Implement**: Minimal required functionality
///
/// ## Example Implementation
/// ```swift
/// struct CustomOutput: EPrintOutput {
///     func write(_ entry: EPrintEntry, config: EPrintConfiguration) {
///         // Your custom logic here
///         myLogger.log(format(entry, config: config))
///     }
/// }
/// ```
///
/// ## Built-in Implementations
/// - `ConsoleOutput`: Prints to standard output
/// - `FileOutput`: Writes to a file (future)
/// - `DatabaseOutput`: Writes to a database (future)
public protocol EPrintOutput: Sendable {
    
    /// Writes a print entry to this output destination.
    ///
    /// Implementations should:
    /// - Respect the configuration's display settings
    /// - Be thread-safe (may be called from multiple threads)
    /// - Handle errors gracefully (e.g., file write failures)
    /// - Be as efficient as possible
    ///
    /// - Parameters:
    ///   - entry: The captured print data
    ///   - config: Display configuration (what to show)
    func write(_ entry: EPrintEntry, config: EPrintConfiguration)
}

// MARK: - Console Output

/// Standard console output using Swift's `print()` function.
///
/// ConsoleOutput is the default output mechanism and what most users will use.
/// It formats entries based on configuration and writes to standard output.
///
/// ## Display Format
/// The output format is built dynamically based on configuration:
/// - If nothing is enabled: just the message
/// - If options are enabled: `[file:line] [function] [timestamp] [thread] [category] message`
///
/// ## Example Output
/// ```
/// // Minimal (default):
/// 🏁 Starting render
///
/// // With file and line:
/// [PDFRenderer.swift:42] 🏁 Starting render
///
/// // Full verbose with category:
/// [PDFRenderer.swift:42] [render(page:)] [14:23:45.123] [main] [rendering] 🏁 Starting render
/// ```
///
/// ## Thread Safety
/// Uses Swift's `print()` which is thread-safe. Multiple threads can safely write
/// simultaneously without corruption (though output may interleave).
public struct ConsoleOutput: EPrintOutput {
    
    /// Creates a new console output.
    ///
    /// Console output requires no configuration - it uses Swift's standard `print()`.
    public init() {
        // Nothing to configure - print() just works!
    }
    
    /// Writes an entry to the console.
    ///
    /// Formats the entry based on configuration and calls `print()`.
    ///
    /// - Parameters:
    ///   - entry: The print entry to write
    ///   - config: Configuration determining what to display
    public func write(_ entry: EPrintEntry, config: EPrintConfiguration) {
        // Build the output string based on what's enabled in config
        let output = format(entry, config: config)
        
        // Write to console
        print(output)
    }
    
    // MARK: - Private Formatting
    
    /// Formats an entry into a display string based on configuration.
    ///
    /// This is where we decide what to show based on the user's settings.
    /// We build up the string piece by piece, only adding enabled components.
    ///
    /// - Parameters:
    ///   - entry: The entry to format
    ///   - config: What to include in the output
    /// - Returns: Formatted string ready for display
    internal func format(_ entry: EPrintEntry, config: EPrintConfiguration) -> String {
        var components: [String] = []
        
        // File and line (shown together if either is enabled)
        if config.showFileName || config.showLineNumber {
            var fileInfo = ""
            
            if config.showFileName {
                fileInfo += entry.fileName
            }
            
            if config.showLineNumber {
                if config.showFileName {
                    fileInfo += ":\(entry.line)"
                } else {
                    fileInfo += "line \(entry.line)"
                }
            }
            
            components.append("[\(fileInfo)]")
        }

         // Category (NEW in v1.2.0)
        if config.showCategory {
            if let category = entry.category {
                components.append("[\(category.name)]")
            }
        }
        
        // Function name
        if config.showFunction {
            components.append("[\(entry.function)]")
        }
        
        // Timestamp
        if config.showTimestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            let timeString = formatter.string(from: entry.timestamp)
            components.append("[\(timeString)]")
        }
        
        // Thread
        if config.showThread {
            components.append("[\(entry.threadName)]")
        }
        
        // Category (NEW in v1.2.0)
        if config.showCategory {
            if let category = entry.category {
                components.append("[\(category.name)]")
            }
        }
        
        // Combine metadata components with the message
        if components.isEmpty {
            // No metadata - just the message
            return entry.message
        } else {
            // Metadata + message
            let metadata = components.joined(separator: " ")
            return "\(metadata) \(entry.message)"
        }
    }
}

// MARK: - File Output (Stub for Future Implementation)

/// File output for writing print entries to a log file.
///
/// ⚠️ **Status**: Stub implementation - not yet functional
///
/// This is a placeholder for future file-based logging. When implemented, it will:
/// - Write formatted entries to a specified file path
/// - Handle file creation, rotation, and cleanup
/// - Be thread-safe using serial DispatchQueue
/// - Support append vs overwrite modes
///
/// ## Future Usage
/// ```swift
/// let fileOutput = FileOutput(path: "/tmp/debug.log")
/// let eprint = EPrint(outputs: [ConsoleOutput(), fileOutput])
/// ```
public struct FileOutput: EPrintOutput {
    
    /// The file path where logs will be written
    public let path: String
    
    /// Creates a new file output.
    ///
    /// - Parameter path: The file path for log output
    public init(path: String) {
        self.path = path
        print("⚠️ FileOutput created but not yet implemented - logs will not be written to \(path)")
    }
    
    /// Writes an entry to the file.
    ///
    /// ⚠️ Currently a no-op stub. Will be implemented in a future version.
    ///
    /// - Parameters:
    ///   - entry: The print entry to write
    ///   - config: Configuration determining what to display
    public func write(_ entry: EPrintEntry, config: EPrintConfiguration) {
        // TODO: Implement file writing
        // Will need:
        // - Thread-safe file handle management
        // - Serial DispatchQueue for writes
        // - Error handling for disk full, permissions, etc.
        // - Optional file rotation
    }
}

// MARK: - Helper Extensions

extension EPrintOutput {
    
    /// Default formatting helper available to all outputs.
    ///
    /// This provides a standard way to format entries that any output can use.
    /// Outputs can call this or implement their own formatting logic.
    ///
    /// - Parameters:
    ///   - entry: The entry to format
    ///   - config: What to include
    /// - Returns: Formatted string
    internal func defaultFormat(_ entry: EPrintEntry, config: EPrintConfiguration) -> String {
        // Use ConsoleOutput's formatting logic as the default
        let console = ConsoleOutput()
        return console.format(entry, config: config)
    }
}