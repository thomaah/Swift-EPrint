# EPrint 🎯

**Enhanced Print Debugging for Swift**

A lightweight, protocol-based print debugging library with emoji support, configurable output, and zero overhead when disabled. Make your debug output beautiful, informative, and production-ready.

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
- 🔌 **Per-File Toggle** - Enable/disable debugging per file with one line
- 📊 **Rich Metadata** - Optionally show file, line, function, timestamp, thread
- 🎨 **Emoji Support** - Use emojis to visually categorize your debug output
- 🚀 **Zero Cost When Disabled** - Near-zero overhead when turned off
- 🧵 **Thread Safe** - Safe to use from any thread
- 🔧 **Extensible** - Protocol-based outputs (console, file, custom)
- ⚙️ **Configurable** - Three presets + full customization
- 🌍 **Cross-Platform** - Works on iOS, macOS, watchOS, tvOS, and Linux
- 📦 **No Dependencies** - Foundation only

---

## Installation 📦

### Swift Package Manager

Add EPrint to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/thomaah/EPrint.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/thomaah/EPrint.git`
3. Select version and add to your target

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

#### 2. Standard - File and Line
```swift
private let eprint = EPrint.standard
eprint(.start, "Starting render")
```

**Output:**
```
[PDFRenderer.swift:42] 🏁 Starting render
```

#### 3. Verbose - Everything
```swift
private let eprint = EPrint.verbose
eprint(.start, "Starting render")
```

**Output:**
```
[PDFRenderer.swift:42] [render(page:)] [14:23:45.123] [main] 🏁 Starting render
```

### Custom Configuration

Build exactly the configuration you need:
```swift
private let eprint = EPrint(
    enabled: true,
    showFileName: true,
    showLineNumber: true,
    showTimestamp: true
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

// Turn off debugging for this file
eprint.enabled = false

// Turn it back on
eprint.enabled = true

// Toggle based on conditions
eprint.enabled = isDebugMode
eprint.enabled = pageIndex == 5  // Only debug page 5
```

---

## Advanced Features 🔧

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

### 4. Toggle Based on Build Configuration
```swift
private let eprint = EPrint(
    enabled: _isDebugAssertConfiguration()
)
```

### 5. Remove Debug Statements Before Shipping

Or simply disable them:
```swift
// Development
private let eprint = EPrint.standard

// Production
private let eprint = EPrint(enabled: false)
```

### 6. Use Standard Preset for Most Cases
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
init(configuration: EPrintConfiguration = EPrintConfiguration())
init(enabled: Bool = true,
     showFileName: Bool = false,
     showLineNumber: Bool = false,
     showFunction: Bool = false,
     showTimestamp: Bool = false,
     showThread: Bool = false,
     outputs: [any EPrintOutput] = [ConsoleOutput()])

// Properties
var configuration: EPrintConfiguration { get set }
var enabled: Bool { get set }

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
A: Yes! Just set `enabled: false` or remove the statements. Zero overhead when disabled.

**Q: Does it work on Linux?**  
A: Yes! EPrint uses Foundation only and works on all Swift platforms.

**Q: Can I filter output?**  
A: Create per-file instances and toggle them individually. More advanced filtering coming in future versions.

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