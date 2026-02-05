# EPrint 🎯

**Enhanced Print Debugging for Swift** (v1.2.1)

A lightweight, protocol-based print debugging library with emoji support, category filtering, configurable output, and zero overhead when disabled. Make your debug output beautiful, informative, and production-ready.

[![Swift Version](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20watchOS%20|%20tvOS%20|%20Linux-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager)

---

## Why EPrint? 🤔

Traditional `print()` statements are great, but they have limitations:
- ❌ Can't easily toggle on/off per file
- ❌ No control over what metadata is shown
- ❌ Difficult to send output to multiple destinations
- ❌ No way to filter or organize debug output
- ❌ Hard to remove before shipping

**EPrint solves all of these problems** while keeping the simplicity of `print()`.

---

## Features ✨

- 🎯 **Dead Simple** - Works just like `print()`, but better
- 🏷️ **Category System** - Organize and filter by category (.rendering, .network, etc.) (v1.2.0)
- 🎛️ **Flexible Filtering** - Whitelist or blacklist categories globally or per-instance (v1.2.0)
- 🌐 **Global Control** - Disable all EPrint output with one line (v1.1.1)
- 🔓 **Override System** - Keep specific files enabled even when globally disabled (v1.1.1)
- 🔌 **Per-File Toggle** - Enable/disable debugging per file with one line
- 📊 **Rich Metadata** - Optionally show file, line, function, timestamp, thread, category
- 🎨 **Emoji Support** - Use emojis to visually categorize your debug output
- 🚀 **Zero Cost When Disabled** - Near-zero overhead when turned off
- 🧵 **Thread Safe** - Safe to use from any thread
- 🔧 **Extensible** - Protocol-based outputs (console, file, custom)
- ⚙️ **Configurable** - Three presets + full customization
- 🌍 **Cross-Platform** - Works on iOS, macOS, watchOS, tvOS, and Linux
- 📦 **No Dependencies** - Foundation only

---

## What's New in v1.2.0 🎉

### Category System
Organize and filter debug output by category for powerful logging control:

```swift
// Tag prints with categories
eprint("Frame rendered", category: .rendering)
eprint("API call complete", category: .network)
eprint("Cache hit", category: .caching)

// Filter globally
EPrint.enableCategories(.performance, .network)  // Production
EPrint.disableCategories(.rendering, .layout)     // Testing

// Filter per instance
let debugLog = EPrint()
debugLog.categoryFilter = .only([.debug, .performance])
```

**Built-in categories**: `.rendering`, `.layout`, `.performance`, `.network`, `.database`, `.animation`, `.userInput`, `.log`, `.debug`

**Create custom categories**:
```swift
extension EPrintCategory {
    static let authentication = EPrintCategory("authentication")
    static let caching = EPrintCategory("caching")
}
```

**Perfect for**:
- Different logging for development vs production
- Focus on specific subsystems
- Dynamic filtering for support scenarios
- Searchable log files

See the [Category System](#category-system-️) section for complete documentation.

---

## What's in v1.1.1

### Global Control System
Control all EPrint output across your entire application with a single switch:

```swift
// Disable ALL EPrint output everywhere
EPrint.globalEnabled = false

// Or use the convenience method
EPrint.disableGlobally()

// Re-enable everything
EPrint.enableGlobally()
```

### Override System
Need one file to keep printing even when globally disabled? Use `.overrideGlobal`:

```swift
// This file will ALWAYS print, even if globally disabled
private let eprint = EPrint(activeState: .overrideGlobal)
// Prints: ⚠️ EPrint: Using .overrideGlobal - ignoring global state

// Now this eprint will work regardless of EPrint.globalEnabled
eprint(.start, "This always prints!")
```

### Active State Enum
More control over how instances respond to global settings:

```swift
// Respects global setting (default)
private let eprint = EPrint(activeState: .enabled)

// Always off, ignores global
private let eprint = EPrint(activeState: .disabled)

// Always on, ignores global (with warning)
private let eprint = EPrint(activeState: .overrideGlobal)
```

---

## Installation 📦

### Swift Package Manager

Add EPrint to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/thomaah/EPrint.git", from: "1.2.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/thomaah/EPrint.git`
3. Select version 1.1.1 or later

---

## Quick Start 🚀

### Simplest Usage - Global Instance
```swift
import EPrint

// Use the shared instance with type-safe emojis (recommended)
EPrint.shared(.start, "Starting operation")
EPrint.shared(.measurement, "Width: \(width), Height: \(height)")
EPrint.shared(.success, "Operation complete")
```

**Output:**
```
🏁 Starting operation
📏 Width: 800, Height: 1200
✅ Operation complete
```

### Per-File Instance (Recommended)
```swift
import EPrint

// Create a per-file instance at the top of your file
private let eprint = EPrint.standard

class PDFRenderer {
    func render(page: Int) {
        eprint(.start, "Starting render for page \(page)")
        
        let size = calculateSize()
        eprint(.measurement, "Calculated size: \(size)")
        
        // ... your code ...
        
        eprint(.success, "Render complete")
    }
}

// Toggle debugging for this entire file
// eprint.enabled = false  // Uncomment to disable
```

### Global Control (New in v1.1.1)
```swift
// In your app startup or settings
EPrint.disableGlobally()  // Turn off ALL EPrint output

// Or use property syntax
EPrint.globalEnabled = false

// Re-enable when needed
EPrint.enableGlobally()
```

### Override Global (New in v1.1.1)
```swift
// In a critical debugging file that should ALWAYS print
private let eprint = EPrint(
    activeState: .overrideGlobal,
    configuration: .standard
)
// Prints: ⚠️ EPrint: Using .overrideGlobal - ignoring global state

// This file will now print even when EPrint.globalEnabled = false
eprint(.start, "This always prints!")
```

---

## Emoji System 🎨

EPrint provides a type-safe emoji system for visually categorizing debug output. This is the recommended way to use EPrint as it provides compile-time safety and cleaner code.

### Standard Emojis

EPrint includes a standard set of emojis via `Emoji.Standard`:

| Emoji | Case | Usage |
|-------|------|-------|
| 🏁 | `.start` | Beginning of an operation |
| ✅ | `.success` | Successful completion |
| ❌ | `.error` | Error or failure |
| ⚠️ | `.warning` | Warning or caution |
| ℹ️ | `.info` | Informational message |
| 📏 | `.measurement` | Values, sizes, metrics |
| 👁️ | `.observation` | State observation |
| 🚀 | `.action` | Action starting |
| 🔍 | `.inspection` | Deep inspection |
| 📊 | `.metrics` | Performance data |
| 🎯 | `.target` | Goals or targets |
| 🐛 | `.debug` | Debug-specific info |
| 📦 | `.complete` | Completion |

### Using Standard Emojis

```swift
private let eprint = EPrint.standard

func processData() {
    eprint(.start, "Processing data")
    eprint(.measurement, "Processing \(count) items")
    
    if error {
        eprint(.error, "Failed to process: \(error)")
        return
    }
    
    eprint(.success, "Processing complete")
}
```

**Output:**
```
[DataProcessor.swift:15] 🏁 Processing data
[DataProcessor.swift:16] 📏 Processing 1000 items
[DataProcessor.swift:24] ✅ Processing complete
```

### Creating Custom Emoji Enums

Create your own emoji enums for project-specific categorization:

```swift
import EPrint

// Define your custom emoji enum
enum MyProjectEmojis: String, EPrintEmoji {
    case api = "🌐"
    case database = "💾"
    case cache = "⚡️"
    case network = "📡"
    case auth = "🔐"
    
    var emoji: String { rawValue }
}

// Use throughout your project
private let eprint = EPrint.standard

func fetchUser() {
    eprint(.api, "Fetching user data")          // "🌐 Fetching user data"
    eprint(.database, "Querying database")      // "💾 Querying database"
    eprint(.cache, "Cache hit!")                // "⚡️ Cache hit!"
}
```

### Mixing Standard and Custom Emojis

You can use both standard and custom emojis in the same file:

```swift
enum APIEmojis: String, EPrintEmoji {
    case request = "📤"
    case response = "📥"
    var emoji: String { rawValue }
}

func makeRequest() {
    eprint(.start, "Making API call")           // Standard: 🏁
    eprint(.request, "POST /api/users")         // Custom: 📤
    eprint(.response, "200 OK")                 // Custom: 📥
    eprint(.success, "Request complete")        // Standard: ✅
}
```

### Legacy String Syntax

The old way of manually adding emojis still works:

```swift
// Still supported
eprint("🏁 Starting render")
eprint("📏 Width: \(width)")

// But the new way is recommended
eprint(.start, "Starting render")
eprint(.measurement, "Width: \(width)")
```

---

## Category System 🏷️

**New in v1.2.0**: Organize and filter debug output by category for powerful logging control across development, production, and support scenarios.

### The Problem

Debug output can quickly become overwhelming. You might need:
- Different logging for **development** vs **production**
- The ability to **focus on specific subsystems** (rendering, network, database)
- **Dynamic filtering** for support scenarios (enable performance logs remotely)
- **Search and filtering** through large log files

The category system solves all of these.

### Quick Start

```swift
private let eprint = EPrint.standard  // Shows categories by default

// Tag prints with categories
eprint("Starting render", category: .rendering)
eprint("API request sent", category: .network)
eprint("Layout calculated", category: .layout)
```

**Output:**
```
[PDFRenderer.swift:42] [rendering] Starting render
[APIClient.swift:89] [network] API request sent
[LayoutEngine.swift:156] [layout] Layout calculated
```

### Built-in Categories

EPrint provides common categories out of the box:

| Category | Purpose | Example Usage |
|----------|---------|---------------|
| `.rendering` | Visual rendering operations | Frame updates, drawing |
| `.layout` | Layout calculations | Constraint solving, sizing |
| `.performance` | Performance metrics | Timing, profiling |
| `.network` | Network operations | API calls, requests |
| `.database` | Database operations | Queries, transactions |
| `.animation` | Animation state | State transitions, motion |
| `.userInput` | User interactions | Taps, gestures |
| `.log` | General logging | Default category |
| `.debug` | Debug information | Development-only |

### Creating Custom Categories

Extend `EPrintCategory` to add your app-specific categories:

```swift
import EPrint

extension EPrintCategory {
    static let authentication = EPrintCategory("authentication")
    static let caching = EPrintCategory("caching")
    static let analytics = EPrintCategory("analytics")
    static let payment = EPrintCategory("payment")
}

// Use like built-in categories
eprint("User logged in", category: .authentication)
eprint("Cache hit", category: .caching)
```

### Filtering Categories

Control which categories print using powerful filtering options:

#### Global Filtering

Affects all EPrint instances (except those with `.overrideGlobal`):

```swift
// Development: See everything
EPrint.globalCategoryFilter = .allEnabled

// Production: Only critical categories
EPrint.enableCategories(.performance, .network)
// Equivalent to:
EPrint.globalCategoryFilter = .only([.performance, .network])

// Testing: Hide noisy categories
EPrint.disableCategories(.rendering, .layout)
// Equivalent to:
EPrint.globalCategoryFilter = .except([.rendering, .layout])

// Emergency: Disable all categorized output
EPrint.disableAllCategories()
```

#### Instance Filtering

Each instance can have its own filter:

```swift
let renderLog = EPrint.standard
renderLog.categoryFilter = .only([.rendering, .performance])
renderLog("Starting render", category: .rendering)  // ✅ Prints
renderLog("API call", category: .network)           // ❌ Silent

// Use with .overrideGlobal to ignore global filter
let debugLog = EPrint(activeState: .overrideGlobal)
debugLog.categoryFilter = .only([.debug])
// Now prints ONLY .debug category, regardless of global settings
```

### Filter Strategies

Four filtering strategies cover all use cases:

| Filter | Behavior | Use Case |
|--------|----------|----------|
| `.allEnabled` | All categories print | Development (default) |
| `.allDisabled` | No categories print | Emergency shutdown |
| `.only([...])` | Whitelist specific categories | Production logging |
| `.except([...])` | Blacklist specific categories | Hide noisy output |

**Important**: Uncategorized prints (no `category:` parameter) always bypass category filters. This ensures critical messages always print.

### Real-World Workflows

#### Development Environment
```swift
#if DEBUG
EPrint.globalCategoryFilter = .allEnabled  // See everything
#endif

eprint("Frame rendered", category: .rendering)
eprint("API call complete", category: .network)
// Both print in development
```

#### Production Environment
```swift
#if RELEASE
EPrint.enableCategories(.performance, .network)  // Only critical logs
#endif

eprint("Frame rendered", category: .rendering)      // ❌ Silent
eprint("API took 450ms", category: .performance)    // ✅ Prints
eprint("Network error", category: .network)         // ✅ Prints
```

#### Support/Debugging Mode
```swift
// User reports performance issue
// Enable performance logging remotely:
func enablePerformanceDebugging() {
    EPrint.enableCategories(.performance, .layout, .rendering)
}

// Or create dedicated support logger
let supportLog = EPrint(
    activeState: .overrideGlobal,
    configuration: .verbose
)
supportLog.categoryFilter = .only([.performance, .network])
```

#### Testing - Hide Noisy Output
```swift
// In test setup
override func setUp() {
    super.setUp()
    // Hide rendering logs during tests
    EPrint.disableCategories(.rendering, .animation)
}
```

### Category Display

Categories appear in output when `showCategory` is enabled:

```swift
// Minimal config - no category display
let eprint = EPrint.minimal
eprint("Message", category: .rendering)
// Output: Message

// Standard config - shows categories (default)
let eprint = EPrint.standard
eprint("Message", category: .rendering)
// Output: [File.swift:42] [rendering] Message

// Verbose config - shows everything including category
let eprint = EPrint.verbose
eprint("Message", category: .rendering)
// Output: [File.swift:42] [function()] [14:23:45.123] [main] [rendering] Message

// Custom - disable category display
let eprint = EPrint(configuration: .with(
    fileName: true,
    lineNumber: true,
    category: false  // Disable category display
))
```

### Searching and Filtering Logs

Categories make log files searchable:

```bash
# Search for all performance logs
grep "\[performance\]" debug.log

# Search for network issues
grep "\[network\]" debug.log | grep -i error

# Count rendering operations
grep -c "\[rendering\]" debug.log

# Multiple categories
grep -E "\[performance\]|\[network\]" debug.log
```

### Best Practices

1. **Use Categories Consistently**: Pick standard categories for your team
   ```swift
   extension EPrintCategory {
       static let api = EPrintCategory("api")
       static let db = EPrintCategory("db")
   }
   ```

2. **Tag Critical Logs**: Always categorize important output
   ```swift
   // ✅ Good - categorized
   eprint("Payment processed", category: .payment)
   
   // ⚠️ Less useful - uncategorized (but still works)
   eprint("Payment processed")
   ```

3. **Use Uncategorized for Must-Print**: Skip category for output that should always print
   ```swift
   // No category = bypasses all filters
   eprint(.error, "Critical: Database connection lost")
   ```

4. **Environment-Specific Filters**: Different filters for different builds
   ```swift
   #if DEBUG
   EPrint.globalCategoryFilter = .allEnabled
   #elseif RELEASE
   EPrint.enableCategories(.performance, .network)
   #endif
   ```

5. **Document Your Categories**: Help your team understand what to use
   ```swift
   extension EPrintCategory {
       /// Backend API communication
       static let api = EPrintCategory("api")
       
       /// Local database operations
       static let database = EPrintCategory("database")
       
       /// User analytics events
       static let analytics = EPrintCategory("analytics")
   }
   ```

### Complete Example

```swift
import EPrint

// Define app categories
extension EPrintCategory {
    static let api = EPrintCategory("api")
    static let cache = EPrintCategory("cache")
    static let auth = EPrintCategory("auth")
}

// Production config
#if RELEASE
EPrint.enableCategories(.api, .auth, .performance)
#endif

class APIClient {
    private let eprint = EPrint.standard
    
    func fetchUser(_ id: String) {
        eprint(.start, "Fetching user", category: .api)
        
        // Check cache first
        if let cached = cache.get(id) {
            eprint(.success, "Cache hit", category: .cache)  // Hidden in production
            return cached
        }
        
        let start = Date()
        makeNetworkRequest(id) { result in
            let duration = Date().timeIntervalSince(start)
            
            switch result {
            case .success(let user):
                eprint(.success, "User fetched", category: .api)  // Prints in production
                eprint(.metrics, "Request took \(duration)ms", category: .performance)  // Prints in production
            case .failure(let error):
                eprint(.error, "Fetch failed: \(error)", category: .api)  // Prints in production
            }
        }
    }
}
```

**Production Output** (only `.api`, `.auth`, `.performance` categories):
```
[APIClient.swift:12] [api] 🏁 Fetching user
[APIClient.swift:26] [api] ✅ User fetched  
[APIClient.swift:27] [performance] 📊 Request took 234ms
```

---

## Usage Guide 📖

### Three Convenience Presets

EPrint comes with three built-in presets for common debugging scenarios:

#### 1. Minimal (Default) - Message Only
```swift
private let eprint = EPrint.minimal
eprint(.start, "Starting render")
```

**Output:**
```
🏁 Starting render
```

#### 2. Standard - File, Line, and Category
```swift
private let eprint = EPrint.standard
eprint(.start, "Starting render", category: .rendering)
```

**Output:**
```
[PDFRenderer.swift:42] [rendering] 🏁 Starting render
```

#### 3. Verbose - Everything
```swift
private let eprint = EPrint.verbose
eprint(.start, "Starting render", category: .rendering)
```

**Output:**
```
[PDFRenderer.swift:42] [render(page:)] [14:23:45.123] [main] [rendering] 🏁 Starting render
```

### Custom Configuration

Build exactly the configuration you need:
```swift
private let eprint = EPrint(
    activeState: .enabled,  // New in v1.1.1
    configuration: EPrintConfiguration(
        showFileName: true,
        showLineNumber: true,
        showTimestamp: true
    )
)
eprint(.start, "Starting render")
```

**Output:**
```
[PDFRenderer.swift:42] [14:23:45.123] 🏁 Starting render
```

### Toggling On/Off
```swift
private let eprint = EPrint()

// Per-instance control
eprint.enabled = false  // Turn off this instance

// Or use active state
eprint.activeState = .disabled  // Same effect

// Global control (v1.1.1)
EPrint.globalEnabled = false  // Turn off ALL instances

// Toggle based on conditions
eprint.enabled = isDebugMode
eprint.enabled = pageIndex == 5  // Only debug page 5
```

---

## Advanced Features 🔧

### Global Control Strategies (v1.1.1)

```swift
// Strategy 1: Global toggle based on build configuration
#if DEBUG
EPrint.globalEnabled = true
#else
EPrint.globalEnabled = false
#endif

// Strategy 2: Runtime control via settings
if UserDefaults.standard.bool(forKey: "enableDebugLogging") {
    EPrint.enableGlobally()
} else {
    EPrint.disableGlobally()
}

// Strategy 3: Critical debugging files override global
// In CriticalDebugFile.swift:
private let eprint = EPrint(activeState: .overrideGlobal)
// This file always prints, even when globally disabled
```

### Multiple Outputs

Send debug output to multiple destinations simultaneously:
```swift
let consoleOutput = ConsoleOutput()
let fileOutput = FileOutput(path: "/tmp/debug.log")

private let eprint = EPrint(
    configuration: EPrintConfiguration(
        outputs: [consoleOutput, fileOutput]
    )
)

// Now prints to BOTH console and file
eprint("🏁 This goes everywhere")
```

### Custom Outputs

Create your own output destinations by conforming to `EPrintOutput`:
```swift
struct NetworkOutput: EPrintOutput {
    func write(_ entry: EPrintEntry, config: EPrintConfiguration) {
        // Send debug output to your logging service
        logService.send(entry.message)
    }
}
```

### Dynamic Configuration

Change configuration at runtime:
```swift
private let eprint = EPrint.minimal

func enableVerboseLogging() {
    eprint.configuration = .verbose
}

func toggleTimestamps() {
    eprint.configuration.showTimestamp.toggle()
}
```

### Builder Pattern

Use the builder pattern for clean configuration:
```swift
private let eprint = EPrint(
    configuration: .with(
        fileName: true,
        lineNumber: true,
        timestamp: true
    )
)
```

---

## Real-World Examples 🌍

### PDF Rendering
```swift
import EPrint

private let eprint = EPrint.standard

class PDFRenderer {
    func render(page: Int, zoom: Double) {
        eprint(.start, "Starting render - page: \(page), zoom: \(zoom)")
        
        let startTime = Date()
        
        guard let document = loadDocument() else {
            eprint(.error, "Failed to load document")
            return
        }
        
        eprint(.measurement, "Document size: \(document.pageCount) pages")
        
        let image = renderPage(page, at: zoom)
        
        let duration = Date().timeIntervalSince(startTime)
        eprint(.success, "Render complete in \(String(format: "%.2f", duration))s")
    }
}
```

**Output:**
```
[PDFRenderer.swift:15] 🏁 Starting render - page: 5, zoom: 1.5
[PDFRenderer.swift:23] 📏 Document size: 120 pages
[PDFRenderer.swift:28] ✅ Render complete in 0.23s
```

### Network Requests
```swift
private let eprint = EPrint(
    showFileName: true,
    showLineNumber: true,
    showTimestamp: true
)

class APIClient {
    func fetchData() async throws -> Data {
        eprint(.action, "Starting API request")
        
        let startTime = Date()
        let data = try await URLSession.shared.data(from: url)
        let duration = Date().timeIntervalSince(startTime)
        
        eprint(.success, "Received \(data.count) bytes in \(String(format: "%.2f", duration))s")
        return data
    }
}
```

### Debugging Scroll Performance
```swift
private let eprint = EPrint.verbose

class ScrollViewController: UIViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        eprint(.observation, "Scroll offset: \(scrollView.contentOffset.y)")
    }
    
    func loadVisibleCells() {
        eprint(.inspection, "Loading cells for visible range")
        // ... loading logic ...
        eprint(.success, "Loaded \(visibleCells.count) cells")
    }
}
```

---

## Configuration Reference ⚙️

### EPrintConfiguration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enabled` | `Bool` | `true` | Master switch for all output |
| `showFileName` | `Bool` | `false` | Display source file name |
| `showLineNumber` | `Bool` | `false` | Display line number |
| `showFunction` | `Bool` | `false` | Display function name |
| `showTimestamp` | `Bool` | `false` | Display timestamp (HH:mm:ss.SSS) |
| `showThread` | `Bool` | `false` | Display thread info |
| `outputs` | `[EPrintOutput]` | `[ConsoleOutput()]` | Output destinations |

### EPrint.ActiveState (v1.1.1)

| Case | Description |
|------|-------------|
| `.enabled` | Instance respects global state (default) |
| `.disabled` | Instance is always off |
| `.overrideGlobal` | Instance is always on, ignores global |

### EPrintEntry

Every print statement captures complete metadata:

| Property | Type | Description |
|----------|------|-------------|
| `message` | `String` | Your debug message |
| `file` | `String` | Full file path |
| `fileName` | `String` | Just the filename |
| `line` | `Int` | Line number |
| `function` | `String` | Function signature |
| `timestamp` | `Date` | Exact time of print |
| `thread` | `String` | Thread information |
| `threadName` | `String` | Simplified thread name |

---

## Performance 🚀

EPrint is designed to be fast and efficient:

- **When Disabled**: Near-zero overhead - early exit before any work
- **When Enabled**: ~43,000 prints/second on modern hardware
- **Thread Safe**: Concurrent access is safe and efficient
- **No Bloat**: Foundation only, no dependencies

### Benchmark Results
```
Performance Test: 1,000 prints
Average time: 0.023 seconds
Throughput: ~43,000 prints/second

Performance Test: 10,000 prints (disabled)
Time: < 0.001 seconds (negligible overhead)
```

---

## Best Practices 💡

### 1. Use Per-File Instances
```swift
// ✅ GOOD - Easy to toggle per file
private let eprint = EPrint.standard

class MyClass {
    func myMethod() {
        eprint(.start, "Debug message")
    }
}
```
```swift
// ❌ AVOID - Global instance harder to manage
class MyClass {
    func myMethod() {
        EPrint.shared(.start, "Debug message")
    }
}
```

### 2. Use Type-Safe Emojis

Use the emoji parameter for compile-time safety and cleaner code:

```swift
// ✅ GOOD - Type-safe, clear, refactorable
eprint(.start, "Starting operation")
eprint(.success, "Operation complete")
eprint(.error, "Operation failed")

// ❌ AVOID - String-based, typo-prone
eprint("🏁 Starting operation")
eprint("✅ Operation complete")
eprint("❌ Operation failed")
```

### 3. Create Project-Specific Emoji Enums

Define custom emojis for your domain:

```swift
enum MyProjectEmojis: String, EPrintEmoji {
    case api = "🌐"
    case database = "💾"
    case cache = "⚡️"
    var emoji: String { rawValue }
}

// Use consistently across your codebase
eprint(.api, "Making request")
eprint(.cache, "Cache hit")
```

### 4. Use Global Control for Production (v1.1.1)
```swift
// In AppDelegate or startup code
#if DEBUG
EPrint.globalEnabled = true
#else
EPrint.globalEnabled = false
#endif
```

### 5. Override Global for Critical Debugging (v1.1.1)
```swift
// In files that need debugging even in production
private let eprint = EPrint(activeState: .overrideGlobal)
// Prints: ⚠️ EPrint: Using .overrideGlobal - ignoring global state
```

### 6. Remove Debug Statements Before Shipping

Or simply disable them:
```swift
// Development
private let eprint = EPrint.standard

// Production
private let eprint = EPrint(activeState: .disabled)

// Or use global control
EPrint.globalEnabled = false
```

### 7. Use Standard Preset for Most Cases
```swift
// ✅ GOOD - Shows location without clutter
private let eprint = EPrint.standard
```

---

## Thread Safety 🧵

EPrint is fully thread-safe:
```swift
private let eprint = EPrint()

DispatchQueue.concurrentPerform(iterations: 100) { index in
    eprint("🧵 Thread \(index) is printing")
}
// Safe! No crashes or corruption
```

All configuration changes and print operations are protected by a serial DispatchQueue.

---

## Migration from `print()` 🔄

Migrating from standard `print()` is easy:
```swift
// Before
print("Starting render")
print("Width: \(width)")

// After
private let eprint = EPrint()
eprint("🏁 Starting render")
eprint("📏 Width: \(width)")
```

Benefits:
- ✅ Can now toggle on/off
- ✅ Can show file/line information
- ✅ Can send to files or custom destinations
- ✅ More organized with emojis

---

## API Reference 📚

### EPrint
```swift
// Initialization
init(activeState: ActiveState = .enabled,
     configuration: EPrintConfiguration = EPrintConfiguration())
     
init(enabled: Bool = true,
     showFileName: Bool = false,
     showLineNumber: Bool = false,
     showFunction: Bool = false,
     showTimestamp: Bool = false,
     showThread: Bool = false,
     outputs: [any EPrintOutput] = [ConsoleOutput()])

// Properties
var configuration: EPrintConfiguration { get set }
var activeState: ActiveState { get set }  // v1.1.1
var enabled: Bool { get set }  // For backward compatibility

// Static Properties (v1.1.1)
static var globalEnabled: Bool { get set }

// Static Methods (v1.1.1)
static func disableGlobally()
static func enableGlobally()

// Static Instances
static let shared: EPrint
static var minimal: EPrint { get }
static var standard: EPrint { get }
static var verbose: EPrint { get }

// Printing
func callAsFunction(_ message: String,
                    file: String = #file,
                    line: Int = #line,
                    function: String = #function)
                    
func callAsFunction(_ emoji: Emoji.Standard,
                    _ message: String,
                    file: String = #file,
                    line: Int = #line,
                    function: String = #function)
```

### EPrint.ActiveState (v1.1.1)
```swift
enum ActiveState {
    case enabled        // Respects global
    case disabled       // Always off
    case overrideGlobal // Always on
}
```

### EPrintConfiguration
```swift
// Initialization
init(enabled: Bool = true,
     showFileName: Bool = false,
     showLineNumber: Bool = false,
     showFunction: Bool = false,
     showTimestamp: Bool = false,
     showThread: Bool = false,
     outputs: [any EPrintOutput] = [ConsoleOutput()])

// Static Presets
static var minimal: EPrintConfiguration { get }
static var standard: EPrintConfiguration { get }
static var verbose: EPrintConfiguration { get }

// Builder
static func with(fileName: Bool = false,
                lineNumber: Bool = false,
                function: Bool = false,
                timestamp: Bool = false,
                thread: Bool = false,
                outputs: [any EPrintOutput] = [ConsoleOutput()]) -> EPrintConfiguration
```

### EPrintOutput Protocol
```swift
protocol EPrintOutput: Sendable {
    func write(_ entry: EPrintEntry, config: EPrintConfiguration)
}
```

Built-in implementations:
- `ConsoleOutput` - Prints to standard output
- `FileOutput` - Writes to a file (coming soon)

---

## FAQ ❓

**Q: Does EPrint work with Swift's strict concurrency checking?**  
A: Yes! EPrint is fully `Sendable` and thread-safe.

**Q: What's the performance impact?**  
A: Near-zero when disabled, and very fast when enabled (~43k prints/sec).

**Q: Can I use EPrint in production?**  
A: Yes! Just set `EPrint.globalEnabled = false` or use `activeState: .disabled`. Zero overhead when disabled.

**Q: Does it work on Linux?**  
A: Yes! EPrint uses Foundation only and works on all Swift platforms.

**Q: How does the new global control work? (v1.1.1)**  
A: Set `EPrint.globalEnabled = false` to disable all instances. Individual instances with `.overrideGlobal` will still print.

**Q: Can I filter output?**  
A: Create per-file instances and toggle them individually, or use global control. More advanced filtering coming in future versions.

**Q: How do I save output to a file?**  
A: Use `FileOutput` (coming soon) or create a custom `EPrintOutput`.

---

## Roadmap 🗺️

Future enhancements being considered:

- [ ] Fully functional `FileOutput` with rotation
- [ ] `DatabaseOutput` for persistent logging
- [ ] Log levels (DEBUG, INFO, WARNING, ERROR)
- [ ] Filtering by pattern/regex
- [ ] Structured output (JSON)
- [ ] Remote logging support
- [ ] SwiftLog backend integration

---

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup
```bash
git clone https://github.com/thomaah/EPrint.git
cd EPrint
swift test
```

### Running Tests
```bash
swift test
```

All tests should pass before submitting a PR.

---

## Requirements 📋

- Swift 5.9+
- iOS 13.0+ / macOS 10.15+ / watchOS 6.0+ / tvOS 13.0+ / Linux

---

## License 📄

EPrint is released under the MIT License. See [LICENSE](LICENSE) for details.

---

## Changelog 📝

### v1.1.1 (2026)
- ✨ **New**: Global control system - `EPrint.globalEnabled` property
- ✨ **New**: Convenience methods `disableGlobally()` and `enableGlobally()`
- ✨ **New**: `ActiveState` enum for fine-grained control
- ✨ **New**: `.overrideGlobal` state to bypass global disable
- ⚠️ **Warning**: Override instances print warning at initialization
- 🔧 **Improved**: Thread safety for global state
- 📝 **Note**: `enabled` property maintained for backward compatibility

### v1.0.0 (2026)
- 🎉 Initial release
- 🎯 Core EPrint functionality
- 🎨 Emoji system with standard set
- 📦 Protocol-based outputs
- ⚙️ Three convenience presets
- 🧵 Full thread safety

---

## Acknowledgments 🙏

EPrint was created to solve a common problem: making debug output more powerful while keeping it simple. Inspired by years of using `print()` statements and wishing for something better.

---

## Author ✍️

Created with ❤️ by [@thomaah](https://github.com/thomaah)

---

## Support 💬

- 🐛 [Report a Bug](https://github.com/thomaah/EPrint/issues)
- 💡 [Request a Feature](https://github.com/thomaah/EPrint/issues)
- 📖 [Documentation](https://github.com/thomaah/EPrint/wiki)
- ⭐ Star the repo if you find it useful!

---

<p align="center">
  <strong>Happy Debugging! 🎯</strong>
</p>

<p align="center">
  Made with ❤️ and lots of ☕
</p>
