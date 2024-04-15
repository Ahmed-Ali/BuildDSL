//
//  Macros.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//
/// Generates a type-safe builder pattern for Swift structs with compile-time validation.
///
/// The `@Builder` macro automatically generates boilerplate code that enables a simple,
/// intuitive, and safe instance creation approach using Swift's result builder pattern.
///
/// ## Overview
///
/// When applied to a struct, this macro generates:
/// - A nested `Builder` class with fluent setter methods
/// - A static `build(_:)` method that returns a `Result<YourStruct, BuilderError>`
/// - A failable initializer that accepts a builder closure
/// - Support for nested builders when working with complex object graphs
///
/// ## Usage
///
/// Apply the `@Builder` macro to any struct to enable the builder pattern:
///
/// ```swift
/// @Builder
/// struct UserAgent {
///     let client: String
///     let os: String
///     
///     @Ignore
///     var fullHeader: String = "User-Agent Header"
/// }
/// 
/// @Builder
/// struct NetworkConfig {
///     @Default(Region.US)
///     let region: Region
///     let userAgent: UserAgent
/// }
/// ```
///
/// ## Creating Instances
///
/// Use the generated builder API to create instances:
///
/// ```swift
/// // Using the static build method (returns Result)
/// let config = NetworkConfig.build { builder in
///     builder
///         .region(.ASIA)  // Override default value
///         .userAgentBuilder { userAgentBuilder in
///             userAgentBuilder
///                 .client("MyApp")
///                 .os("macOS")
///         }
/// }
/// 
/// // Handle the Result
/// switch config {
/// case .success(let networkConfig):
///     print("Configuration created: \(networkConfig)")
/// case .failure(let error):
///     print("Missing required field: \(error)")
/// }
/// 
/// // Using failable initializer (returns Optional)
/// let optionalConfig = NetworkConfig { $0
///     .userAgent(UserAgent(client: "MyApp", os: "macOS"))
/// }
/// ```
///
/// ## Error Handling
///
/// The builder validates that all required properties are set:
///
/// ```swift
/// do {
///     let config = try NetworkConfig.build { $0
///         .userAgent(UserAgent(client: "MyApp", os: "macOS"))
///         // region will use default value
///     }.get()
/// } catch {
///     print("Build failed: \(error)")
/// }
/// ```
///
/// ## Advanced Usage
///
/// Use the generated result builder in your own functions:
///
/// ```swift
/// func createNetworkClient(
///     @NetworkConfig.ResultBuilder 
///     configBuilder: NetworkConfig.BuilderClosure
/// ) {
///     let config = try? NetworkConfig.build(configBuilder).get()
///     // Use config...
/// }
/// 
/// // Call with builder syntax
/// createNetworkClient { $0
///     .userAgent(UserAgent(client: "CustomClient", os: "iOS"))
/// }
/// ```
///
/// - Note: Structs must have a memberwise initializer available. Use `Ignore`
///   for properties that shouldn't appear in the builder, and `Default(_:)`
///   for properties with default values.
///
/// - Important: When using nested builders, declare dependent structs before 
///   their dependents to ensure proper macro execution order.
@attached(extension, conformances: BuildableAPI, names: arbitrary)
public macro Builder() =
    #externalMacro(
        module: "BuildDSLMacros",
        type: "BuilderMacro"
    )

/// Specifies a default value for a property in a builder pattern.
///
/// The `@Default` macro allows you to provide default values for both `var` and `let` 
/// properties in structs annotated with ``Builder``. When a property has a default value,
/// it becomes optional in the builder and will use the specified default if not set.
///
/// ## Overview
///
/// Unlike Swift's normal default value syntax which only works with `var` properties,
/// `@Default` enables default values for `let` properties as well, making immutable
/// properties with sensible defaults possible in the builder pattern.
///
/// ## Usage
///
/// Apply `@Default` with a value to any property:
///
/// ```swift
/// @Builder
/// struct Configuration {
///     @Default("Production")
///     let environment: String
///     
///     @Default(true) 
///     let enableLogging: Bool
///     
///     @Default(TimeInterval(30))
///     let timeout: TimeInterval
///     
///     let apiKey: String  // Required field, no default
/// }
/// ```
///
/// ## Creating Instances
///
/// Properties with defaults can be omitted from the builder:
///
/// ```swift
/// // Use all defaults
/// let config = Configuration.build { $0
///     .apiKey("secret-key")
///     // environment, enableLogging, and timeout will use defaults
/// }
/// 
/// // Override specific defaults
/// let customConfig = Configuration.build { $0
///     .apiKey("secret-key")
///     .environment("Development")  // Override default
///     .timeout(60)                 // Override default
///     // enableLogging still uses default (true)
/// }
/// ```
///
/// ## Supported Types
///
/// `@Default` accepts any value that can be expressed as a literal or static expression:
///
/// ```swift
/// @Builder
/// struct Examples {
///     @Default(42)
///     let number: Int
///     
///     @Default("Hello")
///     let text: String
///     
///     @Default([1, 2, 3])
///     let numbers: [Int]
///     
///     @Default(Date())
///     let timestamp: Date
///     
///     @Default(Region.us)
///     let region: Region  // Enum case
/// }
/// ```
///
/// - Parameter value: The default value to use when the property is not set in the builder.
///   This value is captured at compile time and used during object construction.
///
/// - Note: The default value must be compatible with the property's type and should be
///   a compile-time constant or easily evaluated expression.
@attached(peer)
public macro Default(_ value: Any) =
    #externalMacro(
        module: "BuildDSLMacros",
        type: "MarkerMacro"
    )

/// Excludes a property from the generated builder pattern.
///
/// The `@Ignore` macro prevents a property from having a setter method generated
/// in the builder. This is useful for computed properties, internal state, or
/// properties that should be initialized through other means.
///
/// ## Overview
///
/// Properties marked with `@Ignore` will not appear in the generated builder API.
/// These properties must be initialized either with a default value at declaration
/// or through a custom initializer.
///
/// ## Usage
///
/// Apply `@Ignore` to any property that should not be part of the builder:
///
/// ```swift
/// @Builder
/// struct UserProfile {
///     let name: String
///     let email: String
///     
///     @Ignore
///     var lastLogin: Date = Date()  // Computed/managed internally
///     
///     @Ignore
///     let id: UUID = UUID()         // Auto-generated, not user-settable
/// }
/// ```
///
/// ## Initialization Requirements
///
/// Properties marked with `@Ignore` must be initialized. You can do this in several ways:
///
/// ### Option 1: Default Value at Declaration
/// ```swift
/// @Builder
/// struct Config {
///     let apiKey: String
///     
///     @Ignore
///     var debugMode: Bool = false  // Has default value
/// }
/// ```
///
/// ### Option 2: Custom Initializer
/// ```swift
/// @Builder
/// struct Config {
///     let apiKey: String
///     
///     @Ignore
///     let sessionId: String  // No default here
/// }
/// 
/// extension Config {
///     init(apiKey: String) {
///         self.apiKey = apiKey
///         self.sessionId = UUID().uuidString  // Set in initializer
///     }
/// }
/// ```
///
/// ## Use Cases
///
/// Common scenarios for using `@Ignore`:
///
/// - **Computed properties**: Values derived from other properties
/// - **Internal state**: Properties managed by the object itself  
/// - **Auto-generated values**: UUIDs, timestamps, etc.
/// - **Cached values**: Properties that are calculated and cached
/// - **Legacy compatibility**: Properties that shouldn't be in new builder API
///
/// ```swift
/// @Builder
/// struct Article {
///     let title: String
///     let content: String
///     
///     @Ignore
///     var wordCount: Int {  // Computed property
///         content.split(separator: " ").count
///     }
///     
///     @Ignore
///     let createdAt: Date = Date()  // Auto-generated
/// }
/// ```
///
/// ## Builder Usage
///
/// The generated builder will only include non-ignored properties:
///
/// ```swift
/// let article = Article.build { $0
///     .title("SwiftUI Tips")
///     .content("Here are some great SwiftUI tips...")
///     // wordCount and createdAt are not available in builder
/// }
/// ```
///
/// - Important: The initializer parameter order and names must match the memberwise
///   initializer exactly when providing a custom initializer for ignored properties.
@attached(peer)
public macro Ignore() =
    #externalMacro(
        module: "BuildDSLMacros",
        type: "MarkerMacro"
    )

/// Marks closure properties to use `@escaping` in the generated builder setter.
///
/// The `@Escaping` macro helps resolve compiler errors when working with closure
/// properties that use type aliases or aren't recognized as closures by the macro system.
/// It ensures the generated setter method properly marks the closure parameter as `@escaping`.
///
/// ## Overview
///
/// Swift requires closure parameters to be marked as `@escaping` when they're stored
/// in properties. The ``Builder`` macro automatically detects most closure types, but
/// when using type aliases or complex closure types, manual annotation may be needed.
///
/// ## When to Use
///
/// Use `@Escaping` when you encounter compiler errors about non-escaping closures
/// being assigned to stored properties, particularly with:
/// - Type aliases for closure types
/// - Complex closure signatures
/// - Generic closure types
///
/// ## Usage
///
/// ### Problem Case
/// Without `@Escaping`, this fails to compile:
///
/// ```swift
/// typealias CompletionHandler = (Result<String, Error>) -> Void
/// 
/// @Builder
/// struct NetworkRequest {
///     let url: String
///     let completion: CompletionHandler  // Compiler error!
/// }
/// ```
///
/// **Error**: `Assigning non-escaping parameter 'value' to an @escaping closure`
///
/// ### Solution
/// Apply `@Escaping` to fix the issue:
///
/// ```swift
/// typealias CompletionHandler = (Result<String, Error>) -> Void
/// 
/// @Builder
/// struct NetworkRequest {
///     let url: String
///     
///     @Escaping
///     let completion: CompletionHandler  // Now works correctly!
/// }
/// ```
///
/// ## Generated Code
///
/// The macro generates different setter signatures:
///
/// ### Without @Escaping (type alias - causes error)
/// ```swift
/// func completion(_ value: CompletionHandler) -> Builder {
///     // Error: non-escaping parameter assigned to escaping closure
/// }
/// ```
///
/// ### With @Escaping (correct)
/// ```swift  
/// func completion(_ value: @escaping CompletionHandler) -> Builder {
///     self.completion = value
///     return self
/// }
/// ```
///
/// ## Automatic Detection
///
/// The macro automatically handles these closure types without `@Escaping`:
///
/// ```swift
/// @Builder
/// struct AutoDetected {
///     let simpleCallback: () -> Void              // ✓ Auto-detected
///     let paramCallback: (String) -> Void        // ✓ Auto-detected  
///     let returningCallback: () -> String        // ✓ Auto-detected
///     let complexCallback: (Int, String) -> Bool // ✓ Auto-detected
/// }
/// ```
///
/// ## Builder Usage
///
/// Use the generated builder normally:
///
/// ```swift
/// let request = NetworkRequest.build { $0
///     .url("https://api.example.com/data")
///     .completion { result in
///         switch result {
///         case .success(let data):
///             print("Success: \(data)")
///         case .failure(let error):
///             print("Error: \(error)")
///         }
///     }
/// }
/// ```
///
/// - Note: Only use `@Escaping` when you encounter compiler errors. The macro
///   system automatically handles most closure types correctly.
@attached(peer)
public macro Escaping() =
    #externalMacro(module: "BuildDSLMacros", type: "MarkerMacro")
