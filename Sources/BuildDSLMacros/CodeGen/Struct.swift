//
//  Struct.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct Struct {
    let type: any TypeDecl
    let properties: [Property]
    let accessLevel: String

    init?(
        _ decl: DeclGroupSyntax,
        buildableTypes: Set<String>
    ) throws {
        let (hasError, declDiagnostics) = decl.validateAsStruct()
        guard !hasError else {
            throw DiagnosticsError(diagnostics: declDiagnostics)
        }
        let strct = decl.asStruct!
        let typeName = strct.name.trimmedDescription

        type = Type.create(
            name: typeName,
            options: .usesBuilder
        )
        accessLevel = strct.accessLevel
        var properties: [Property] = []
        var diagnostics: [Diagnostic] = []

        var errors = false
        for member in strct.memberVariables {
            let (hasError, propertyDiagnostics) = member.validateAsVar()
            if !member.isStatic && !hasError,
               let createdProperties = createProperties(
                   for: member,
                   accessLevel: accessLevel,
                   root: type,
                   buildableTypes: buildableTypes
               ) {
                properties.append(contentsOf: createdProperties)
            } else if hasError {
                errors = true
                diagnostics.append(contentsOf: propertyDiagnostics)
            }
        }

        if errors {
            throw DiagnosticsError(diagnostics: diagnostics)
        }

        self.properties = properties
    }
}

extension Struct {
    var decl: String {
        """
        \(accessLevel)final class \(BUILDER_CLASS): \(BUILDER_PROTOCOL) {
        \(accessLevel)typealias \(BUILDABLE_ALIAS) = \(type)

        \(vars)
        \(accessLevel)init() {}
        \(setters)
        \(buildMethod)
        }
        """
    }

    var memberwiseInitParamDecls: String {
        properties.map(\.initParamDecl).joined(separator: ", ")
    }

    var memberwiseInitValueSet: String {
        properties.map(\.initValueSet).joined(separator: "\n")
    }

    private var vars: String {
        properties.map(\.builderVarDecl).joined(separator: "\n")
    }

    private var setters: String {
        properties.flatMap(\.setters).joined(separator: "\n")
    }

    private var buildMethod: String {
        """
        \(accessLevel)func build() -> \(type.buildReturn) {
        \(guardChecks)
        return .success(\(type)(\(initParams)))
        }
        """
    }

    private var guardChecks: String {
        properties.map(\.guardCheck).joined(separator: "\n")
    }

    private var initParams: String {
        properties.map(\.initParam).joined(separator: ", ")
    }
}
