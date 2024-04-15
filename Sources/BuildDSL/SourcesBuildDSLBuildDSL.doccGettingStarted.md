# Getting Started with BuildDSL

Learn how to use BuildDSL to create elegant, type-safe builder patterns for your Swift structs.

## Overview

BuildDSL transforms regular Swift structs into powerful builder APIs using macros. This guide will walk you through the basics and show you how to leverage advanced features.

## Basic Usage

### Creating Your First Builder

Start by importing BuildDSL and applying the `@Builder` macro to your struct:

```swift
import BuildDSL

@Builder
struct Person {
    let firstName: String
    let lastName: String
    let age: Int
}
```

The `@Builder` macro automatically generates:
- A nested `Builder` class with fluent methods
- A static `build(_:)` method returning a `Result`
- A failable initializer for simpler cases

### Building Instances

Use the generated builder API to create instances:

```swift
// Using the static build method (recommended)
let result = Person.build { $0
    .firstName("John")
    .lastName("Doe") 
    .age(30)
}

switch result {
case .success(let person):
    print("Created: \(person)")
case .failure(let error):
    print("Build failed: \(error)")
}

// Using failable initializer (for simpler cases)
let person = Person { $0
    .firstName("Jane")
    .lastName("Smith")
    .age(25)
}
// person is Optional<Person>
```

## Working with Default Values

Use `@Default` to provide default values for properties:

```swift
@Builder
struct Configuration {
    @Default("production")
    let environment: String
    
    @Default(true)
    let enableLogging: Bool
    
    let apiKey: String  // Required field
}

// Default values can be omitted
let config = Configuration.build { $0
    .apiKey("secret-key")
    // environment and enableLogging use defaults
}

// Or override defaults as needed
let devConfig = Configuration.build { $0
    .apiKey("dev-key")
    .environment("development")  // Override default
}
```

## Ignoring Properties

Use `@Ignore` to exclude properties from the builder:

```swift
@Builder  
struct User {
    let username: String
    let email: String
    
    @Ignore
    let id: UUID = UUID()  // Auto-generated, not settable
    
    @Ignore
    var lastLoginDate: Date?  // Managed internally
}

let user = User.build { $0
    .username("johndoe")
    .email("john@example.com")
    // id and lastLoginDate are not available in builder
}
```

## Nested Builders

BuildDSL supports nested builders for complex object graphs:

```swift
@Builder
struct Address {
    let street: String
    let city: String
    let country: String
}

@Builder
struct Company {
    let name: String
    let address: Address
}

// Use nested builders
let company = Company.build { $0
    .name("Tech Corp")
    .addressBuilder { $0
        .street("123 Main St")
        .city("San Francisco")
        .country("USA")
    }
}

// Or construct nested objects separately
let address = Address(street: "456 Oak Ave", city: "Portland", country: "USA")
let company2 = Company.build { $0
    .name("Another Corp")
    .address(address)
}
```

## Error Handling

BuildDSL provides comprehensive error handling for missing required fields:

```swift
@Builder
struct ApiRequest {
    let endpoint: String
    let method: String
    @Default("application/json")
    let contentType: String
}

// This will fail - missing required 'method' field
let result = ApiRequest.build { $0
    .endpoint("/users")
    // .method("GET")  // Commented out - will cause error
}

switch result {
case .success(let request):
    print("Request: \(request)")
case .failure(let error as BuilderError):
    print("Missing field: \(error.property)")  // "method"
    print("In type: \(error.container)")       // "ApiRequest"
}

// Using try/catch for simpler error handling
do {
    let request = try ApiRequest.build { $0
        .endpoint("/users")
        .method("GET")
    }.get()
    print("Success: \(request)")
} catch {
    print("Build failed: \(error)")
}
```

## Working with Closures

For closure properties using type aliases, use `@Escaping`:

```swift
typealias CompletionHandler = (Result<String, Error>) -> Void

@Builder
struct NetworkTask {
    let url: String
    
    @Escaping  // Required for type aliases
    let completion: CompletionHandler
}

let task = NetworkTask.build { $0
    .url("https://api.example.com/data")
    .completion { result in
        switch result {
        case .success(let data):
            print("Got data: \(data)")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}
```

## Best Practices

### 1. Declare Dependencies First

When using nested builders, declare dependent structs before their dependents:

```swift
// ✅ Good - Address declared first
@Builder
struct Address {
    let street: String
    let city: String
}

@Builder  
struct Person {
    let name: String
    let address: Address  // Uses Address declared above
}

// ❌ Avoid - forward reference may cause issues
@Builder
struct Company {
    let address: Office  // Office not yet declared
}

@Builder
struct Office {
    let building: String
}
```

### 2. Use Meaningful Default Values

Provide sensible defaults that work for most use cases:

```swift
@Builder
struct HTTPRequest {
    let url: String
    
    @Default("GET")
    let method: String
    
    @Default([:])
    let headers: [String: String]
    
    @Default(30.0)
    let timeout: TimeInterval
}
```

### 3. Group Related Properties

Organize complex structs by grouping related properties:

```swift
@Builder
struct DatabaseConfig {
    // Connection settings
    let host: String
    let port: Int
    let database: String
    
    // Authentication
    let username: String
    let password: String
    
    // Performance tuning
    @Default(10)
    let maxConnections: Int
    
    @Default(30.0)
    let connectionTimeout: TimeInterval
    
    // Internal state
    @Ignore
    var isConnected: Bool = false
}
```

## Next Steps

- Explore the full API reference for ``Builder()``, ``Default(_:)``, and ``Ignore()``
- Check out advanced examples in the test suite
- Review error handling patterns with ``BuilderError``

## See Also

- ``Builder()`` - The core macro for generating builders
- ``BuilderError`` - Error handling in builders
- ``BuildableAPI`` - Protocol for buildable types