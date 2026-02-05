//
//  EPrintConfiguration.swift
//  EPrint - Enhanced Print Debugging
//
//  Configuration system for controlling what metadata is displayed.
//
//  Created: 2025
//  License: MIT
//  Author: @thomaah
//

import Foundation

/// Configuration controlling how print entries are displayed.
///
/// EPrintConfiguration separates what data is **captured** (everything, always) from
/// what is **displayed** (user's choice). This allows for flexible debugging output
/// without losing information.
///
/// ## Design Philosophy
/// - **Capture Everything, Display Selectively**: All metadata is captured, but only
///   enabled fields are shown in output
/// - **Sensible Defaults**: By default, only the message is shown
/// - **Mutable**: Configuration can be changed at runtime
/// - **Preset Convenience**: Common configurations available as static properties
///
/// ## Example Usage
/// ```swift
/// // Minimal - just the message (default)
/// var config = EPrintConfiguration()
/// // Output: 🏁 Starting render
///
/// // Standard - add location
/// config.showFileName = true
/// config.showLineNumber = true
/// // Output: [PDFRenderer.swift:42] 🏁 Starting render
///
/// // Or use a preset
/// let config = EPrintConfiguration.verbose
/// // Output: [PDFRenderer.swift:42] [render()] [14:23:45] [main] 🏁 Starting render
/// ```
public struct EPrintConfiguration: Sendable {
    
    // MARK: - Master Control
    
    /// Master switch to enable or disable all output.
    ///
    /// When `false`, no output is produced and minimal work is done.
    /// This provides near-zero overhead for disabled debugging.
    ///
    /// Default: `true`
    public var enabled: Bool
    
    // MARK: - Display Flags
    
    /// Whether to show the source file name.
    ///
    /// When enabled, shows just the filename (not full path).
    ///
    /// Example: `[PDFRenderer.swift]`
    ///
    /// Default: `false`
    public var showFileName: Bool
    
    /// Whether to show the line number.
    ///
    /// When enabled with `showFileName`, formats as `[file:line]`.
    /// When enabled alone, formats as `[line 42]`.
    ///
    /// Example: `[PDFRenderer.swift:42]` or `[line 42]`
    ///
    /// Default: `false`
    public var showLineNumber: Bool
    
    /// Whether to show the function or method name.
    ///
    /// Displays the full function signature including parameter labels.
    ///
    /// Example: `[render(page:at:zoom:)]`
    ///
    /// Default: `false`
    public var showFunction: Bool
    
    /// Whether to show the timestamp.
    ///
    /// Displays time in HH:mm:ss.SSS format (24-hour with milliseconds).
    ///
    /// Example: `[14:23:45.123]`
    ///
    /// Default: `false`
    public var showTimestamp: Bool
    
    /// Whether to show the thread information.
    ///
    /// Displays a simplified thread name (e.g., "main" or "bg-qos").
    ///
    /// Example: `[main]`
    ///
    /// Default: `false`
    public var showThread: Bool
    
    /// Whether to show the category information.
    ///
    /// Displays the category tag for categorized prints.
    /// Uncategorized prints show no category.
    ///
    /// Example: `[rendering]` or `[network]`
    ///
    /// Default: `false` (enabled in `.standard` and `.verbose` presets)
    public var showCategory: Bool
    
    // MARK: - Output Destinations
    
    /// The output destinations where entries will be written.
    ///
    /// Supports multiple simultaneous outputs. For example, you can write to both
    /// console and a log file at the same time.
    ///
    /// Default: `[ConsoleOutput()]` (console only)
    ///
    /// ## Example
    /// ```swift
    /// config.outputs = [
    ///     ConsoleOutput(),
    ///     FileOutput(path: "debug.log")
    /// ]
    /// ```
    public var outputs: [any EPrintOutput]
    
    // MARK: - Initialization
    
    /// Creates a new configuration with custom settings.
    ///
    /// This is the most flexible initializer, allowing you to specify exactly
    /// what you want displayed.
    ///
    /// - Parameters:
    ///   - enabled: Master switch for all output (default: true)
    ///   - showFileName: Display file name (default: false)
    ///   - showLineNumber: Display line number (default: false)
    ///   - showFunction: Display function name (default: false)
    ///   - showTimestamp: Display timestamp (default: false)
    ///   - showThread: Display thread info (default: false)
    ///   - showCategory: Display category (default: false)
    ///   - outputs: Output destinations (default: console only)
    ///
    /// ## Example
    /// ```swift
    /// let config = EPrintConfiguration(
    ///     enabled: true,
    ///     showFileName: true,
    ///     showLineNumber: true,
    ///     showCategory: true,
    ///     outputs: [ConsoleOutput(), FileOutput(path: "debug.log")]
    /// )
    /// ```
    public init(
        enabled: Bool = true,
        showFileName: Bool = false,
        showLineNumber: Bool = false,
        showFunction: Bool = false,
        showTimestamp: Bool = false,
        showThread: Bool = false,
        showCategory: Bool = false,
        outputs: [any EPrintOutput] = [ConsoleOutput()]
    ) {
        self.enabled = enabled
        self.showFileName = showFileName
        self.showLineNumber = showLineNumber
        self.showFunction = showFunction
        self.showTimestamp = showTimestamp
        self.showThread = showThread
        self.showCategory = showCategory
        self.outputs = outputs
    }
    
    // MARK: - Convenience Presets
    
    /// Minimal configuration - just the message, no metadata.
    ///
    /// This is the default behavior and what most users want for simple debugging.
    /// Perfect for when you just want to see your debug messages without clutter.
    ///
    /// **Display**: Message only
    ///
    /// ## Example Output
    /// ```
    /// 🏁 Starting render
    /// 📏 Width: 800, Height: 1200
    /// ✅ Render complete
    /// ```
    ///
    /// ## Usage
    /// ```swift
    /// let eprint = EPrint.minimal
    /// eprint("🏁 Starting render")
    /// ```
    public static var minimal: EPrintConfiguration {
        return EPrintConfiguration(
            enabled: true,
            showFileName: false,
            showLineNumber: false,
            showFunction: false,
            showTimestamp: false,
            showThread: false
        )
    }
    
    /// Standard configuration - file name and line number.
    ///
    /// This is the most common debugging configuration. Shows where the print
    /// came from without being too verbose. Includes category information for
    /// filtering and organization.
    ///
    /// **Display**: File, line, category (if present) + message
    ///
    /// ## Example Output
    /// ```
    /// [PDFRenderer.swift:42] [rendering] 🏁 Starting render
    /// [PDFRenderer.swift:67] [layout] 📏 Width: 800, Height: 1200
    /// [PDFRenderer.swift:89] [performance] ⚡ Render took 45ms
    /// ```
    ///
    /// ## Usage
    /// ```swift
    /// let eprint = EPrint.standard
    /// eprint("🏁 Starting render", category: .rendering)
    /// ```
    public static var standard: EPrintConfiguration {
        return EPrintConfiguration(
            enabled: true,
            showFileName: true,
            showLineNumber: true,
            showFunction: false,
            showTimestamp: false,
            showThread: false,
            showCategory: true
        )
    }
    
    /// Verbose configuration - all metadata enabled.
    ///
    /// Maximum information for deep debugging. Shows file, line, function, timestamp,
    /// thread, and category. Useful for performance debugging, concurrency issues, or
    /// when you need complete context.
    ///
    /// **Display**: File, line, function, timestamp, thread, category + message
    ///
    /// ## Example Output
    /// ```
    /// [PDFRenderer.swift:42] [render(page:at:zoom:)] [14:23:45.123] [main] [rendering] 🏁 Starting render
    /// [PDFRenderer.swift:67] [calculateSize(for:)] [14:23:45.125] [main] [layout] 📏 Width: 800, Height: 1200
    /// [PDFRenderer.swift:89] [render(page:at:zoom:)] [14:23:45.456] [bg-qos] [performance] ⚡ Render took 45ms
    /// ```
    ///
    /// ## Usage
    /// ```swift
    /// let eprint = EPrint.verbose
    /// eprint("🏁 Starting render", category: .rendering)
    /// ```
    public static var verbose: EPrintConfiguration {
        return EPrintConfiguration(
            enabled: true,
            showFileName: true,
            showLineNumber: true,
            showFunction: true,
            showTimestamp: true,
            showThread: true,
            showCategory: true
        )
    }
}

// MARK: - Builder Pattern Convenience

extension EPrintConfiguration {
    
    /// Creates a configuration with specific display options enabled.
    ///
    /// This provides a fluent, readable way to create custom configurations
    /// without needing to specify every parameter.
    ///
    /// ## Example
    /// ```swift
    /// let config = EPrintConfiguration.with(
    ///     fileName: true,
    ///     lineNumber: true,
    ///     category: true,
    ///     timestamp: true
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - fileName: Show file name
    ///   - lineNumber: Show line number
    ///   - function: Show function name
    ///   - timestamp: Show timestamp
    ///   - thread: Show thread info
    ///   - category: Show category
    ///   - outputs: Output destinations
    /// - Returns: Configured instance
    public static func with(
        fileName: Bool = false,
        lineNumber: Bool = false,
        function: Bool = false,
        timestamp: Bool = false,
        thread: Bool = false,
        category: Bool = false,
        outputs: [any EPrintOutput] = [ConsoleOutput()]
    ) -> EPrintConfiguration {
        return EPrintConfiguration(
            enabled: true,
            showFileName: fileName,
            showLineNumber: lineNumber,
            showFunction: function,
            showTimestamp: timestamp,
            showThread: thread,
            showCategory: category,
            outputs: outputs
        )
    }
}

// MARK: - CustomStringConvertible

extension EPrintConfiguration: CustomStringConvertible {
    
    /// Human-readable description of the configuration.
    ///
    /// Useful for debugging the debugger! Shows what's enabled.
    ///
    /// ## Example Output
    /// ```
    /// EPrintConfiguration(enabled: true, displays: [fileName, lineNumber, category], outputs: 1)
    /// ```
    public var description: String {
        var displays: [String] = []
        
        if showFileName { displays.append("fileName") }
        if showLineNumber { displays.append("lineNumber") }
        if showFunction { displays.append("function") }
        if showTimestamp { displays.append("timestamp") }
        if showThread { displays.append("thread") }
        if showCategory { displays.append("category") }
        
        let displaysString = displays.isEmpty ? "none" : displays.joined(separator: ", ")
        
        return "EPrintConfiguration(enabled: \(enabled), displays: [\(displaysString)], outputs: \(outputs.count))"
    }
}

// MARK: - Equatable

extension EPrintConfiguration: Equatable {
    
    /// Compares two configurations for equality.
    ///
    /// Note: This compares display settings only, not the actual output instances.
    /// Two configs with the same settings but different output objects will be equal.
    public static func == (lhs: EPrintConfiguration, rhs: EPrintConfiguration) -> Bool {
        return lhs.enabled == rhs.enabled &&
               lhs.showFileName == rhs.showFileName &&
               lhs.showLineNumber == rhs.showLineNumber &&
               lhs.showFunction == rhs.showFunction &&
               lhs.showTimestamp == rhs.showTimestamp &&
               lhs.showThread == rhs.showThread &&
               lhs.showCategory == rhs.showCategory &&
               lhs.outputs.count == rhs.outputs.count
    }
}