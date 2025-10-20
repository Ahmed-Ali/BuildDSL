//
//  DSLResultBuilder.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import Foundation

/// A result builder that constrains builder closures to only use builder APIs.
///
/// `DSLResultBuilder` is a key component that ensures type safety and prevents
/// arbitrary code execution within builder closures. It transforms builder
/// method chains into the final build result.
///
/// ## Overview
///
/// This result builder serves as a compile-time safety mechanism that:
/// - Restricts closure content to only builder method calls
/// - Prevents arbitrary code execution within builder closures
/// - Transforms the builder chain into a final `Result` type
/// - Enables clean, declarative syntax for object construction
///
/// ## How It Works
///
/// The result builder processes builder method chains like this:
///
/// ```swift
/// // This builder closure...
/// MyStruct.build { $0
///     .property1("value")
///     .property2(42)
/// }
///
/// // ...is transformed by DSLResultBuilder into a build result
/// ```
///
/// ## Safety Benefits
///
/// Without this result builder, users could execute arbitrary code in closures:
///
/// ```swift
/// // This would be possible without DSLResultBuilder (unsafe):
/// MyStruct.build { builder in
///     print("Executing random code")  // ❌ Not allowed
///     someGlobalFunction()            // ❌ Not allowed
///     return builder.property("value")
/// }
/// ```
///
/// With `DSLResultBuilder`, only builder operations are permitted:
///
/// ```swift
/// // Only builder method chains are allowed (safe):
/// MyStruct.build { $0
///     .property1("value")  // ✅ Builder method
///     .property2(42)       // ✅ Builder method
/// }
/// ```
///
/// - Note: This type is used internally by the ``Builder`` macro and is
///   typically not used directly in application code.
@resultBuilder
public struct DSLResultBuilder<Builder: BuilderAPI> {
    /// Transforms a builder instance into the result builder's intermediate representation.
    ///
    /// - Parameter instance: The builder instance from a method chain.
    /// - Returns: The same builder instance for further chaining.
    public static func buildExpression(_ instance: Builder) -> Builder {
        instance
    }

    /// Handles the first branch of a conditional expression in the builder.
    ///
    /// - Parameter instance: The builder instance from the true branch.
    /// - Returns: The builder instance for continued processing.
    public static func buildEither(first instance: Builder) -> Builder {
        instance
    }

    /// Handles the second branch of a conditional expression in the builder.
    ///
    /// - Parameter instance: The builder instance from the false branch.
    /// - Returns: The builder instance for continued processing.
    public static func buildEither(second instance: Builder) -> Builder {
        instance
    }

    /// Combines builder expressions into a single builder instance.
    ///
    /// This method is called to combine the results of builder method chains
    /// into a single builder that can be used to construct the final result.
    ///
    /// - Parameter builder: The final builder instance after all method calls.
    /// - Returns: The builder instance ready for final result construction.
    public static func buildBlock(_ builder: Builder) -> Builder {
        builder
    }

    /// Converts the final builder into the build result.
    ///
    /// This is the final step in the result builder process, where the
    /// configured builder is asked to construct the target type and return
    /// the appropriate `Result` value.
    ///
    /// - Parameter builder: The fully configured builder instance.
    /// - Returns: A `Result` containing either the successfully built instance
    ///   or a ``BuilderError`` if validation failed.
    public static func buildFinalResult(_ builder: Builder) -> Builder.Result {
        builder.build()
    }
}
