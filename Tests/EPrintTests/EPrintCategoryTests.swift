//
//  EPrintCategoryTests.swift
//  EPrint - Enhanced Print Debugging
//
//  Tests for the category system (v1.2.0)
//
//  Created: 2025
//  License: MIT
//  Author: @thomaah
//

import XCTest
@testable import EPrint

/// Tests for the category system introduced in v1.2.0
///
/// These tests cover:
/// - EPrintCategory creation and equality
/// - CategoryFilter behavior (allEnabled, allDisabled, only, except)
/// - Global category filtering
/// - Instance category filtering
/// - Integration with ActiveState
/// - Category display in output
/// - Convenience methods
final class EPrintCategoryTests: XCTestCase {
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        // Reset global state before each test
        EPrint.globalEnabled = true
        EPrint.globalCategoryFilter = .allEnabled
    }
    
    override func tearDown() {
        // Clean up global state after each test
        EPrint.globalEnabled = true
        EPrint.globalCategoryFilter = .allEnabled
        super.tearDown()
    }
    
    // MARK: - EPrintCategory Tests
    
    func testCategoryCreation() {
        let category = EPrintCategory("test")
        XCTAssertEqual(category.name, "test")
    }
    
    func testCategoryEquality() {
        let category1 = EPrintCategory("test")
        let category2 = EPrintCategory("test")
        let category3 = EPrintCategory("other")
        
        XCTAssertEqual(category1, category2, "Categories with same name should be equal")
        XCTAssertNotEqual(category1, category3, "Categories with different names should not be equal")
    }
    
    func testCategoryHashable() {
        let category1 = EPrintCategory("test")
        let category2 = EPrintCategory("test")
        let category3 = EPrintCategory("other")
        
        var set: Set<EPrintCategory> = []
        set.insert(category1)
        set.insert(category2)
        set.insert(category3)
        
        XCTAssertEqual(set.count, 2, "Set should contain 2 unique categories")
        XCTAssertTrue(set.contains(category1))
        XCTAssertTrue(set.contains(category3))
    }
    
    func testBuiltInCategories() {
        // Verify all built-in categories exist and have correct names
        XCTAssertEqual(EPrintCategory.rendering.name, "rendering")
        XCTAssertEqual(EPrintCategory.layout.name, "layout")
        XCTAssertEqual(EPrintCategory.performance.name, "performance")
        XCTAssertEqual(EPrintCategory.network.name, "network")
        XCTAssertEqual(EPrintCategory.database.name, "database")
        XCTAssertEqual(EPrintCategory.animation.name, "animation")
        XCTAssertEqual(EPrintCategory.userInput.name, "userInput")
        XCTAssertEqual(EPrintCategory.log.name, "log")
        XCTAssertEqual(EPrintCategory.debug.name, "debug")
    }
    
    func testCustomCategoryCreation() {
        // Test that custom categories can be created inline
        let custom = EPrintCategory("custom")
        XCTAssertEqual(custom.name, "custom")
        
        // Test that they work in Sets (for filters)
        let filter = CategoryFilter.only([custom])
        XCTAssertTrue(filter.allows(custom))
        XCTAssertFalse(filter.allows(.rendering))
    }
    
    // MARK: - CategoryFilter Tests
    
    func testCategoryFilterAllEnabled() {
        let filter = CategoryFilter.allEnabled
        
        XCTAssertTrue(filter.allows(.rendering))
        XCTAssertTrue(filter.allows(.network))
        XCTAssertTrue(filter.allows(.performance))
        XCTAssertTrue(filter.allows(EPrintCategory("custom")))
        XCTAssertTrue(filter.allows(nil), "Uncategorized should always be allowed")
    }
    
    func testCategoryFilterAllDisabled() {
        let filter = CategoryFilter.allDisabled
        
        XCTAssertFalse(filter.allows(.rendering))
        XCTAssertFalse(filter.allows(.network))
        XCTAssertFalse(filter.allows(.performance))
        XCTAssertFalse(filter.allows(EPrintCategory("custom")))
        XCTAssertTrue(filter.allows(nil), "Uncategorized should always be allowed")
    }
    
    func testCategoryFilterOnlySet() {
        let filter = CategoryFilter.only([.rendering, .network])
        
        XCTAssertTrue(filter.allows(.rendering), "Rendering should be allowed")
        XCTAssertTrue(filter.allows(.network), "Network should be allowed")
        XCTAssertFalse(filter.allows(.performance), "Performance should be blocked")
        XCTAssertFalse(filter.allows(.layout), "Layout should be blocked")
        XCTAssertTrue(filter.allows(nil), "Uncategorized should always be allowed")
    }
    
    func testCategoryFilterOnlyVariadic() {
        let filter = CategoryFilter.only(.rendering, .network)
        
        XCTAssertTrue(filter.allows(.rendering))
        XCTAssertTrue(filter.allows(.network))
        XCTAssertFalse(filter.allows(.performance))
    }
    
    func testCategoryFilterExceptSet() {
        let filter = CategoryFilter.except([.rendering, .layout])
        
        XCTAssertFalse(filter.allows(.rendering), "Rendering should be blocked")
        XCTAssertFalse(filter.allows(.layout), "Layout should be blocked")
        XCTAssertTrue(filter.allows(.network), "Network should be allowed")
        XCTAssertTrue(filter.allows(.performance), "Performance should be allowed")
        XCTAssertTrue(filter.allows(nil), "Uncategorized should always be allowed")
    }
    
    func testCategoryFilterExceptVariadic() {
        let filter = CategoryFilter.except(.rendering, .layout)
        
        XCTAssertFalse(filter.allows(.rendering))
        XCTAssertFalse(filter.allows(.layout))
        XCTAssertTrue(filter.allows(.network))
    }
    
    func testCategoryFilterEquality() {
        XCTAssertEqual(CategoryFilter.allEnabled, CategoryFilter.allEnabled)
        XCTAssertEqual(CategoryFilter.allDisabled, CategoryFilter.allDisabled)
        XCTAssertEqual(
            CategoryFilter.only([.rendering, .network]),
            CategoryFilter.only([.network, .rendering])
        )
        XCTAssertEqual(
            CategoryFilter.except([.rendering]),
            CategoryFilter.except([.rendering])
        )
        
        XCTAssertNotEqual(CategoryFilter.allEnabled, CategoryFilter.allDisabled)
        XCTAssertNotEqual(
            CategoryFilter.only([.rendering]),
            CategoryFilter.only([.network])
        )
    }
    
    // MARK: - Global Category Filter Tests
    
    func testGlobalCategoryFilterDefault() {
        // Default should be allEnabled
        XCTAssertEqual(EPrint.globalCategoryFilter, .allEnabled)
    }
    
    func testGlobalCategoryFilterSetting() {
        EPrint.globalCategoryFilter = .only([.performance])
        XCTAssertEqual(EPrint.globalCategoryFilter, .only([.performance]))
        
        EPrint.globalCategoryFilter = .allDisabled
        XCTAssertEqual(EPrint.globalCategoryFilter, .allDisabled)
    }
    
    func testGlobalEnableCategories() {
        EPrint.enableCategories(.rendering, .network)
        XCTAssertEqual(EPrint.globalCategoryFilter, .only([.rendering, .network]))
    }
    
    func testGlobalDisableCategories() {
        EPrint.disableCategories(.rendering, .layout)
        XCTAssertEqual(EPrint.globalCategoryFilter, .except([.rendering, .layout]))
    }
    
    func testGlobalEnableAllCategories() {
        EPrint.globalCategoryFilter = .allDisabled
        EPrint.enableAllCategories()
        XCTAssertEqual(EPrint.globalCategoryFilter, .allEnabled)
    }
    
    func testGlobalDisableAllCategories() {
        EPrint.disableAllCategories()
        XCTAssertEqual(EPrint.globalCategoryFilter, .allDisabled)
    }
    
    // MARK: - Instance Category Filter Tests
    
    func testInstanceCategoryFilterDefault() {
        let eprint = EPrint()
        XCTAssertEqual(eprint.categoryFilter, .allEnabled)
    }
    
    func testInstanceCategoryFilterSetting() {
        let eprint = EPrint()
        
        eprint.categoryFilter = .only([.debug])
        XCTAssertEqual(eprint.categoryFilter, .only([.debug]))
        
        eprint.categoryFilter = .except([.rendering])
        XCTAssertEqual(eprint.categoryFilter, .except([.rendering]))
    }
    
    func testInstanceEnableCategories() {
        let eprint = EPrint()
        eprint.enableCategories(.performance, .network)
        XCTAssertEqual(eprint.categoryFilter, .only([.performance, .network]))
    }
    
    func testInstanceDisableCategories() {
        let eprint = EPrint()
        eprint.disableCategories(.rendering, .layout)
        XCTAssertEqual(eprint.categoryFilter, .except([.rendering, .layout]))
    }
    
    func testInstanceEnableAllCategories() {
        let eprint = EPrint()
        eprint.categoryFilter = .allDisabled
        eprint.enableAllCategories()
        XCTAssertEqual(eprint.categoryFilter, .allEnabled)
    }
    
    func testInstanceDisableAllCategories() {
        let eprint = EPrint()
        eprint.disableAllCategories()
        XCTAssertEqual(eprint.categoryFilter, .allDisabled)
    }
    
    // MARK: - Category Filtering Integration Tests
    
    /// Helper to wait for async EPrint writes to complete
    private func waitForWrites() {
        // Give the async queue time to complete writes
        Thread.sleep(forTimeInterval: 0.01)
    }
    
    func testCategoryFilteringWithGlobalEnabled() {
        // Setup: Global filter allows only performance
        EPrint.globalCategoryFilter = .only([.performance])
        
        // Create test output to capture prints
        let testOutput = TestOutput()
        let eprint = EPrint(configuration: EPrintConfiguration(
            enabled: true,
            outputs: [testOutput]
        ))
        
        // Test: Only performance should print
        eprint("Performance message", category: .performance)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertEqual(testOutput.entries[0].category, .performance)
        
        eprint("Rendering message", category: .rendering)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, 1, "Rendering should be filtered out - count should still be 1")
    }
    
    func testCategoryFilteringWithInstanceOverride() {
        // Setup: Global filter blocks all, but instance overrides
        EPrint.globalCategoryFilter = .allDisabled
        
        let testOutput = TestOutput()
        let eprint = EPrint(
            activeState: .overrideGlobal,
            configuration: EPrintConfiguration(outputs: [testOutput])
        )
        eprint.categoryFilter = .only([.debug])
        
        // Test: Instance filter should be used, not global
        eprint("Debug message", category: .debug)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertEqual(testOutput.entries[0].category, .debug)
        
        eprint("Performance message", category: .performance)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, 1, "Performance should be filtered by instance filter - count should still be 1")
    }
    
    func testUncategorizedBypassesFilters() {
        // Setup: Block all categories globally
        EPrint.globalCategoryFilter = .allDisabled
        
        let testOutput = TestOutput()
        let eprint = EPrint(configuration: EPrintConfiguration(outputs: [testOutput]))
        
        // Test: Uncategorized should still print
        eprint("Uncategorized message")
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertNil(testOutput.entries[0].category)
    }
    
    func testCategoryFilteringWithDisabledState() {
        // Setup: Instance is disabled
        let testOutput = TestOutput()
        let eprint = EPrint(
            activeState: .disabled,
            configuration: EPrintConfiguration(outputs: [testOutput])
        )
        
        // Test: Nothing should print regardless of category filter
        eprint("Message", category: .performance)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, 0)
    }
    
    func testCategoryFilteringExceptStrategy() {
        // Setup: Block only rendering and layout
        EPrint.globalCategoryFilter = .except([.rendering, .layout])
        
        let testOutput = TestOutput()
        let eprint = EPrint(configuration: EPrintConfiguration(outputs: [testOutput]))
        
        // Test: Performance should print
        eprint("Performance message", category: .performance)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, 1)
        
        // Test: Rendering should be blocked
        let beforeCount = testOutput.entries.count
        eprint("Rendering message", category: .rendering)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, beforeCount, "Rendering should be blocked")
        
        // Test: Layout should be blocked
        eprint("Layout message", category: .layout)
        waitForWrites()
        XCTAssertEqual(testOutput.entries.count, beforeCount, "Layout should be blocked")
    }
    
    // MARK: - Category Display Tests
    
    func testCategoryDisplayInMinimalConfig() {
        let testOutput = TestOutput()
        var minimalConfig = EPrintConfiguration.minimal
        minimalConfig.outputs = [testOutput]
        let eprint = EPrint(configuration: minimalConfig)
        
        eprint("Test message", category: .rendering)
        waitForWrites()
        
        // Minimal config has showCategory = false
        XCTAssertFalse(minimalConfig.showCategory, "Minimal should not show category")
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertEqual(testOutput.entries[0].category, .rendering)
    }
    
    func testCategoryDisplayInStandardConfig() {
        let testOutput = TestOutput()
        var config = EPrintConfiguration.standard
        config.outputs = [testOutput]
        let eprint = EPrint(configuration: config)
        
        eprint("Test message", category: .rendering)
        waitForWrites()
        
        // Standard config should have showCategory = true
        XCTAssertTrue(config.showCategory, "Standard config should show category")
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertEqual(testOutput.entries[0].category, .rendering)
    }
    
    func testCategoryDisplayInVerboseConfig() {
        let testOutput = TestOutput()
        var config = EPrintConfiguration.verbose
        config.outputs = [testOutput]
        let eprint = EPrint(configuration: config)
        
        eprint("Test message", category: .performance)
        waitForWrites()
        
        // Verbose config should have showCategory = true
        XCTAssertTrue(config.showCategory, "Verbose config should show category")
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertEqual(testOutput.entries[0].category, .performance)
    }
    
    func testCategoryDisplayCustomConfig() {
        let testOutput = TestOutput()
        let config = EPrintConfiguration.with(
            fileName: true,
            category: true,
            outputs: [testOutput]
        )
        let eprint = EPrint(configuration: config)
        
        eprint("Test message", category: .network)
        waitForWrites()
        
        // Custom config with category enabled
        XCTAssertTrue(config.showCategory, "Custom config should have showCategory enabled")
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertEqual(testOutput.entries[0].category, .network)
    }
    
    func testNoCategoryDisplayWhenNil() {
        let testOutput = TestOutput()
        var config = EPrintConfiguration.standard
        config.outputs = [testOutput]
        let eprint = EPrint(configuration: config)
        
        eprint("Test message")  // No category
        waitForWrites()
        
        // Should have captured entry with nil category
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertNil(testOutput.entries[0].category, "Entry should have nil category")
    }
    
    // MARK: - Integration with Emoji System Tests
    
    func testEmojiWithCategory() {
        let testOutput = TestOutput()
        let eprint = EPrint(configuration: EPrintConfiguration(outputs: [testOutput]))
        
        eprint(.start, "Test message", category: .rendering)
        waitForWrites()
        
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertTrue(testOutput.entries[0].message.contains("🏁"))
        XCTAssertEqual(testOutput.entries[0].category, .rendering)
    }
    
    func testCustomEmojiWithCategory() {
        enum CustomEmoji: String, EPrintEmoji {
            case api = "🌐"
            var emoji: String { rawValue }
        }
        
        let testOutput = TestOutput()
        let eprint = EPrint(configuration: EPrintConfiguration(outputs: [testOutput]))
        
        eprint(CustomEmoji.api, "API call", category: .network)
        waitForWrites()
        
        XCTAssertEqual(testOutput.entries.count, 1)
        XCTAssertTrue(testOutput.entries[0].message.contains("🌐"))
        XCTAssertEqual(testOutput.entries[0].category, .network)
    }
    
    // MARK: - EPrintEntry Tests
    
    func testEntryWithCategory() {
        let entry = EPrintEntry(
            message: "Test",
            file: "test.swift",
            line: 42,
            function: "testFunc()",
            timestamp: Date(),
            thread: "main",
            category: .rendering
        )
        
        XCTAssertEqual(entry.category, .rendering)
    }
    
    func testEntryWithoutCategory() {
        let entry = EPrintEntry(
            message: "Test",
            file: "test.swift",
            line: 42,
            function: "testFunc()",
            timestamp: Date(),
            thread: "main"
        )
        
        XCTAssertNil(entry.category)
    }
    
    func testEntryEqualityWithCategory() {
        let date = Date()
        let entry1 = EPrintEntry(
            message: "Test",
            file: "test.swift",
            line: 42,
            function: "testFunc()",
            timestamp: date,
            thread: "main",
            category: .rendering
        )
        let entry2 = EPrintEntry(
            message: "Test",
            file: "test.swift",
            line: 42,
            function: "testFunc()",
            timestamp: date,
            thread: "main",
            category: .rendering
        )
        let entry3 = EPrintEntry(
            message: "Test",
            file: "test.swift",
            line: 42,
            function: "testFunc()",
            timestamp: date,
            thread: "main",
            category: .network
        )
        
        XCTAssertEqual(entry1, entry2)
        XCTAssertNotEqual(entry1, entry3)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentCategoryFilterAccess() {
        let eprint = EPrint()
        let expectation = self.expectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100
        
        // Concurrent reads and writes
        DispatchQueue.concurrentPerform(iterations: 100) { i in
            if i % 2 == 0 {
                eprint.categoryFilter = .only([.rendering])
            } else {
                _ = eprint.categoryFilter
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testConcurrentGlobalCategoryFilterAccess() {
        let expectation = self.expectation(description: "Concurrent global access")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { i in
            if i % 2 == 0 {
                EPrint.globalCategoryFilter = .only([.performance])
            } else {
                _ = EPrint.globalCategoryFilter
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
}