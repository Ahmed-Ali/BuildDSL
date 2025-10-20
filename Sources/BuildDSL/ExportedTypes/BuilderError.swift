//
//  BuilderError.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import Foundation

/// An error type representing validation failures in the builder pattern.
///
/// `BuilderError` is returned when a builder fails to construct an instance
/// due to missing required properties that don't have default values.
///
/// ## Overview
///
/// When using the ``Builder`` macro, generated builders validate that all
/// required properties are set before constructing the target type. If any
/// non-optional properties without default values are missing, the build
/// operation fails with a `BuilderError`.
///
/// ## Usage
///
/// Handle builder errors using standard Swift error handling:
///
/// ```swift
/// let result = MyStruct.build { $0
///     .someProperty("value")
///     // Missing required property "otherProperty"
/// }
///
/// switch result {
/// case .success(let instance):
///     print("Success: \(instance)")
/// case .failure(let error as BuilderError):
///     print("Missing property: \(error.property ?? "unknown")")
///     print("In container: \(error.container ?? "unknown")")
/// }
/// ```
///
/// ## Error Information
///
/// Each error provides detailed information about what went wrong:
///
/// ```swift
/// do {
///     let instance = try MyStruct.build { $0
///         .someProperty("value")
///     }.get()
/// } catch let error as BuilderError {
///     print("Build failed: \(error)")
///     // Outputs: "Missing a non-optional value for MyStruct.otherProperty"
/// }
/// ```
public enum BuilderError: Swift.Error {
    /// Indicates that a required property was not set during the build process.
    ///
    /// - Parameters:
    ///   - property: The name of the missing property
    ///   - container: The name of the type being built
    case missingValueFor(_ property: String, container: String)

    /// The name of the property that was missing during the build.
    ///
    /// - Returns: The property name, or `nil` if not available.
    public var property: String? {
        switch self {
        case let .missingValueFor(property, container: _):
            property
        }
    }

    /// The name of the container type that failed to build.
    ///
    /// - Returns: The container type name, or `nil` if not available.
    public var container: String? {
        switch self {
        case let .missingValueFor(_, container: container):
            container
        }
    }
}

extension BuilderError: CustomStringConvertible {
    /// A human-readable description of the build error.
    ///
    /// The description includes both the container type and the specific
    /// property that was missing.
    ///
    /// ## Example Output
    ///
    /// ```
    /// "Missing a non-optional value for UserProfile.email"
    /// ```
    public var description: String {
        switch self {
        case let .missingValueFor(property, container: container):
            "Missing a non-optional value for \(container).\(property)"
        }
    }
}
