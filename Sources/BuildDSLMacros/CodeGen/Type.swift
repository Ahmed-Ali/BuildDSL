//
//  Type.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import Foundation
import SwiftSyntax
let BUILDER_CLASS = "Builder"
let BUILDER_ERROR_ENUM_NAME = "BuilderError"
let BUILDER_RESULT_BUILDER_ALIAS = "ResultBuilder"
let BUILDER_RESULT_BUILDER_TYPE = "DSLResultBuilder"

let RESULT_BUILDER_CLOSURE_ALIAS = "Closure"
let BUILDER_FAILABLE_RETURN_ALIAS = "Result"

let BUILDER_PROTOCOL = "BuilderAPI"
let BUILDABLE_PROTOCOL = "BuildableAPI"
let BUILDABLE_ALIAS = "Buildable"

struct TypeOptions: OptionSet {
    let rawValue: Int

    static let usesBuilder = TypeOptions(rawValue: 1 << 1)
    static let escaping = TypeOptions(rawValue: 1 << 2)
    static let closure = TypeOptions(rawValue: 1 << 3)
}

protocol TypeDecl: CustomStringConvertible {
    var prevDecl: (any TypeDecl)? { get }

    var name: String { get }
    var options: TypeOptions { get }
    var initParamType: String { get }
    var setterParam: String { get }
    var setterBody: String { get }
    var varDecl: String { get }
    var builder: String { get }
    var error: String { get }
    var buildReturn: String { get }
    var resultBuilder: String { get }
    var resultBuilderClosure: String { get }
    var resultBuilderAsParam: String { get }
    var valueFromResultBuilderParam: String { get }

    func initialValueAssignment(for value: String) -> String
}

extension TypeDecl {
    var prevDecl: (any TypeDecl)? {
        nil
    }

    var name: String {
        if let n = prevDecl?.name {
            return n
        }
        assertionFailure("Type's name must be implemented by one of the types in the chain")
        return ""
    }

    var options: TypeOptions {
        prevDecl?.options ?? []
    }

    var varDecl: String {
        prevDecl?.varDecl ?? name
    }

    var initParamType: String {
        prevDecl?.initParamType ?? name
    }

    var setterParam: String {
        prevDecl?.setterParam ?? "_ value: \(name)"
    }

    var setterBody: String {
        prevDecl?.setterBody ?? "value"
    }

    var builder: String {
        prevDecl?.builder ?? "\(name).\(BUILDER_CLASS)"
    }

    var error: String {
        prevDecl?.error ?? BUILDER_ERROR_ENUM_NAME
    }

    var buildReturn: String {
        prevDecl?.buildReturn ?? "\(name).\(BUILDER_FAILABLE_RETURN_ALIAS)"
    }

    var resultBuilder: String {
        prevDecl?.resultBuilder ?? "\(name).\(BUILDER_RESULT_BUILDER_ALIAS)"
    }

    var resultBuilderClosure: String {
        prevDecl?.resultBuilderClosure ?? "\(name).\(RESULT_BUILDER_CLOSURE_ALIAS)"
    }

    var resultBuilderAsParam: String {
        prevDecl?
            .resultBuilderAsParam ?? "@\(resultBuilder) _ resultBuilder: \(resultBuilderClosure)"
    }

    var valueFromResultBuilderParam: String {
        prevDecl?.valueFromResultBuilderParam ?? "resultBuilder(\(builder)())"
    }

    var description: String {
        prevDecl?.name ?? name
    }

    func initialValueAssignment(for value: String) -> String {
        prevDecl?.initialValueAssignment(for: value) ?? " = \(value)"
    }
}

struct Type: TypeDecl {
    let name: String
    let options: TypeOptions

    static func create(name: String, options: TypeOptions) -> any TypeDecl {
        let defaultType = Type(name: name, options: options)
        if !options.isEmpty {
            return create(prevType: defaultType, options: options)
        }
        return defaultType
    }
}

struct BuilderType: TypeDecl {
    var prevDecl: (any TypeDecl)?

    init(prevDecl: any TypeDecl) {
        self.prevDecl = prevDecl
    }

    var varDecl: String {
        buildReturn
    }

    var setterBody: String {
        ".success(value)"
    }

    func initialValueAssignment(for value: String) -> String {
        " = .success(\(value))"
    }
}

struct EscapingType: TypeDecl {
    var prevDecl: (any TypeDecl)?

    init(prevDecl: any TypeDecl) {
        self.prevDecl = prevDecl
    }

    var initParamType: String {
        "@escaping \(name)"
    }

    var setterParam: String {
        "_ value: @escaping \(name)"
    }
}

struct ClosureType: TypeDecl {
    var prevDecl: (any TypeDecl)?

    init(prevDecl: any TypeDecl) {
        self.prevDecl = prevDecl
    }

    var varDecl: String {
        "(\(name))"
    }

    var initParamType: String {
        "@escaping \(name)"
    }

    var setterParam: String {
        "_ value: @escaping \(name)"
    }
}

extension TypeDecl {
    static func create(prevType: any TypeDecl, options: TypeOptions) -> any TypeDecl {
        if options.contains(.usesBuilder) {
            return create(
                prevType: BuilderType(prevDecl: prevType),
                options: options.subtracting(.usesBuilder)
            )
        }

        if options.contains(.escaping) {
            return create(
                prevType: EscapingType(prevDecl: prevType),
                options: options.subtracting(.escaping)
            )
        }

        if options.contains(.closure) {
            return create(
                prevType: ClosureType(prevDecl: prevType),
                options: options.subtracting(.closure)
            )
        }

        return prevType
    }
}
