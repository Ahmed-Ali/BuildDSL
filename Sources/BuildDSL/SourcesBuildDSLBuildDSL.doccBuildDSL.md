# ``BuildDSL``

A powerful Swift package for creating type-safe, declarative builder patterns using macros.

## Overview

BuildDSL provides a robust Domain-Specific Language (DSL) for crafting intuitive builder APIs for Swift structs. It streamlines the creation of complex objects with clean, type-safe syntax, utilizing Swift's `@resultBuilder`, protocols, and generics, along with an auto-generated Builder pattern.

### Key Features

- **Type-Safe Builder Pattern**: Auto-generate builders for Swift structs with compile-time type checks
- **Declarative Syntax**: Use a succinct DSL to outline your object construction
- **Automatic Code Generation**: Minimize boilerplate with auto-generated builder code
- **Nested Builders**: Seamlessly construct complex objects using nested builders
- **Comprehensive Error Handling**: Utilize `Result` types for robust error handling
- **Customizable Defaults**: Specify default values for immutable fields with ``Default(_:)``
- **Property Exclusion**: Omit properties from the builder with ``Ignore()``

## Getting Started

Add BuildDSL to your project using Swift Package Manager and start building with the ``Builder()`` macro:

```swift
import BuildDSL

@Builder
struct UserProfile {
    let name: String
    let email: String
    
    @Default(Date())
    let createdAt: Date
    
    @Ignore
    var isVerified: Bool = false
}

// Create instances using the fluent builder API
let profile = UserProfile.build { $0
    .name("John Doe")
    .email("john@example.com")
}
```

## Topics

### Essential Macros

- ``Builder()``
- ``Default(_:)``
- ``Ignore()``
- ``Escaping()``

### Core Protocols

- ``BuildableAPI``
- ``BuilderAPI``

### Error Handling

- ``BuilderError``

### Result Builder

- ``DSLResultBuilder``

## Requirements

- **Swift 5.9+**
- **iOS 13.0+ / macOS 11.0+ / tvOS 13.0+ / watchOS 6.0+ / visionOS 1.0+**
- **Xcode 15.0+**