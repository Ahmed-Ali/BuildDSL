//
//  BuilderError.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import Foundation

/**
 Every generated Builder will return Result.failure(BuilderError)
 if a non-optional field without a default value hasn't been set
 */
public enum BuilderError: Swift.Error {
    case missingValueFor(_ property: String, container: String)

    public var property: String? {
        switch self {
        case let .missingValueFor(property, container: _):
            return property
        }
    }

    public var container: String? {
        switch self {
        case let .missingValueFor(_, container: container):
            return container
        }
    }
}

extension BuilderError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .missingValueFor(property, container: container):
            return "Missing a non-optional value for \(container).\(property)"
        }
    }
}
