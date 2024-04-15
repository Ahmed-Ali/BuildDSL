# BuildDSL

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_13+_|_macOS_11+_|_tvOS_13+_|_watchOS_6+_|_visionOS_1+-blue.svg)](https://developer.apple.com)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

BuildDSL is a Swift package that offers a robust Domain-Specific Language (DSL) for crafting intuitive builder APIs for Swift structs. It streamlines the creation of complex objects with a clean, type-safe syntax, utilizing Swift's `@resultBuilder`, protocols, and generics, along with an auto-generated Builder pattern.

## Features

- **Type-Safe Builder Pattern**: Auto-generate builders for Swift structs with compile-time type checks.
- **Declarative Syntax**: Employ a succinct DSL to outline your object construction.
- **Automatic Code Generation**: Minimize boilerplate with auto-generated builder code.
- **Nested Builders**: Seamlessly construct complex objects using nested builders.
- **Error Handling**: Utilize `Result` types for comprehensive error handling.
- **Customizable Defaults**: Specify default values for immutable fields with `@Default`.
- **Property Exclusion**: Omit properties from the builder with `@Ignore`.

## Requirements

- **Swift 5.9+**
- **iOS 13.0+ / macOS 11.0+ / tvOS 13.0+ / watchOS 6.0+ / visionOS 1.0+**
- **Xcode 15.0+**

## Installation

### Swift Package Manager

Add BuildDSL to your project with Swift Package Manager by including the following in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Ahmed-Ali/BuildDSL.git", from: "0.1.0")
]
```

Or add it through Xcode by going to `File > Add Package Dependencies` and enter:
```
https://github.com/Ahmed-Ali/BuildDSL.git
```

## Quick Start

Annotate your struct with `@Builder` and use the generated builder API:

```swift
import BuildDSL

@Builder
struct Person {
    let name: String
    let email: String
    @Default(Date())
    let createdAt: Date
    @Ignore
    var isVerified: Bool = false
}

// Create instances using the fluent builder API
let result = Person.build { $0
    .name("John Doe")
    .email("john@example.com")
}

switch result {
case .success(let person):
    print("Created: \(person)")
case .failure(let error):
    print("Build failed: \(error)")
}
```

## Documentation

📚 **[Complete Documentation](https://ahmed-ali.github.io/BuildDSL/)**

The full API documentation is available online, including:

- **Getting Started Guide**: Learn the basics with step-by-step examples
- **API Reference**: Complete documentation for all macros and types
- **Advanced Patterns**: Sophisticated usage scenarios and best practices
- **Migration Guide**: How to integrate BuildDSL into existing projects

### Key Documentation Topics

- [`@Builder`](https://ahmed-ali.github.io/BuildDSL/documentation/builddsl/builder()): The core macro for generating builder patterns
- [`@Default`](https://ahmed-ali.github.io/BuildDSL/documentation/builddsl/default(_:)): Setting default values for properties
- [`@Ignore`](https://ahmed-ali.github.io/BuildDSL/documentation/builddsl/ignore()): Excluding properties from builders
- [`@Escaping`](https://ahmed-ali.github.io/BuildDSL/documentation/builddsl/escaping()): Handling closure properties
- [`BuilderError`](https://ahmed-ali.github.io/BuildDSL/documentation/builddsl/buildererror): Error handling in builders

## Examples

For comprehensive examples, see:
- [Sources/BuildDSLClient/main.swift](Sources/BuildDSLClient/main.swift) - Real-world usage examples
- [Tests/BuildDSLTests/MacroUsageTests.swift](Tests/BuildDSLTests/MacroUsageTests.swift) - Test cases covering all features

## FAQ

- **Why use `@resultBuilder` instead of a closure?**  
  `@resultBuilder` ensures the closure is solely used for object construction, preventing arbitrary code execution and potential misuse.

- **Are there benefits to using Builder pattern + `@resultBuilder` over just a Builder?**  
  Yes, it enhances discoverability and IDE assistance, making it easier to understand how to initialize objects with complex configurations.

## Known Limitations & Workarounds

- **Initialization**: Structs must have a memberwise initializer. Exclude properties with `@Ignore` and provide default values or implement the initializer yourself.
- **Buildable Dependencies**: Declare dependent structs before dependees to ensure proper macro execution and avoid compilation errors.
- **Autocomplete**: While macros and Swift's Generics with `@resultBuilder` are powerful, IDE autocomplete may be less helpful with complex nested types. Patience and manual code entry may be required at times.

## Contribution

Contributions are welcomed! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Add** tests for your changes
4. **Ensure** all tests pass (`swift test`)
5. **Run** SwiftLint (`swiftlint`)
6. **Commit** your changes (`git commit -m 'Add amazing feature'`)
7. **Push** to the branch (`git push origin feature/amazing-feature`)
8. **Create** a Pull Request

Please make sure to:
- Write tests for any new functionality
- Follow the existing code style and conventions
- Update documentation if needed
- Ensure CI passes

## License

BuildDSL is released under the MIT License. See [LICENSE](LICENSE) for details.

---

Happy building with BuildDSL! 🚀
