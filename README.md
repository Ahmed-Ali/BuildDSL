# BuildDSL

BuildDSL is a Swift package that offers a robust Domain-Specific Language (DSL) for crafting intuitive builder APIs for Swift structs. It streamlines the creation of complex objects with a clean, type-safe syntax, utilizing Swift's `@resultBuilder`, protocols, and generics, along with an auto-generated Builder pattern.

## Features

- **Type-Safe Builder Pattern**: Auto-generate builders for Swift structs with compile-time type checks.
- **Declarative Syntax**: Employ a succinct DSL to outline your object construction.
- **Automatic Code Generation**: Minimize boilerplate with auto-generated builder code.
- **Nested Builders**: Seamlessly construct complex objects using nested builders.
- **Error Handling**: Utilize `Result` types for comprehensive error handling.
- **Customizable Defaults**: Specify default values for immutable fields with `@Default`.
- **Property Exclusion**: Omit properties from the builder with `@Ignore`.

## Installation

### Swift Package Manager

Add BuildDSL to your project with Swift Package Manager by including the following in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Ahmed-Ali/BuildDSL.git", from:"0.1.0")
]
```

## Usage

Annotate your struct with `@Builder` and use `@Default`, `@Ignore`, and `@Escaping` for struct fields. Here's an example:

```swift
import BuildDSL

@Builder
struct Post {
    let title: String
    let content: String
    @Default(Date())
    let createdOn: Date
    @Ignore
    var popularityScore: Int = 5
}

// Create a Post using the generated Builder
let post = Post { $0
    .title("BuildDSL")
    .content("Building Intuitive Builder API with BuildDSL")
}

// Handle errors with try-catch
do {
    let mustHavePost = try Post.build { $0
        // ...
    }.get()
} catch {
    // Error handling
}

// Or use a switch statement
let result = Post.build { $0.title("Title") }
switch result {
    case .success(let post):
        // Required fields are set
    case .failure(let error):
        // Inspect error.container and error.property
}
```

For more examples, see [Sources/BuildDSLClient/main.swift](Sources/BuildDSLClient/main.swift) and [Tests/BuildDSLTests/MacroUsageTests.swift](Tests/BuildDSLTests/MacroUsageTests.swift).
The [Sources/BuildDSL/Macros.swift](Sources/BuildDSL/Macros.swift) also documents each macro in details

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
PRs and issues are always welcome. I will create a more comprehensive cotribution guidance if needed.

Happy building with BuildDSL!
