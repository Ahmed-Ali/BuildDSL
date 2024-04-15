//
//  Protocols.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import Foundation

/// A protocol that enables types to participate in the BuildDSL builder pattern.
///
/// Types conforming to `BuildableAPI` gain access to a type-safe builder pattern
/// with compile-time validation and fluent syntax for object construction.
/// 
/// ## Overview
///
/// The ``Builder`` macro automatically generates conformance to this protocol,
/// creating a nested `Builder` type and the necessary build methods.
///
/// - Note: You typically don't implement this protocol directly. Instead, use
///   the ``Builder`` macro which generates the conformance automatically.
public protocol BuildableAPI<Builder> {
    /// The associated builder type that constructs instances of this type.
    associatedtype Builder: BuilderAPI where Builder.Buildable == Self

    /// A result builder type for creating fluent builder closures.
    typealias ResultBuilder = DSLResultBuilder<Builder>
    
    /// The result type returned by build operations, containing either
    /// a successfully built instance or a ``BuilderError``.
    typealias Result = Swift.Result<Self, BuilderError>
    
    /// A closure type that takes a builder and returns a build result.
    typealias Closure = (Builder) -> Self.Builder.Result
}

/// A protocol defining the core builder functionality for constructing buildable types.
///
/// Builder types implement this protocol to provide the actual construction logic
/// and validation for their associated buildable type.
///
/// ## Overview
///
/// The ``Builder`` macro generates types that conform to this protocol, implementing
/// the required `init()` and `build()` methods along with fluent setter methods
/// for each buildable property.
///
/// - Note: You typically don't implement this protocol directly. The ``Builder``
///   macro generates conforming types automatically.
public protocol BuilderAPI<Buildable> {
    /// The type that this builder can construct.
    associatedtype Buildable: BuildableAPI
    
    /// The result type for build operations.
    typealias Result = Buildable.Result

    /// Creates a new builder instance with default values.
    init()

    /// Validates the current builder state and constructs the target type.
    ///
    /// - Returns: A `Result` containing either the successfully built instance
    ///   or a ``BuilderError`` if required properties are missing.
    func build() -> Result
}

extension BuildableAPI {
    /// Creates an instance using the builder pattern with a result builder closure.
    ///
    /// This method provides a type-safe way to construct complex objects using
    /// a fluent builder syntax. The closure uses a result builder to ensure
    /// only valid builder operations can be performed.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let result = MyStruct.build { builder in
    ///     builder
    ///         .property1("value1")
    ///         .property2(42)
    /// }
    /// 
    /// switch result {
    /// case .success(let instance):
    ///     print("Built successfully: \(instance)")
    /// case .failure(let error):
    ///     print("Build failed: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter resBuilder: A closure that configures the builder using
    ///   the result builder syntax. The closure receives a builder instance
    ///   and should return the configured builder.
    ///
    /// - Returns: A `Result` containing either the successfully constructed
    ///   instance or a ``BuilderError`` describing what required properties
    ///   are missing.
    public static func build(
        @ResultBuilder _ resBuilder: Self.Closure
    ) -> Self.Result {
        resBuilder(Builder())
    }
}
