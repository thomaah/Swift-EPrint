//
//  EPrintCategory.swift
//  EPrint - Enhanced Print Debugging
//
//  Category-based filtering system for organizing debug output.
//
//  Created: 2025
//  License: MIT
//  Author: @thomaah
//

import Foundation

/// A lightweight category identifier for organizing debug output.
///
/// Categories provide a way to tag and filter debug messages, making it easy to:
/// - Enable/disable specific types of logging
/// - Search through logs by category
/// - Customize logging for different environments (debug, production, support)
///
/// ## Design Philosophy
/// - **Extensible**: Users can create custom categories via extensions
/// - **Type-Safe**: Categories are strongly typed, not magic strings
/// - **Lightweight**: Just a named identifier - no overhead
/// - **Thread-Safe**: Value type, inherently thread-safe
///
/// ## Built-in Categories
/// EPrint provides common categories out of the box:
/// - `.rendering`: Visual rendering operations
/// - `.layout`: Layout calculations and positioning
/// - `.performance`: Performance metrics and timing
/// - `.network`: Network requests and responses
/// - `.database`: Database queries and operations
/// - `.animation`: Animation state and transitions
/// - `.userInput`: User interaction events
/// - `.log`: General logging (default category)
/// - `.debug`: Debug-specific information
///
/// ## Creating Custom Categories
/// Extend EPrintCategory to add your app-specific categories:
/// ```swift
/// extension EPrintCategory {
///     static let authentication = EPrintCategory("authentication")
///     static let caching = EPrintCategory("caching")
///     static let analytics = EPrintCategory("analytics")
/// }
/// ```
///
/// ## Usage
/// ```swift
/// // Use built-in categories
/// eprint("Rendering frame", category: .rendering)
/// eprint("API request sent", category: .network)
///
/// // Use custom categories
/// eprint("User logged in", category: .authentication)
///
/// // Filter by category
/// EPrint.globalCategoryFilter = .only([.performance, .network])
/// eprint.categoryFilter = .except([.rendering])
/// ```
public struct EPrintCategory: Sendable, Hashable {
    
    /// The category identifier name
    public let name: String
    
    /// Creates a new category with the given name.
    ///
    /// This initializer is public, allowing users to create custom categories
    /// either inline or via extensions.
    ///
    /// - Parameter name: The category identifier
    ///
    /// ## Example
    /// ```swift
    /// // Inline creation
    /// let auth = EPrintCategory("authentication")
    ///
    /// // Or via extension (recommended)
    /// extension EPrintCategory {
    ///     static let authentication = EPrintCategory("authentication")
    /// }
    /// ```
    public init(_ name: String) {
        self.name = name
    }
    
    // MARK: - Standard Categories
    
    /// Rendering operations and visual updates
    ///
    /// Use for tracking rendering pipeline, frame updates, drawing operations.
    ///
    /// Example: `eprint("Rendering frame", category: .rendering)`
    public static let rendering = EPrintCategory("rendering")
    
    /// Layout calculations and positioning
    ///
    /// Use for layout engine operations, constraint solving, size calculations.
    ///
    /// Example: `eprint("Calculated bounds", category: .layout)`
    public static let layout = EPrintCategory("layout")
    
    /// Performance metrics and timing
    ///
    /// Use for timing measurements, performance analysis, profiling data.
    ///
    /// Example: `eprint("Operation took 45ms", category: .performance)`
    public static let performance = EPrintCategory("performance")
    
    /// Network requests and responses
    ///
    /// Use for API calls, network operations, HTTP requests.
    ///
    /// Example: `eprint("GET /api/users", category: .network)`
    public static let network = EPrintCategory("network")
    
    /// Database queries and operations
    ///
    /// Use for database access, queries, migrations, transactions.
    ///
    /// Example: `eprint("Fetching 100 records", category: .database)`
    public static let database = EPrintCategory("database")
    
    /// Animation state and transitions
    ///
    /// Use for animation updates, state transitions, motion tracking.
    ///
    /// Example: `eprint("Animation started", category: .animation)`
    public static let animation = EPrintCategory("animation")
    
    /// User interaction events
    ///
    /// Use for button taps, gestures, keyboard input, user actions.
    ///
    /// Example: `eprint("Button tapped", category: .userInput)`
    public static let userInput = EPrintCategory("userInput")
    
    /// General logging (default category)
    ///
    /// Use for general-purpose logging that doesn't fit other categories.
    ///
    /// Example: `eprint("App launched", category: .log)`
    public static let log = EPrintCategory("log")
    
    /// Debug-specific information
    ///
    /// Use for debug-only output, development information.
    ///
    /// Example: `eprint("Debug state dump", category: .debug)`
    public static let debug = EPrintCategory("debug")
}

// MARK: - CustomStringConvertible

extension EPrintCategory: CustomStringConvertible {
    /// Human-readable description of the category
    ///
    /// Returns just the category name for clean display.
    ///
    /// Example: `"rendering"`, `"network"`, `"authentication"`
    public var description: String {
        return name
    }
}

// MARK: - Category Filter

/// Defines which categories should be enabled for printing.
///
/// CategoryFilter provides flexible control over which categories produce output,
/// supporting both whitelist and blacklist approaches.
///
/// ## Design Philosophy
/// - **Flexible**: Supports multiple filtering strategies
/// - **Composable**: Works alongside the existing ActiveState system
/// - **Clear Semantics**: Each case has obvious behavior
/// - **Thread-Safe**: Sendable value type
///
/// ## Filter Behavior
/// - `.allEnabled`: All categories print (default, production-friendly)
/// - `.allDisabled`: No categories print (emergency shutdown)
/// - `.only([categories])`: Whitelist - only listed categories print
/// - `.except([categories])`: Blacklist - all except listed categories print
///
/// ## Usage Patterns
/// ```swift
/// // Development: See everything
/// EPrint.globalCategoryFilter = .allEnabled
///
/// // Production: Only critical categories
/// EPrint.globalCategoryFilter = .only([.performance, .network])
///
/// // Testing: Disable noisy categories
/// EPrint.globalCategoryFilter = .except([.rendering, .layout])
///
/// // Emergency: Disable everything
/// EPrint.globalCategoryFilter = .allDisabled
/// ```
///
/// ## Instance vs Global
/// Each EPrint instance can have its own category filter, and can override
/// the global filter using `.overrideGlobal` active state:
/// ```swift
/// // Set global filter
/// EPrint.globalCategoryFilter = .allDisabled
///
/// // But this instance overrides it
/// let debugLog = EPrint(activeState: .overrideGlobal)
/// debugLog.categoryFilter = .only([.debug])
/// ```
public enum CategoryFilter: Sendable {
    /// All categories are enabled (default).
    ///
    /// This is the most permissive setting - every categorized print will output.
    /// Perfect for development when you want to see everything.
    ///
    /// Messages without a category still print (they bypass category filtering).
    ///
    /// ## Example
    /// ```swift
    /// EPrint.globalCategoryFilter = .allEnabled
    /// eprint("Message", category: .rendering)  // ✅ Prints
    /// eprint("Message", category: .network)    // ✅ Prints
    /// eprint("Message")                        // ✅ Prints (no category)
    /// ```
    case allEnabled
    
    /// All categories are disabled.
    ///
    /// This is the most restrictive setting - no categorized prints will output.
    /// Use for emergency shutdown or when you want complete silence.
    ///
    /// Messages without a category still print (they bypass category filtering).
    ///
    /// ## Example
    /// ```swift
    /// EPrint.globalCategoryFilter = .allDisabled
    /// eprint("Message", category: .rendering)  // ❌ Silent
    /// eprint("Message", category: .network)    // ❌ Silent
    /// eprint("Message")                        // ✅ Prints (no category)
    /// ```
    case allDisabled
    
    /// Only specified categories are enabled (whitelist).
    ///
    /// This creates a whitelist - only the listed categories will print.
    /// All other categories are silenced. Perfect for focusing on specific
    /// subsystems or production logging.
    ///
    /// Messages without a category still print (they bypass category filtering).
    ///
    /// ## Example
    /// ```swift
    /// EPrint.globalCategoryFilter = .only([.performance, .network])
    /// eprint("Message", category: .performance)  // ✅ Prints
    /// eprint("Message", category: .network)      // ✅ Prints
    /// eprint("Message", category: .rendering)    // ❌ Silent
    /// eprint("Message")                          // ✅ Prints (no category)
    /// ```
    case only(Set<EPrintCategory>)
    
    /// All categories except specified ones are enabled (blacklist).
    ///
    /// This creates a blacklist - all categories print except the listed ones.
    /// Perfect for silencing noisy categories while keeping everything else.
    ///
    /// Messages without a category still print (they bypass category filtering).
    ///
    /// ## Example
    /// ```swift
    /// EPrint.globalCategoryFilter = .except([.rendering, .layout])
    /// eprint("Message", category: .performance)  // ✅ Prints
    /// eprint("Message", category: .network)      // ✅ Prints
    /// eprint("Message", category: .rendering)    // ❌ Silent
    /// eprint("Message")                          // ✅ Prints (no category)
    /// ```
    case except(Set<EPrintCategory>)
    
    // MARK: - Filter Logic
    
    /// Determines if a category should be enabled based on this filter.
    ///
    /// This is the core filtering logic. Given a category (or nil for uncategorized
    /// messages), it returns whether output should be produced.
    ///
    /// **Important**: Uncategorized messages (category == nil) always return true,
    /// bypassing category filtering entirely.
    ///
    /// - Parameter category: The category to check, or nil for uncategorized messages
    /// - Returns: True if this category should print, false otherwise
    ///
    /// ## Examples
    /// ```swift
    /// let filter = CategoryFilter.only([.network, .performance])
    ///
    /// filter.allows(.network)      // true
    /// filter.allows(.rendering)    // false
    /// filter.allows(nil)            // true (uncategorized always allowed)
    /// ```
    public func allows(_ category: EPrintCategory?) -> Bool {
        // Uncategorized messages always print - they bypass category filtering
        guard let category = category else {
            return true
        }
        
        // Apply the filter logic
        switch self {
        case .allEnabled:
            return true
            
        case .allDisabled:
            return false
            
        case .only(let allowed):
            return allowed.contains(category)
            
        case .except(let blocked):
            return !blocked.contains(category)
        }
    }
}

// MARK: - CategoryFilter Convenience

extension CategoryFilter {
    /// Creates a whitelist filter from a variadic list of categories.
    ///
    /// This provides a more ergonomic way to create `.only` filters without
    /// needing to construct a Set explicitly.
    ///
    /// - Parameter categories: The categories to whitelist
    /// - Returns: A `.only` filter with the specified categories
    ///
    /// ## Example
    /// ```swift
    /// // Instead of:
    /// let filter = CategoryFilter.only(Set([.network, .performance]))
    ///
    /// // You can write:
    /// let filter = CategoryFilter.only(.network, .performance)
    /// ```
    public static func only(_ categories: EPrintCategory...) -> CategoryFilter {
        return .only(Set(categories))
    }
    
    /// Creates a blacklist filter from a variadic list of categories.
    ///
    /// This provides a more ergonomic way to create `.except` filters without
    /// needing to construct a Set explicitly.
    ///
    /// - Parameter categories: The categories to blacklist
    /// - Returns: An `.except` filter with the specified categories
    ///
    /// ## Example
    /// ```swift
    /// // Instead of:
    /// let filter = CategoryFilter.except(Set([.rendering, .layout]))
    ///
    /// // You can write:
    /// let filter = CategoryFilter.except(.rendering, .layout)
    /// ```
    public static func except(_ categories: EPrintCategory...) -> CategoryFilter {
        return .except(Set(categories))
    }
}

// MARK: - CustomStringConvertible

extension CategoryFilter: CustomStringConvertible {
    /// Human-readable description of the filter
    ///
    /// Shows the filter type and affected categories.
    ///
    /// ## Example Output
    /// ```
    /// allEnabled
    /// allDisabled
    /// only([network, performance])
    /// except([rendering, layout])
    /// ```
    public var description: String {
        switch self {
        case .allEnabled:
            return "allEnabled"
            
        case .allDisabled:
            return "allDisabled"
            
        case .only(let categories):
            let names = categories.map { $0.name }.sorted().joined(separator: ", ")
            return "only([\(names)])"
            
        case .except(let categories):
            let names = categories.map { $0.name }.sorted().joined(separator: ", ")
            return "except([\(names)])"
        }
    }
}

// MARK: - Equatable

extension CategoryFilter: Equatable {
    /// Compares two category filters for equality
    public static func == (lhs: CategoryFilter, rhs: CategoryFilter) -> Bool {
        switch (lhs, rhs) {
        case (.allEnabled, .allEnabled):
            return true
        case (.allDisabled, .allDisabled):
            return true
        case (.only(let lhsSet), .only(let rhsSet)):
            return lhsSet == rhsSet
        case (.except(let lhsSet), .except(let rhsSet)):
            return lhsSet == rhsSet
        default:
            return false
        }
    }
}