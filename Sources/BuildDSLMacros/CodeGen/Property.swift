//
//  Property.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct Property {
    let accessLevel: String
    let name: String
    let type: any TypeDecl
    let root: any TypeDecl
    let initialValue: String?
    let isOptional: Bool
}

func createProperties(
    for varDecl: VariableDeclSyntax,
    accessLevel: String,
    root: any TypeDecl,
    buildableTypes: Set<String>
) -> [Property]? {
    // filter out getter-only and const with initial value properties
    let bindings = varDecl.bindings.filter(\.storedProperty)
    var properties: [Property] = []

    var typeOptions: TypeOptions = []
    if varDecl.escaping {
        typeOptions.insert(.escaping)
    }

    for varBinding in bindings {
        guard let bindingType = varBinding.type else {
            return nil
        }

        guard let propertyName = varBinding.name else {
            return nil
        }

        let initialValue = (varBinding.initialValue ?? varDecl.defaultValue)?.replacingOccurrences(
            of: "Self",
            with: root.name
        )

        let type = bindingType.replacingOccurrences(
            of: "Self",
            with: root.name
        )

        if buildableTypes.contains(type) {
            typeOptions.insert(.usesBuilder)
        }

        if varBinding.isClosure {
            typeOptions.insert(.closure)
        }

        properties.append(
            Property(
                accessLevel: accessLevel,
                name: propertyName,
                type: Type.create(
                    name: type,
                    options: typeOptions
                ),
                root: root,
                initialValue: initialValue,
                isOptional: varBinding.isOptional
            )
        )
    }

    return properties
}

// MARK: Builder var declaration

extension Property {
    var builderVarDecl: String {
        "private var \(name): \(type.varDecl)?\(initialAssignment)"
    }

    private var initialAssignment: String {
        if let initialValue, initialValue != "nil" {
            return type.initialValueAssignment(for: initialValue)
        }
        return ""
    }
}

// MARK: Setters

extension Property {
    var setters: [String] {
        [
            regularSetter,
            builderSetter
        ].filter { !$0.isEmpty }
    }

    private var regularSetter: String {
        """
        @discardableResult
        \(accessLevel)func \(name)(\(
            type
                .setterParam
        )) -> \(root.builder) {
        self.\(name) = \(type.setterBody)
        return self
        }
        """
    }

    private var builderSetter: String {
        guard type.options.contains(.usesBuilder) else {
            return ""
        }

        return
            """
            @discardableResult
            \(accessLevel)func \(name)Builder(\(
                type.resultBuilderAsParam
            )) -> \(root.builder) {
            self.\(name) = \(type.valueFromResultBuilderParam)
            return self
            }
            """
    }
}

// MARK: Guard checks

extension Property {
    var guardCheck: String {
        if type.options.contains(.usesBuilder) {
            return builderGuardCheck
        } else if !isOptional {
            return
                """
                guard let \(name) else {
                return .failure(\(
                    root.error
                ).missingValueFor("\(name)", container: "\(root)"))
                }
                """
        }

        return ""
    }

    private var builderGuardCheck: String {
        if isOptional {
            return "let \(name) = try? \(name)?.get()"
        }

        return
            """
            guard let \(name) = try? \(name)?.get() else {
            switch \(name) {
            case let .failure(e):
            return .failure(e)
            case .success(_), .none:
            return .failure(\(root.error).missingValueFor("\(name)", container: "\(root)"))
            }
            }
            """
    }
}

// MARK: Init params

extension Property {
    var initParam: String {
        "\(name): \(name)"
    }

    var initParamDecl: String {
        "\(name): \(type.initParamType)"
    }

    var initValueSet: String {
        "self.\(name) = \(name)"
    }
}
