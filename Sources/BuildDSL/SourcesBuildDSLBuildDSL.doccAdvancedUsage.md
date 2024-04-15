# Advanced BuildDSL Patterns

Learn advanced techniques for using BuildDSL in complex scenarios.

## Overview

This guide covers advanced patterns and techniques for leveraging BuildDSL in sophisticated applications, including custom result builders, complex validation, and integration patterns.

## Custom Result Builder Functions

You can create functions that accept builder closures for more flexible APIs:

```swift
@Builder
struct DatabaseConnection {
    let host: String
    let port: Int
    @Default("postgres") 
    let driver: String
}

// Function accepting builder closure
func connectToDatabase(
    @DatabaseConnection.ResultBuilder 
    configBuilder: DatabaseConnection.BuilderClosure
) async throws -> Connection {
    let config = try DatabaseConnection.build(configBuilder).get()
    return try await connect(to: config)
}

// Usage with builder syntax
let connection = try await connectToDatabase { $0
    .host("localhost")
    .port(5432)
    .driver("postgresql")
}
```

## Complex Validation Patterns

Combine builder validation with custom validation logic:

```swift
@Builder
struct EmailConfiguration {
    let smtpServer: String
    let port: Int
    let username: String
    let password: String
    
    @Default(false)
    let useTLS: Bool
}

extension EmailConfiguration {
    /// Additional validation beyond required fields
    func validate() throws {
        guard !smtpServer.isEmpty else {
            throw ValidationError.invalidServer
        }
        
        guard port > 0 && port <= 65535 else {
            throw ValidationError.invalidPort
        }
        
        guard username.contains("@") else {
            throw ValidationError.invalidUsername  
        }
    }
}

// Usage with additional validation
func setupEmailService(
    @EmailConfiguration.ResultBuilder 
    configBuilder: EmailConfiguration.BuilderClosure
) throws -> EmailService {
    let config = try EmailConfiguration.build(configBuilder).get()
    try config.validate()  // Additional validation
    return EmailService(config: config)
}
```

## Builder Composition Patterns

Create builders that compose other builders:

```swift
@Builder
struct Server {
    let name: String
    let port: Int
}

@Builder
struct Database {
    let connectionString: String
    let poolSize: Int
}

@Builder 
struct Application {
    let name: String
    let server: Server
    let database: Database
    
    @Default([:])
    let environment: [String: String]
}

// Compose complex configurations
let app = Application.build { $0
    .name("MyWebApp")
    .serverBuilder { $0
        .name("web-server-01")
        .port(8080)
    }
    .databaseBuilder { $0
        .connectionString("postgresql://localhost/myapp")
        .poolSize(20)
    }
    .environment([
        "LOG_LEVEL": "info",
        "CACHE_ENABLED": "true"
    ])
}
```

## Conditional Building

Use Swift's conditional syntax within builders:

```swift
@Builder
struct APIConfiguration {
    let baseURL: String
    let apiKey: String
    
    @Default(false)
    let enableDebugLogging: Bool
    
    @Default(30.0)
    let timeout: TimeInterval
}

func createAPIConfig(isProduction: Bool) -> Result<APIConfiguration, BuilderError> {
    APIConfiguration.build { builder in
        builder
            .baseURL(isProduction ? "https://api.prod.com" : "https://api.dev.com")
            .apiKey(isProduction ? productionKey : developmentKey)
            .enableDebugLogging(!isProduction)
            .timeout(isProduction ? 60.0 : 10.0)
    }
}
```

## Generic Builder Patterns

Create generic functions that work with any buildable type:

```swift
/// Generic function to build any BuildableAPI type with error handling
func safeBuild<T: BuildableAPI>(
    _ type: T.Type,
    @T.ResultBuilder builder: T.Closure
) -> T? {
    switch T.build(builder) {
    case .success(let instance):
        return instance
    case .failure(let error):
        print("Build failed for \(type): \(error)")
        return nil
    }
}

// Usage with any builder type
let person = safeBuild(Person.self) { $0
    .firstName("John")
    .lastName("Doe")
    .age(30)
}

let config = safeBuild(APIConfiguration.self) { $0
    .baseURL("https://api.example.com")
    .apiKey("secret-key")
}
```

## Testing Builder Configurations

Create test utilities for builder validation:

```swift
import Testing

@Suite("Configuration Builder Tests")
struct ConfigurationTests {
    
    @Test("Valid configuration builds successfully")
    func validConfigurationBuilds() async throws {
        let result = APIConfiguration.build { $0
            .baseURL("https://api.example.com")
            .apiKey("test-key")
        }
        
        let config = try #require(result.get())
        #expect(config.baseURL == "https://api.example.com")
        #expect(config.apiKey == "test-key")
        #expect(config.enableDebugLogging == false) // Default value
    }
    
    @Test("Missing required field fails build")
    func missingRequiredFieldFails() async throws {
        let result = APIConfiguration.build { $0
            .baseURL("https://api.example.com")
            // Missing apiKey
        }
        
        switch result {
        case .success:
            #expect(false, "Expected build to fail")
        case .failure(let error as BuilderError):
            #expect(error.property == "apiKey")
            #expect(error.container == "APIConfiguration")
        }
    }
}
```

## Integration with Combine

Use builders with Combine publishers:

```swift
import Combine

@Builder
struct NetworkRequest {
    let url: String
    let method: String
    
    @Default([:])
    let headers: [String: String]
}

class NetworkService {
    func makeRequest(
        @NetworkRequest.ResultBuilder 
        requestBuilder: NetworkRequest.BuilderClosure
    ) -> AnyPublisher<Data, Error> {
        NetworkRequest.build(requestBuilder)
            .publisher
            .flatMap { request in
                URLSession.shared.dataTaskPublisher(for: self.urlRequest(from: request))
                    .map(\.data)
            }
            .eraseToAnyPublisher()
    }
    
    private func urlRequest(from request: NetworkRequest) -> URLRequest {
        // Convert builder result to URLRequest
        // Implementation details...
        fatalError("Implementation required")
    }
}
```

## Performance Considerations

### Builder Reuse

For frequently created configurations, consider caching builders:

```swift
class ConfigurationCache {
    private static let productionBuilder: APIConfiguration.BuilderClosure = { $0
        .baseURL("https://api.prod.com")
        .timeout(60.0)
        .enableDebugLogging(false)
    }
    
    static func productionConfig(apiKey: String) -> Result<APIConfiguration, BuilderError> {
        APIConfiguration.build { builder in
            productionBuilder(builder)
                .apiKey(apiKey)
        }
    }
}
```

### Compilation Performance

For complex builders with many properties, consider splitting into smaller builders:

```swift
// Instead of one large builder...
@Builder
struct LargeConfiguration {
    // 20+ properties...
}

// Consider breaking into logical groups...
@Builder
struct NetworkConfiguration {
    let host: String
    let port: Int
    let timeout: TimeInterval
}

@Builder
struct SecurityConfiguration {
    let apiKey: String
    let useHTTPS: Bool
    let certificatePath: String?
}

@Builder
struct ApplicationConfiguration {
    let network: NetworkConfiguration
    let security: SecurityConfiguration
    let appName: String
}
```

## See Also

- ``Builder()`` - The core builder macro
- ``BuilderError`` - Error handling patterns
- ``DSLResultBuilder`` - Result builder implementation
- <doc:GettingStarted> - Basic usage patterns