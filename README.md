# EPrint

A comprehensive debug printing library for Swift.

## Overview

EPrint is a Swift Package that provides enhanced debug printing capabilities for your Swift projects.

## Requirements

- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+
- visionOS 1.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add EPrint to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/EPrint.git", from: "1.0.0")
]
```

## Usage

```swift
import EPrint

// Basic debug print
EPrint.print("This is a debug message")

// Custom prefix
EPrint.print(prefix: "Custom", "This is a custom debug message")
```

## License

[Add your license here]

