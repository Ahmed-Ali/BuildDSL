//
//  VariableDiagnostics.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension DeclSyntaxProtocol {
    func validateAsVar() -> (hasError: Bool, diagnostics: [SwiftDiagnostics.Diagnostic]) {
        var diagnostics: [SwiftDiagnostics.Diagnostic] = []

        guard let asVar = self.as(VariableDeclSyntax.self), !asVar.hasError else {
            return (true, [invalidProperty(self)])
        }
        var hasError = false

        let isStatic = asVar.isStatic
        let hasBuilderAttributes = asVar.hasBuilderAttributes
        if isStatic && hasBuilderAttributes {
            return (true, [unsupportedDecl(self)])
        } else if isStatic {
            return (false, [])
        }
        let defaultValue = asVar.defaultValue
        var types = Set<String>()
        asVar.bindings.forEach { b in

            if defaultValue != nil && b.initialValue != nil {
                hasError = true
                diagnostics.append(useDefaultAttributeOrDefaultValue(b))
            }

            if b.type == nil {
                hasError = true
                diagnostics.append(noPropertyType(b))
            }

            if b.name == nil {
                hasError = true
                diagnostics.append(noPropertyName(b))
            }

            types.insert(b.type ?? "")
        }

        if defaultValue != nil && types.count > 1 {
            hasError = true
            diagnostics.append(multipleTypesForProprtyWithDefaultValue(self))
        }

        return (hasError, diagnostics)
    }

    private func noPropertyType(_ declaration: PatternBindingSyntax) -> SwiftDiagnostics
        .Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "couldn't infer property type",
                diagnosticID: MessageID.invalidProperty,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func noPropertyName(_ declaration: PatternBindingSyntax) -> SwiftDiagnostics
        .Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "couldn't parse the property name",
                diagnosticID: MessageID.invalidProperty,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func unsupportedDecl(_ declaration: some DeclSyntaxProtocol)
        -> SwiftDiagnostics.Diagnostic {
        let attrs = MACRO_ATTRIBUTE_NAMES.map { "@\($0)" }.joined(separator: ", ")
        return SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "\(attrs) work on non-static struct member properties only",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func staticPropertyWithBuilderAttributs(_ declaration: some DeclSyntaxProtocol)
        -> SwiftDiagnostics
        .Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "Static properties are not supported",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func invalidDefaultDecl(_ declaration: some DeclSyntaxProtocol) -> SwiftDiagnostics
        .Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "@Default unable to parse the property",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func invalidProperty(_ declaration: some DeclSyntaxProtocol) -> SwiftDiagnostics
        .Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "Invalid property",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func multipleTypesForProprtyWithDefaultValue(_ declaration: some DeclSyntaxProtocol)
        -> SwiftDiagnostics.Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "@Default value can't be applied on properties with different or missing types",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func useDefaultAttributeOrDefaultValue(_ declaration: PatternBindingSyntax)
        -> SwiftDiagnostics.Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "Chose to set the default value using either @Default or the assignment operator not both",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: []
        )
    }
}
