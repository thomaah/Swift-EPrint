//
//  EPrintTests.swift
//  EPrint - Enhanced Print Debugging Tests
//
//  Comprehensive test suite ensuring EPrint works correctly.
//
//  Created: 2025
//  License: MIT
//  Author: @thomaah
//

import XCTest
@testable import EPrint

// MARK: - Test Output (Captures output for verification)

/// A test output that captures entries for verification in tests.
///
/// Instead of printing to console, this stores entries in an array
/// so we can inspect what would have been printed.
final class TestOutput: EPrintOutput {
    
    /// All entries that have been written
    private(set) var entries: [EPrintEntry] = []
    
    /// All formatted strings that would have been displayed
    private(set) var formattedOutputs: [String] = []
    
    /// Thread-safe access to stored data
    private let queue = DispatchQueue(label: "com.eprint.testoutput")
    
    func write(_ entry: EPrintEntry, config: EPrintConfiguration) {
        queue.sync {
            print("🧪 TestOutput.write called for: \(entry.message)")
            entries.append(entry)
            
            // Store the formatted output as it would appear
            let formatted = format(entry, config: config)
            formattedOutputs.append(formatted)
            print("📝 Stored formatted output: \(formatted)")
        }
    }
    
    /// Clear all stored data
    func reset() {
        queue.sync {
            print("🧹 TestOutput.reset - clearing \(entries.count) entries")
            entries.removeAll()
            formattedOutputs.removeAll()
        }
    }
    
    /// Get the count of entries (thread-safe)
    var count: Int {
        queue.sync { entries.count }
    }
    
    /// Format an entry based on config (copied from ConsoleOutput logic)
    private func format(_ entry: EPrintEntry, config: EPrintConfiguration) -> String {
        var components: [String] = []
        
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
        
        if config.showFunction {
            components.append("[\(entry.function)]")
        }
        
        if config.showTimestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            let timeString = formatter.string(from: entry.timestamp)
            components.append("[\(timeString)]")
        }
        
        if config.showThread {
            components.append("[\(entry.threadName)]")
        }
        
        if components.isEmpty {
            return entry.message
        } else {
            let metadata = components.joined(separator: " ")
            return "\(metadata) \(entry.message)"
        }
    }
}

// MARK: - EPrintEntry Tests

/// Tests for the EPrintEntry data structure.
final class EPrintEntryTests: XCTestCase {
    
    func testBasicEntryCreation() {
        print("🧪 Test: Basic EPrintEntry creation")
        
        let timestamp = Date()
        let entry = EPrintEntry(
            message: "🏁 Test message",
            file: "/Users/test/Project/TestFile.swift",
            line: 42,
            function: "testFunction()",
            timestamp: timestamp,
            thread: "main"
        )
        
        print("✅ Created entry: \(entry.message)")
        
        XCTAssertEqual(entry.message, "🏁 Test message")
        XCTAssertEqual(entry.file, "/Users/test/Project/TestFile.swift")
        XCTAssertEqual(entry.line, 42)
        XCTAssertEqual(entry.function, "testFunction()")
        XCTAssertEqual(entry.timestamp, timestamp)
        XCTAssertEqual(entry.thread, "main")
        
        print("✅ All properties verified")
    }
    
    func testFileNameExtraction() {
        print("🧪 Test: File name extraction from full path")
        
        let entry = EPrintEntry(
            message: "Test",
            file: "/Users/test/Project/Subfolder/TestFile.swift",
            line: 1,
            function: "test()",
            timestamp: Date(),
            thread: "main"
        )
        
        print("📏 Full path: \(entry.file)")
        print("📏 Extracted fileName: \(entry.fileName)")
        
        XCTAssertEqual(entry.fileName, "TestFile.swift")
        
        print("✅ File name correctly extracted")
    }
    
    func testThreadNameSimplification() {
        print("🧪 Test: Thread name simplification")
        
        // Test main thread
        let mainEntry = EPrintEntry(
            message: "Test",
            file: "Test.swift",
            line: 1,
            function: "test()",
            timestamp: Date(),
            thread: "main"
        )
        
        print("🧵 Main thread name: \(mainEntry.threadName)")
        XCTAssertEqual(mainEntry.threadName, "main")
        
        // Test GCD queue
        let bgEntry = EPrintEntry(
            message: "Test",
            file: "Test.swift",
            line: 1,
            function: "test()",
            timestamp: Date(),
            thread: "com.apple.root.default-qos"
        )
        
        print("🧵 Background thread name: \(bgEntry.threadName)")
        XCTAssertEqual(bgEntry.threadName, "default-qos")
        
        print("✅ Thread names correctly simplified")
    }
    
    func testEntryEquality() {
        print("🧪 Test: EPrintEntry equality")
        
        let timestamp = Date()
        
        let entry1 = EPrintEntry(
            message: "Test",
            file: "Test.swift",
            line: 42,
            function: "test()",
            timestamp: timestamp,
            thread: "main"
        )
        
        let entry2 = EPrintEntry(
            message: "Test",
            file: "Test.swift",
            line: 42,
            function: "test()",
            timestamp: timestamp,
            thread: "main"
        )
        
        let entry3 = EPrintEntry(
            message: "Different",
            file: "Test.swift",
            line: 42,
            function: "test()",
            timestamp: timestamp,
            thread: "main"
        )
        
        print("⚖️ Comparing equal entries")
        XCTAssertEqual(entry1, entry2)
        
        print("⚖️ Comparing different entries")
        XCTAssertNotEqual(entry1, entry3)
        
        print("✅ Equality checks passed")
    }
}

// MARK: - EPrintConfiguration Tests

/// Tests for configuration and presets.
final class EPrintConfigurationTests: XCTestCase {
    
    func testDefaultConfiguration() {
        print("🧪 Test: Default configuration")
        
        let config = EPrintConfiguration()
        
        print("🔍 Checking default values")
        XCTAssertTrue(config.enabled)
        XCTAssertFalse(config.showFileName)
        XCTAssertFalse(config.showLineNumber)
        XCTAssertFalse(config.showFunction)
        XCTAssertFalse(config.showTimestamp)
        XCTAssertFalse(config.showThread)
        XCTAssertEqual(config.outputs.count, 1) // Default console output
        
        print("✅ Default configuration verified")
    }
    
    func testMinimalPreset() {
        print("🧪 Test: Minimal preset")
        
        let config = EPrintConfiguration.minimal
        
        print("🔍 Checking minimal preset")
        XCTAssertTrue(config.enabled)
        XCTAssertFalse(config.showFileName)
        XCTAssertFalse(config.showLineNumber)
        XCTAssertFalse(config.showFunction)
        XCTAssertFalse(config.showTimestamp)
        XCTAssertFalse(config.showThread)
        
        print("✅ Minimal preset verified")
    }
    
    func testStandardPreset() {
        print("🧪 Test: Standard preset")
        
        let config = EPrintConfiguration.standard
        
        print("🔍 Checking standard preset")
        XCTAssertTrue(config.enabled)
        XCTAssertTrue(config.showFileName)
        XCTAssertTrue(config.showLineNumber)
        XCTAssertFalse(config.showFunction)
        XCTAssertFalse(config.showTimestamp)
        XCTAssertFalse(config.showThread)
        
        print("✅ Standard preset verified")
    }
    
    func testVerbosePreset() {
        print("🧪 Test: Verbose preset")
        
        let config = EPrintConfiguration.verbose
        
        print("🔍 Checking verbose preset")
        XCTAssertTrue(config.enabled)
        XCTAssertTrue(config.showFileName)
        XCTAssertTrue(config.showLineNumber)
        XCTAssertTrue(config.showFunction)
        XCTAssertTrue(config.showTimestamp)
        XCTAssertTrue(config.showThread)
        
        print("✅ Verbose preset verified")
    }
    
    func testBuilderPattern() {
        print("🧪 Test: Configuration builder pattern")
        
        let config = EPrintConfiguration.with(
            fileName: true,
            timestamp: true
        )
        
        print("🔍 Checking builder pattern result")
        XCTAssertTrue(config.showFileName)
        XCTAssertTrue(config.showTimestamp)
        XCTAssertFalse(config.showLineNumber)
        XCTAssertFalse(config.showFunction)
        
        print("✅ Builder pattern verified")
    }
    
    func testConfigurationEquality() {
        print("🧪 Test: Configuration equality")
        
        let config1 = EPrintConfiguration.standard
        let config2 = EPrintConfiguration.standard
        let config3 = EPrintConfiguration.verbose
        
        print("⚖️ Comparing equal configurations")
        XCTAssertEqual(config1, config2)
        
        print("⚖️ Comparing different configurations")
        XCTAssertNotEqual(config1, config3)
        
        print("✅ Equality checks passed")
    }
}

// MARK: - EPrintOutput Tests

/// Tests for output formatting.
final class EPrintOutputTests: XCTestCase {
    
    func testMinimalFormatting() {
        print("🧪 Test: Minimal formatting (message only)")
        
        let output = TestOutput()
        let config = EPrintConfiguration.minimal
        
        let entry = EPrintEntry(
            message: "🏁 Test message",
            file: "Test.swift",
            line: 42,
            function: "test()",
            timestamp: Date(),
            thread: "main"
        )
        
        output.write(entry, config: config)
        
        print("📝 Formatted output: \(output.formattedOutputs[0])")
        
        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output.formattedOutputs[0], "🏁 Test message")
        
        print("✅ Minimal formatting verified")
    }
    
    func testStandardFormatting() {
        print("🧪 Test: Standard formatting (file and line)")
        
        let output = TestOutput()
        let config = EPrintConfiguration.standard
        
        let entry = EPrintEntry(
            message: "🏁 Test message",
            file: "/path/to/Test.swift",
            line: 42,
            function: "test()",
            timestamp: Date(),
            thread: "main"
        )
        
        output.write(entry, config: config)
        
        print("📝 Formatted output: \(output.formattedOutputs[0])")
        
        XCTAssertEqual(output.count, 1)
        XCTAssertTrue(output.formattedOutputs[0].contains("[Test.swift:42]"))
        XCTAssertTrue(output.formattedOutputs[0].contains("🏁 Test message"))
        
        print("✅ Standard formatting verified")
    }
    
    func testVerboseFormatting() {
        print("🧪 Test: Verbose formatting (all metadata)")
        
        let output = TestOutput()
        let config = EPrintConfiguration.verbose
        
        let entry = EPrintEntry(
            message: "🏁 Test message",
            file: "/path/to/Test.swift",
            line: 42,
            function: "testFunction()",
            timestamp: Date(),
            thread: "main"
        )
        
        output.write(entry, config: config)
        
        print("📝 Formatted output: \(output.formattedOutputs[0])")
        
        let formatted = output.formattedOutputs[0]
        XCTAssertTrue(formatted.contains("[Test.swift:42]"))
        XCTAssertTrue(formatted.contains("[testFunction()]"))
        XCTAssertTrue(formatted.contains("[main]"))
        XCTAssertTrue(formatted.contains("🏁 Test message"))
        
        print("✅ Verbose formatting verified")
    }
    
    func testLineNumberOnly() {
        print("🧪 Test: Line number only formatting")
        
        let output = TestOutput()
        let config = EPrintConfiguration(
            showFileName: false,
            showLineNumber: true
        )
        
        let entry = EPrintEntry(
            message: "🏁 Test",
            file: "Test.swift",
            line: 42,
            function: "test()",
            timestamp: Date(),
            thread: "main"
        )
        
        output.write(entry, config: config)
        
        print("📝 Formatted output: \(output.formattedOutputs[0])")
        
        XCTAssertTrue(output.formattedOutputs[0].contains("[line 42]"))
        
        print("✅ Line number only formatting verified")
    }
}

// MARK: - EPrint Main Class Tests

/// Tests for the main EPrint class functionality.
final class EPrintMainTests: XCTestCase {
    
    func testBasicPrint() {
        print("🧪 Test: Basic print functionality")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("🏁 Calling eprint")
        eprint("🏁 Test message")
        
        // Give async write time to complete
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Checking output: \(testOutput.count) entries")
        XCTAssertEqual(testOutput.count, 1)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Test message")
        
        print("✅ Basic print verified")
    }
    
    func testDisabledPrint() {
        print("🧪 Test: Disabled print produces no output")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(enabled: false, outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("🚫 Calling eprint (should be disabled)")
        eprint("🏁 Should not appear")
        
        // Give any potential async writes time
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Checking output: \(testOutput.count) entries")
        XCTAssertEqual(testOutput.count, 0)
        
        print("✅ Disabled print verified")
    }
    
    func testEnabledToggle() {
        print("🧪 Test: Toggling enabled on/off")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("✅ Print while enabled")
        eprint("🏁 Message 1")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🚫 Disable and print")
        eprint.enabled = false
        eprint("🏁 Message 2 - should not appear")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("✅ Re-enable and print")
        eprint.enabled = true
        eprint("🏁 Message 3")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Checking output: \(testOutput.count) entries")
        XCTAssertEqual(testOutput.count, 2)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Message 1")
        XCTAssertEqual(testOutput.entries[1].message, "🏁 Message 3")
        
        print("✅ Toggle verified")
    }
    
    func testSharedInstance() {
        print("🧪 Test: Shared instance accessibility")
        
        // Just verify shared instance exists and is callable
        EPrint.shared.enabled = false  // Disable so we don't pollute output
        EPrint.shared("🏁 Test shared")
        
        print("✅ Shared instance verified")
    }
    
    func testConveniencePresets() {
        print("🧪 Test: Convenience preset instances")
        
        let minimal = EPrint.minimal
        let standard = EPrint.standard
        let verbose = EPrint.verbose
        
        // Verify they have expected configurations
        XCTAssertFalse(minimal.configuration.showFileName)
        XCTAssertTrue(standard.configuration.showFileName)
        XCTAssertTrue(verbose.configuration.showFunction)
        
        print("✅ Convenience presets verified")
    }
    
    func testMetadataCapture() {
        print("🧪 Test: Automatic metadata capture")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        eprint("🏁 Test from line \(#line)")
        Thread.sleep(forTimeInterval: 0.1)
        
        XCTAssertEqual(testOutput.count, 1)
        
        let entry = testOutput.entries[0]
        print("📦 Captured entry:")
        print("   File: \(entry.file)")
        print("   Line: \(entry.line)")
        print("   Function: \(entry.function)")
        print("   Thread: \(entry.thread)")
        
        XCTAssertTrue(entry.file.contains("EPrintTests.swift"))
        XCTAssertGreaterThan(entry.line, 0)
        XCTAssertFalse(entry.function.isEmpty)
        
        print("✅ Metadata capture verified")
    }
    
    func testMultipleOutputs() {
        print("🧪 Test: Multiple simultaneous outputs")
        
        let output1 = TestOutput()
        let output2 = TestOutput()
        let config = EPrintConfiguration(outputs: [output1, output2])
        let eprint = EPrint(configuration: config)
        
        print("📤 Printing to multiple outputs")
        eprint("🏁 Test message")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Checking both outputs")
        XCTAssertEqual(output1.count, 1)
        XCTAssertEqual(output2.count, 1)
        XCTAssertEqual(output1.entries[0].message, output2.entries[0].message)
        
        print("✅ Multiple outputs verified")
    }
}

// MARK: - Thread Safety Tests

/// Tests ensuring thread safety under concurrent access.
final class EPrintThreadSafetyTests: XCTestCase {
    
    func testConcurrentWrites() {
        print("🧪 Test: Concurrent writes from multiple threads")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        let expectation = self.expectation(description: "Concurrent writes")
        expectation.expectedFulfillmentCount = 10
        
        print("🚀 Launching 10 concurrent writes")
        
        // Launch multiple concurrent writes
        for i in 0..<10 {
            DispatchQueue.global().async {
                eprint("🧵 Message from thread \(i)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2.0)
        
        // Give async writes time to complete
        Thread.sleep(forTimeInterval: 0.2)
        
        print("🔍 Checking output: \(testOutput.count) entries")
        XCTAssertEqual(testOutput.count, 10)
        
        print("✅ Concurrent writes verified - no crashes or corruption")
    }
    
    func testConcurrentConfigurationChanges() {
        print("🧪 Test: Concurrent configuration changes")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        let expectation = self.expectation(description: "Concurrent config changes")
        expectation.expectedFulfillmentCount = 20
        
        print("🚀 Launching concurrent config changes and writes")
        
        // Mix configuration changes with writes
        for i in 0..<10 {
            DispatchQueue.global().async {
                eprint.enabled = i % 2 == 0
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                eprint("🧵 Message \(i)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2.0)
        Thread.sleep(forTimeInterval: 0.2)
        
        print("✅ Concurrent config changes verified - no crashes")
    }
}

// MARK: - Performance Tests

/// Tests for performance characteristics.
final class EPrintPerformanceTests: XCTestCase {
    
    func testDisabledPerformance() {
        print("🧪 Test: Performance when disabled")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(enabled: false, outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("⏱️ Measuring 10,000 disabled prints")
        
        measure {
            for i in 0..<10_000 {
                eprint("🏁 Message \(i)")
            }
        }
        
        // Should produce no output
        Thread.sleep(forTimeInterval: 0.1)
        XCTAssertEqual(testOutput.count, 0)
        
        print("✅ Disabled performance verified")
    }
    
    func testEnabledPerformance() {
        print("🧪 Test: Performance when enabled")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("⏱️ Measuring 1,000 enabled prints")
        
        measure {
            for i in 0..<1_000 {
                eprint("🏁 Message \(i)")
            }
        }
        
        print("✅ Enabled performance measured")
    }
}

// MARK: - Integration Tests

/// End-to-end integration tests simulating real usage.
final class EPrintIntegrationTests: XCTestCase {
    
    func testRealWorldScenario() {
        print("🧪 Test: Real-world usage scenario")
        
        // Simulate a typical debugging session
        let testOutput = TestOutput()
        let config = EPrintConfiguration.with(
            fileName: true,
            lineNumber: true,
            outputs: [testOutput]
        )
        let eprint = EPrint(configuration: config)
        
        // Simulate some code execution with debugging
        print("🏁 Starting simulated render")
        eprint("🏁 Starting render")
        
        let width = 800
        let height = 1200
        print("📏 Calculating dimensions")
        eprint("📏 Width: \(width), Height: \(height)")
        
        // Simulate some work
        Thread.sleep(forTimeInterval: 0.05)
        
        print("✅ Completing render")
        eprint("✅ Render complete")
        
        // Wait for async writes
        Thread.sleep(forTimeInterval: 0.2)
        
        print("🔍 Verifying output")
        XCTAssertEqual(testOutput.count, 3)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Starting render")
        XCTAssertTrue(testOutput.entries[1].message.contains("Width: 800"))
        XCTAssertEqual(testOutput.entries[2].message, "✅ Render complete")
        
        print("✅ Real-world scenario verified")
    }
    
    func testDynamicConfiguration() {
        print("🧪 Test: Dynamic configuration changes")
        
        let testOutput = TestOutput()
        let eprint = EPrint(configuration: EPrintConfiguration.minimal)
        eprint.configuration.outputs = [testOutput]
        
        // Start minimal
        print("📝 Minimal mode")
        eprint("🏁 Minimal message")
        Thread.sleep(forTimeInterval: 0.1)
        
        // Switch to verbose
        print("📝 Switching to verbose")
        eprint.configuration = EPrintConfiguration.verbose
        eprint.configuration.outputs = [testOutput]
        eprint("🏁 Verbose message")
        Thread.sleep(forTimeInterval: 0.1)
        
        // Back to minimal
        print("📝 Back to minimal")
        eprint.configuration = EPrintConfiguration.minimal
        eprint.configuration.outputs = [testOutput]
        eprint("🏁 Minimal again")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Verifying output")
        XCTAssertEqual(testOutput.count, 3)
        
        print("✅ Dynamic configuration verified")
    }
}

// MARK: - Emoji System Tests

/// Tests for the emoji system including protocol, standard emojis, and custom emojis.
final class EPrintEmojiTests: XCTestCase {
    
    func testStandardEmojiValues() {
        print("🧪 Test: Standard emoji values")
        
        // Verify all standard emojis have correct values
        XCTAssertEqual(Emoji.Standard.start.emoji, "🏁")
        XCTAssertEqual(Emoji.Standard.success.emoji, "✅")
        XCTAssertEqual(Emoji.Standard.error.emoji, "❌")
        XCTAssertEqual(Emoji.Standard.warning.emoji, "⚠️")
        XCTAssertEqual(Emoji.Standard.info.emoji, "ℹ️")
        XCTAssertEqual(Emoji.Standard.measurement.emoji, "📏")
        XCTAssertEqual(Emoji.Standard.observation.emoji, "👁️")
        XCTAssertEqual(Emoji.Standard.action.emoji, "🚀")
        XCTAssertEqual(Emoji.Standard.inspection.emoji, "🔍")
        XCTAssertEqual(Emoji.Standard.metrics.emoji, "📊")
        XCTAssertEqual(Emoji.Standard.target.emoji, "🎯")
        XCTAssertEqual(Emoji.Standard.debug.emoji, "🐛")
        XCTAssertEqual(Emoji.Standard.complete.emoji, "📦")
        
        print("✅ All standard emojis verified")
    }
    
    func testEmojiOverloadBasicUsage() {
        print("🧪 Test: Emoji overload basic usage")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("🏁 Calling eprint with emoji overload")
        eprint(.start, "Test message")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Checking output")
        XCTAssertEqual(testOutput.count, 1)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Test message")
        
        print("✅ Emoji overload basic usage verified")
    }
    
    func testEmojiOverloadWithMultipleTypes() {
        print("🧪 Test: Multiple emoji types")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("📝 Testing different emoji types")
        eprint(.start, "Starting")
        eprint(.success, "Success")
        eprint(.error, "Error")
        eprint(.warning, "Warning")
        eprint(.measurement, "Measurement")
        Thread.sleep(forTimeInterval: 0.2)
        
        print("🔍 Verifying messages")
        XCTAssertEqual(testOutput.count, 5)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Starting")
        XCTAssertEqual(testOutput.entries[1].message, "✅ Success")
        XCTAssertEqual(testOutput.entries[2].message, "❌ Error")
        XCTAssertEqual(testOutput.entries[3].message, "⚠️ Warning")
        XCTAssertEqual(testOutput.entries[4].message, "📏 Measurement")
        
        print("✅ Multiple emoji types verified")
    }
    
    func testEmojiOverloadWithConfiguration() {
        print("🧪 Test: Emoji overload with configuration (standard)")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration.standard
        let eprint = EPrint(configuration: config)
        eprint.configuration.outputs = [testOutput]
        
        print("📝 Calling with standard config")
        eprint(.start, "Test message")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Checking formatted output")
        XCTAssertEqual(testOutput.count, 1)
        XCTAssertTrue(testOutput.formattedOutputs[0].contains("🏁 Test message"))
        XCTAssertTrue(testOutput.formattedOutputs[0].contains("[EPrintTests.swift"))
        
        print("✅ Emoji with configuration verified")
    }
    
    func testCustomEmojiEnum() {
        print("🧪 Test: Custom emoji enum")
        
        // Define custom emoji enum
        enum TestEmojis: String, EPrintEmoji {
            case custom1 = "🌟"
            case custom2 = "🎨"
            case custom3 = "🔥"
            
            var emoji: String { rawValue }
        }
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("📝 Using custom emojis")
        // Need to be explicit since TestEmojis is defined in this scope
        eprint(TestEmojis.custom1, "Custom message 1")
        eprint(TestEmojis.custom2, "Custom message 2")
        eprint(TestEmojis.custom3, "Custom message 3")
        Thread.sleep(forTimeInterval: 0.2)
        
        print("🔍 Verifying custom emojis")
        XCTAssertEqual(testOutput.count, 3)
        XCTAssertEqual(testOutput.entries[0].message, "🌟 Custom message 1")
        XCTAssertEqual(testOutput.entries[1].message, "🎨 Custom message 2")
        XCTAssertEqual(testOutput.entries[2].message, "🔥 Custom message 3")
        
        print("✅ Custom emoji enum verified")
    }
    
    func testMixingStandardAndCustomEmojis() {
        print("🧪 Test: Mixing standard and custom emojis")
        
        enum CustomEmojis: String, EPrintEmoji {
            case api = "🌐"
            case database = "💾"
            var emoji: String { rawValue }
        }
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("📝 Using both standard and custom emojis")
        // Need to be explicit when both enums are in scope
        eprint(Emoji.Standard.start, "Starting operation")           // Standard
        eprint(CustomEmojis.api, "Making API call")                // Custom
        eprint(CustomEmojis.database, "Querying database")         // Custom
        eprint(Emoji.Standard.success, "Operation complete")         // Standard
        Thread.sleep(forTimeInterval: 0.2)
        
        print("🔍 Verifying mixed emojis")
        XCTAssertEqual(testOutput.count, 4)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Starting operation")
        XCTAssertEqual(testOutput.entries[1].message, "🌐 Making API call")
        XCTAssertEqual(testOutput.entries[2].message, "💾 Querying database")
        XCTAssertEqual(testOutput.entries[3].message, "✅ Operation complete")
        
        print("✅ Mixed emojis verified")
    }
    
    func testEmojiOverloadPreservesMetadata() {
        print("🧪 Test: Emoji overload preserves metadata")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        eprint(.start, "Test")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Checking metadata")
        let entry = testOutput.entries[0]
        
        XCTAssertTrue(entry.file.contains("EPrintTests.swift"))
        XCTAssertGreaterThan(entry.line, 0)
        XCTAssertFalse(entry.function.isEmpty)
        XCTAssertFalse(entry.thread.isEmpty)
        
        print("✅ Metadata preservation verified")
    }
    
    func testBackwardCompatibilityWithStringOnly() {
        print("🧪 Test: Backward compatibility with string-only syntax")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        print("📝 Using old string-only syntax")
        eprint("🏁 Old style message")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Verifying old syntax still works")
        XCTAssertEqual(testOutput.count, 1)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Old style message")
        
        print("✅ Backward compatibility verified")
    }
    
    func testEmojiWithStringInterpolation() {
        print("🧪 Test: Emoji with string interpolation")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        let value = 42
        let name = "Test"
        
        print("📝 Using string interpolation with emojis")
        eprint(.measurement, "Value is \(value)")
        eprint(.info, "Name is \(name)")
        Thread.sleep(forTimeInterval: 0.1)
        
        print("🔍 Verifying interpolation")
        XCTAssertEqual(testOutput.count, 2)
        XCTAssertEqual(testOutput.entries[0].message, "📏 Value is 42")
        XCTAssertEqual(testOutput.entries[1].message, "ℹ️ Name is Test")
        
        print("✅ String interpolation verified")
    }
}

// MARK: - Debug Mode Tests

/// Tests for EPrint's internal debug mode
final class EPrintDebugModeTests: XCTestCase {
    
    func testDebugModeDefault() {
        print("🧪 Test: Debug mode default value")
        
        // Debug mode should be false by default
        XCTAssertFalse(EPrint.debugMode)
        
        print("✅ Debug mode default verified")
    }
    
    func testDebugModeToggle() {
        print("🧪 Test: Debug mode toggle")
        
        let originalValue = EPrint.debugMode
        
        EPrint.debugMode = true
        XCTAssertTrue(EPrint.debugMode)
        
        EPrint.debugMode = false
        XCTAssertFalse(EPrint.debugMode)
        
        // Restore original value
        EPrint.debugMode = originalValue
        
        print("✅ Debug mode toggle verified")
    }
    
    func testDebugModeDoesNotAffectOutput() {
        print("🧪 Test: Debug mode doesn't affect user output")
        
        let testOutput = TestOutput()
        let config = EPrintConfiguration(outputs: [testOutput])
        let eprint = EPrint(configuration: config)
        
        // Test with debug mode off
        EPrint.debugMode = false
        eprint(.start, "Message 1")
        Thread.sleep(forTimeInterval: 0.1)
        
        // Test with debug mode on
        EPrint.debugMode = true
        eprint(.start, "Message 2")
        Thread.sleep(forTimeInterval: 0.1)
        
        // Restore
        EPrint.debugMode = false
        
        print("🔍 Verifying output is identical")
        XCTAssertEqual(testOutput.count, 2)
        XCTAssertEqual(testOutput.entries[0].message, "🏁 Message 1")
        XCTAssertEqual(testOutput.entries[1].message, "🏁 Message 2")
        
        print("✅ Debug mode output independence verified")
    }
}