//
//  StructDiagnostics.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension DeclGroupSyntax {
    func validateAsStruct() -> (hasError: Bool, diagnostics: [SwiftDiagnostics.Diagnostic]) {
        guard let strct = asStruct else {
            return (true, [unsupportedDecl(self)])
        }

        guard !strct.isOptionSet else {
            return (true, [optionSetIsNotSupported(self)])
        }

        return (false, [])
    }

    private func optionSetIsNotSupported(_ declaration: DeclGroupSyntax) -> SwiftDiagnostics
        .Diagnostic {
        SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "@Builder doesn't support OptionSet",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: []
        )
    }

    private func unsupportedDecl(_ declaration: DeclGroupSyntax) -> SwiftDiagnostics.Diagnostic {
        var fixits: [FixIt] = []
        if let convertable = declaration.toStructConversion {
            fixits.append(FixIt(
                message: SimpleDiagnosticMessage(
                    message: "replace with 'struct'",
                    diagnosticID: MessageID.unsupportedDeclType,
                    severity: .error
                ),
                changes: [
                    FixIt.Change.replace(
                        oldNode: Syntax(convertable.token),
                        newNode: Syntax(convertable.toStructToken)
                    )
                ]
            ))
        }

        return SwiftDiagnostics.Diagnostic(
            node: declaration,
            message: SimpleDiagnosticMessage(
                message: "@Builder only works on structs",
                diagnosticID: MessageID.unsupportedDeclType,
                severity: .error
            ),
            fixIts: fixits
        )
    }
}
