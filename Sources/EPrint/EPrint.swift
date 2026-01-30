//
//  EPrint.swift
//  EPrint - Enhanced Print Debugging
//
//  The main class providing simple, powerful print debugging.
//
//  Created: 2025
//  License: MIT
//  Author: @thomaah
//

import Foundation

// MARK: - Emoji System

/// Protocol for defining emoji types that can be used with EPrint.
///
/// Conform to this protocol to create custom emoji enums for your project.
/// EPrint provides a standard set via `Emoji.Standard`.
///
/// ## Example: Custom Emoji Enum
/// ```swift
/// enum MyProjectEmojis: String, EPrintEmoji {
///     case api = "🌐"
///     case database = "💾"
///     case cache = "⚡️"
///
///     var emoji: String { rawValue }
/// }
///
/// // Usage
/// eprint(.api, "Fetching data")  // "🌐 Fetching data"
/// ```
public protocol EPrintEmoji {
    /// The emoji character(s) to display
    var emoji: String { get }
}

/// Namespace for standard emoji types
public enum Emoji {
    
    /// Standard emoji set for common debugging scenarios.
    ///
    /// These emojis provide visual categorization of debug output:
    /// - `.start`: Beginning of an operation 🏁
    /// - `.success`: Successful completion ✅
    /// - `.error`: Error or failure ❌
    /// - `.warning`: Warning or caution ⚠️
    /// - `.info`: Informational message ℹ️
    /// - `.measurement`: Values, sizes, metrics 📏
    /// - `.observation`: State observation 👁️
    /// - `.action`: Action starting 🚀
    /// - `.inspection`: Deep inspection 🔍
    /// - `.metrics`: Performance data 📊
    /// - `.target`: Goals or targets 🎯
    /// - `.debug`: Debug-specific info 🐛
    /// - `.complete`: Completion 📦
    ///
    /// ## Example Usage
    /// ```swift
    /// private let eprint = EPrint.standard
    ///
    /// eprint(.start, "Beginning render")      // "🏁 Beginning render"
    /// eprint(.measurement, "Width: \(width)") // "📏 Width: 800"
    /// eprint(.success, "Render complete")     // "✅ Render complete"
    /// ```
    public enum Standard: String, EPrintEmoji {
        case start = "🏁"
        case success = "✅"
        case error = "❌"
        case warning = "⚠️"
        case info = "ℹ️"
        case measurement = "📏"
        case observation = "👁️"
        case action = "🚀"
        case inspection = "🔍"
        case metrics = "📊"
        case target = "🎯"
        case debug = "🐛"
        case complete = "📦"
        
        public var emoji: String { rawValue }
    }
}

/// Enhanced print debugging with emoji support and configurable output.
///
/// EPrint makes debugging output simple, flexible, and powerful. Use it anywhere you'd
/// normally use `print()`, but with the ability to toggle output, add metadata, and
/// send to multiple destinations.
///
/// ## Basic Usage
/// ```swift
/// // Quick debugging with shared instance
/// EPrint.shared("🏁 Starting render")
///
/// // Per-file instance with toggle
/// private let eprint = EPrint()
/// eprint("🏁 Starting render")
/// eprint.enabled = false  // Turn off
///
/// // Global control (affects all instances)
/// EPrint.globalEnabled = false  // Disable everywhere
/// EPrint.disableGlobally()      // Alternative syntax
///
/// // Override global in specific file
/// private let eprint = EPrint(activeState: .overrideGlobal)
///
/// // Convenience presets
/// private let eprint = EPrint.minimal    // Just message
/// private let eprint = EPrint.standard   // File and line
/// private let eprint = EPrint.verbose    // Everything
/// ```
///
/// ## Design Philosophy
/// - **Simple by default**: Works like `print()` out of the box
/// - **Powerful when needed**: Full configuration available
/// - **Zero cost when disabled**: Near-zero overhead when turned off
/// - **Thread-safe**: Safe to use from any thread
///
/// ## Thread Safety
/// EPrint uses a serial DispatchQueue internally to ensure thread-safe writes.
/// Multiple threads can call the same EPrint instance simultaneously without
/// data corruption or race conditions.
public final class EPrint: @unchecked Sendable {
    
    // MARK: - Debug Mode
    
    /// Controls internal debug output from EPrint itself.
    ///
    /// When `true`, EPrint will print its own internal debugging messages
    /// showing the flow of execution through the library. This is useful for
    /// debugging EPrint itself, not your application code.
    ///
    /// Default: `false`
    ///
    /// ## Example
    /// ```swift
    /// EPrint.debugMode = true
    /// eprint("Test")
    /// // Prints:
    /// // 🎯 EPrint.callAsFunction called Test
    /// // 📦 Creating EPrintEntry
    /// // ✍️ Writing to 1 outputs
    /// // Test
    /// // ✅ EPrint write complete
    /// ```
    public static var debugMode: Bool = false
    
    // MARK: - Global Control
    
    /// Global enable/disable flag affecting all EPrint instances.
    ///
    /// When set to `false`, all EPrint instances (except those with `.overrideGlobal`)
    /// will be disabled. This provides a single switch to control all debug output
    /// across your entire application.
    ///
    /// Default: `true`
    ///
    /// ## Example
    /// ```swift
    /// // Disable all EPrint output globally
    /// EPrint.globalEnabled = false
    ///
    /// // Re-enable
    /// EPrint.globalEnabled = true
    ///
    /// // Check status
    /// if EPrint.globalEnabled {
    ///     print("EPrint is globally enabled")
    /// }
    /// ```
    ///
    /// ## Thread Safety
    /// Access is synchronized via a static queue. Safe to read/write from any thread.
    public static var globalEnabled: Bool {
        get {
            globalQueue.sync { _globalEnabled }
        }
        set {
            globalQueue.sync { _globalEnabled = newValue }
        }
    }
    
    /// Internal storage for global enabled state
    private static var _globalEnabled: Bool = true
    
    /// Queue for thread-safe access to global state
    private static let globalQueue = DispatchQueue(
        label: "com.eprint.global",
        qos: .utility
    )
    
    /// Convenience method to disable EPrint globally.
    ///
    /// This is equivalent to `EPrint.globalEnabled = false`.
    ///
    /// ## Example
    /// ```swift
    /// EPrint.disableGlobally()
    /// // All EPrint instances are now silent
    /// ```
    public static func disableGlobally() {
        globalEnabled = false
    }
    
    /// Convenience method to enable EPrint globally.
    ///
    /// This is equivalent to `EPrint.globalEnabled = true`.
    ///
    /// ## Example
    /// ```swift
    /// EPrint.enableGlobally()
    /// // All EPrint instances are now active
    /// ```
    public static func enableGlobally() {
        globalEnabled = true
    }
    
    // MARK: - Active State
    
    /// Defines how an EPrint instance responds to the global enable/disable flag.
    ///
    /// This enum controls the relationship between an individual instance and the
    /// global `EPrint.globalEnabled` setting.
    ///
    /// ## Cases
    /// - `.enabled`: Instance is on and respects global state (default)
    /// - `.disabled`: Instance is always off, ignores global state
    /// - `.overrideGlobal`: Instance is always on, ignores global state
    ///
    /// ## Example
    /// ```swift
    /// // Normal behavior - respects global
    /// private let eprint = EPrint(activeState: .enabled)
    ///
    /// // Always off
    /// private let eprint = EPrint(activeState: .disabled)
    ///
    /// // Always on (with warning at init)
    /// private let eprint = EPrint(activeState: .overrideGlobal)
    /// // Prints: ⚠️ EPrint: Using .overrideGlobal - ignoring global state
    /// ```
    public enum ActiveState {
        /// Instance respects global enable/disable (default)
        case enabled
        
        /// Instance is always disabled
        case disabled
        
        /// Instance ignores global state and is always enabled
        case overrideGlobal
    }
    
    // MARK: - Properties
    
    /// The configuration controlling display behavior.
    ///
    /// This is mutable, allowing you to adjust settings at runtime.
    ///
    /// ## Example
    /// ```swift
    /// let eprint = EPrint()
    /// eprint.configuration.showTimestamp = true
    /// eprint("🏁 Now with timestamps")
    /// ```
    public var configuration: EPrintConfiguration {
        get {
            queue.sync { _configuration }
        }
        set {
            queue.sync { _configuration = newValue }
        }
    }
    
    /// The active state determining how this instance responds to global control.
    ///
    /// ## Example
    /// ```swift
    /// let eprint = EPrint()
    /// eprint.activeState = .disabled  // Turn off
    /// eprint.activeState = .overrideGlobal  // Always on
    /// ```
    public var activeState: ActiveState {
        get {
            queue.sync { _activeState }
        }
        set {
            queue.sync { _activeState = newValue }
        }
    }
    
    /// Convenience property for toggling output on/off.
    ///
    /// This provides a simple way to enable/disable without touching the full configuration.
    /// Setting this property maps to `.enabled` or `.disabled` active states.
    ///
    /// **Note**: For backward compatibility. Consider using `activeState` for more control.
    ///
    /// ## Example
    /// ```swift
    /// eprint.enabled = false  // Sets activeState to .disabled
    /// eprint.enabled = true   // Sets activeState to .enabled
    /// ```
    public var enabled: Bool {
        get {
            shouldPrint
        }
        set {
            activeState = newValue ? .enabled : .disabled
        }
    }
    
    // MARK: - Private Properties
    
    /// Internal storage for active state (thread-safe access via queue)
    private var _activeState: ActiveState
    
    /// Internal storage for configuration (thread-safe access via queue)
    private var _configuration: EPrintConfiguration
    
    /// Serial queue ensuring thread-safe access to configuration and writes
    ///
    /// This queue serializes all print operations, preventing race conditions
    /// and ensuring output integrity even under heavy concurrent use.
    private let queue: DispatchQueue
    
    /// Computed property determining if this instance should actually print.
    ///
    /// This evaluates the activeState against the global state AND configuration.enabled.
    /// Both must be true for output to occur (except for .overrideGlobal which bypasses everything).
    private var shouldPrint: Bool {
        // First check configuration's enabled flag (backward compatibility)
        let configEnabled = queue.sync { _configuration.enabled }
        
        // Evaluate activeState against global
        let stateEnabled: Bool
        switch queue.sync(execute: { _activeState }) {
        case .enabled:
            stateEnabled = EPrint.globalEnabled
        case .disabled:
            stateEnabled = false
        case .overrideGlobal:
            // Override bypasses both config and global
            return true
        }
        
        // Both config and state must be enabled (unless overridden)
        return configEnabled && stateEnabled
    }
    
    // MARK: - Initialization
    
    /// Creates a new EPrint instance with custom active state and configuration.
    ///
    /// This is the most flexible initializer, allowing full control over behavior.
    ///
    /// - Parameters:
    ///   - activeState: How this instance responds to global control (default: .enabled)
    ///   - configuration: The display configuration to use
    ///
    /// ## Example
    /// ```swift
    /// // Normal instance
    /// let eprint = EPrint(activeState: .enabled, configuration: .verbose)
    ///
    /// // Always-on instance (prints warning)
    /// let eprint = EPrint(activeState: .overrideGlobal, configuration: .standard)
    /// // Output: ⚠️ EPrint: Using .overrideGlobal - ignoring global state
    /// ```
    public init(
        activeState: ActiveState = .enabled,
        configuration: EPrintConfiguration = EPrintConfiguration()
    ) {
        self._activeState = activeState
        self._configuration = configuration
        self.queue = DispatchQueue(
            label: "com.eprint.queue.\(UUID().uuidString)",
            qos: .utility
        )
        
        // Print warning if overriding global
        if activeState == .overrideGlobal {
            print("⚠️ EPrint: Using .overrideGlobal - ignoring global state")
        }
    }
    
    /// Convenience initializer with individual settings.
    ///
    /// This provides a clean way to create an instance with specific settings
    /// without manually building a configuration.
    ///
    /// **Note**: This initializer always uses `.enabled` active state for backward compatibility.
    /// Use the main initializer if you need `.disabled` or `.overrideGlobal`.
    ///
    /// - Parameters:
    ///   - enabled: Master switch for output (default: true) - Note: Sets activeState, not configuration
    ///   - showFileName: Display file name (default: false)
    ///   - showLineNumber: Display line number (default: false)
    ///   - showFunction: Display function name (default: false)
    ///   - showTimestamp: Display timestamp (default: false)
    ///   - showThread: Display thread info (default: false)
    ///   - outputs: Output destinations (default: console only)
    ///
    /// ## Example
    /// ```swift
    /// let eprint = EPrint(
    ///     enabled: true,
    ///     showFileName: true,
    ///     showLineNumber: true
    /// )
    /// ```
    public convenience init(
        enabled: Bool = true,
        showFileName: Bool = false,
        showLineNumber: Bool = false,
        showFunction: Bool = false,
        showTimestamp: Bool = false,
        showThread: Bool = false,
        outputs: [any EPrintOutput] = [ConsoleOutput()]
    ) {
        let config = EPrintConfiguration(
            enabled: enabled,
            showFileName: showFileName,
            showLineNumber: showLineNumber,
            showFunction: showFunction,
            showTimestamp: showTimestamp,
            showThread: showThread,
            outputs: outputs
        )
        self.init(
            activeState: enabled ? .enabled : .disabled,
            configuration: config
        )
    }
    
    // MARK: - Main Print Function
    
    // MARK: - Main Print Functions
    
    /// Prints a debug message with a standard emoji prefix and captured metadata.
    ///
    /// This overload enables shorthand syntax for standard emojis using type inference.
    /// When you write `eprint(.start, "message")`, Swift infers `.start` as `Emoji.Standard.start`.
    ///
    /// - Parameters:
    ///   - emoji: A standard emoji (e.g., `.start`, `.success`, `.error`)
    ///   - message: The debug message to print
    ///   - file: Source file (automatically captured via #file)
    ///   - line: Line number (automatically captured via #line)
    ///   - function: Function name (automatically captured via #function)
    ///
    /// ## Example
    /// ```swift
    /// eprint(.start, "Beginning render")       // "🏁 Beginning render"
    /// eprint(.measurement, "Width: \(width)")  // "📏 Width: 800"
    /// eprint(.success, "Render complete")      // "✅ Render complete"
    /// ```
    public func callAsFunction(
        _ emoji: Emoji.Standard,
        _ message: String,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        // Prepend emoji to message with space
        let emojiMessage = "\(emoji.emoji) \(message)"
        
        // Call the main implementation
        callAsFunction(emojiMessage, file: file, line: line, function: function)
    }
    
    /// Prints a debug message with custom emoji prefix and captured metadata.
    ///
    /// This generic overload supports custom emoji enums that conform to `EPrintEmoji`.
    /// For custom emojis, you may need to be explicit about the type.
    ///
    /// - Parameters:
    ///   - emoji: A custom emoji from your project's emoji enum
    ///   - message: The debug message to print
    ///   - file: Source file (automatically captured via #file)
    ///   - line: Line number (automatically captured via #line)
    ///   - function: Function name (automatically captured via #function)
    ///
    /// ## Example
    /// ```swift
    /// enum MyEmojis: String, EPrintEmoji {
    ///     case api = "🌐"
    ///     case database = "💾"
    ///     var emoji: String { rawValue }
    /// }
    ///
    /// eprint(MyEmojis.api, "Fetching data")        // "🌐 Fetching data"
    /// eprint(MyEmojis.database, "Query complete")  // "💾 Query complete"
    /// ```
    public func callAsFunction<E: EPrintEmoji>(
        _ emoji: E,
        _ message: String,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        // Prepend emoji to message with space
        let emojiMessage = "\(emoji.emoji) \(message)"
        
        // Call the main implementation
        callAsFunction(emojiMessage, file: file, line: line, function: function)
    }
    
    /// Prints a debug message with captured metadata.
    ///
    /// This is the core function that captures file, line, function, timestamp, and
    /// thread information, then writes to all configured outputs.
    ///
    /// The use of `callAsFunction` allows calling EPrint instances like a function:
    /// `eprint("message")` instead of `eprint.print("message")`.
    ///
    /// For better visual categorization, consider using the emoji overload:
    /// `eprint(.start, "message")` instead of `eprint("🏁 message")`.
    ///
    /// - Parameters:
    ///   - message: The debug message to print
    ///   - file: Source file (automatically captured via #file)
    ///   - line: Line number (automatically captured via #line)
    ///   - function: Function name (automatically captured via #function)
    ///
    /// ## Example
    /// ```swift
    /// eprint("🏁 Starting render")
    /// eprint("📏 Width: \(width), Height: \(height)")
    /// eprint("✅ Render complete")
    /// ```
    public func callAsFunction(
        _ message: String,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        // Early exit if disabled - this keeps overhead minimal
        // We check this before doing ANY work (even string interpolation happens after this check)
        guard shouldPrint else { return }
        
        if EPrint.debugMode {
            print("🎯 EPrint.callAsFunction called", message)
        }
        
        // Capture current timestamp and thread info
        let timestamp = Date()
        let thread = captureThreadInfo()
        
        if EPrint.debugMode {
            print("📦 Creating EPrintEntry")
        }
        
        // Create the entry with all captured information
        let entry = EPrintEntry(
            message: message,
            file: file,
            line: line,
            function: function,
            timestamp: timestamp,
            thread: thread
        )
        
        // Write to all outputs (thread-safely)
        queue.async { [configuration] in
            if EPrint.debugMode {
                print("✍️ Writing to \(configuration.outputs.count) outputs")
            }
            for output in configuration.outputs {
                output.write(entry, config: configuration)
            }
            if EPrint.debugMode {
                print("✅ EPrint write complete")
            }
        }
    }
    
    // MARK: - Private Helpers
    
    /// Captures information about the current thread.
    ///
    /// This provides human-readable thread information for debugging.
    /// Handles both main thread and background threads.
    ///
    /// - Returns: Thread description string
    private func captureThreadInfo() -> String {
        let thread = Thread.current
        
        // Check if we're on the main thread
        if thread.isMainThread {
            return "main"
        }
        
        // For named threads, use the name
        if let name = thread.name, !name.isEmpty {
            return name
        }
        
        // For GCD queues, try to get the queue label
        if let queueLabel = String(validatingUTF8: __dispatch_queue_get_label(nil)) {
            return queueLabel
        }
        
        // Fallback: use thread description
        return thread.description
    }
    
    // MARK: - Shared Instance
    
    /// Shared instance for quick debugging without setup.
    ///
    /// This provides a global EPrint instance that's always available.
    /// Perfect for quick debugging sessions where you don't want to create
    /// an instance.
    ///
    /// Uses minimal configuration by default (just prints the message).
    ///
    /// ## Example
    /// ```swift
    /// EPrint.shared("🏁 Quick debug")
    /// EPrint.shared("📏 Width: \(width)")
    ///
    /// // Toggle on/off globally
    /// EPrint.shared.enabled = false
    /// ```
    public static let shared = EPrint()
    
    // MARK: - Convenience Presets
    
    /// Creates a minimal EPrint instance (message only, no metadata).
    ///
    /// This is the simplest configuration - just your debug messages with no
    /// additional information. Perfect for clean, uncluttered output.
    ///
    /// **Display**: Message only
    ///
    /// ## Example
    /// ```swift
    /// private let eprint = EPrint.minimal
    /// eprint("🏁 Starting render")
    /// // Output: 🏁 Starting render
    /// ```
    public static var minimal: EPrint {
        return EPrint(configuration: .minimal)
    }
    
    /// Creates a standard EPrint instance (file name and line number).
    ///
    /// This is the most common debugging configuration. Shows where the print
    /// came from without being too verbose.
    ///
    /// **Display**: File and line + message
    ///
    /// ## Example
    /// ```swift
    /// private let eprint = EPrint.standard
    /// eprint("🏁 Starting render")
    /// // Output: [PDFRenderer.swift:42] 🏁 Starting render
    /// ```
    public static var standard: EPrint {
        return EPrint(configuration: .standard)
    }
    
    /// Creates a verbose EPrint instance (all metadata enabled).
    ///
    /// Maximum information for deep debugging. Shows file, line, function,
    /// timestamp, and thread. Use when you need complete context.
    ///
    /// **Display**: File, line, function, timestamp, thread + message
    ///
    /// ## Example
    /// ```swift
    /// private let eprint = EPrint.verbose
    /// eprint("🏁 Starting render")
    /// // Output: [PDFRenderer.swift:42] [render(page:)] [14:23:45.123] [main] 🏁 Starting render
    /// ```
    public static var verbose: EPrint {
        return EPrint(configuration: .verbose)
    }
}

// MARK: - CustomStringConvertible

extension EPrint: CustomStringConvertible {
    
    /// Human-readable description of the EPrint instance.
    ///
    /// Useful for debugging your debugging setup! Shows the current configuration.
    ///
    /// ## Example Output
    /// ```
    /// EPrint(activeState: enabled, config: EPrintConfiguration(enabled: true, displays: [fileName, lineNumber], outputs: 1))
    /// ```
    public var description: String {
        let config = queue.sync { _configuration }
        let state = queue.sync { _activeState }
        return "EPrint(activeState: \(state), config: \(config))"
    }
}