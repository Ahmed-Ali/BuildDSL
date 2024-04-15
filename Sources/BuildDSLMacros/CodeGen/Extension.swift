//
//  Extension.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum Extension {
    static func gen(withBuilder strct: Struct) throws -> ExtensionDeclSyntax {
        let decl =
            """
            extension \(strct.type): \(BUILDABLE_PROTOCOL) {
            \(
                strct
                    .accessLevel
            )typealias \(BUILDER_RESULT_BUILDER_ALIAS) = \(BUILDER_RESULT_BUILDER_TYPE)<Self.\(
                BUILDER_CLASS
            )>

            \(strct.decl)

            \(failableInitializer(for: strct))
            }
            """

        return try ExtensionDeclSyntax("\(raw: decl)")
    }

    static func failableInitializer(for strct: Struct) -> String {
        """
        \(
            strct
                .accessLevel
        )init?(@\(BUILDER_RESULT_BUILDER_ALIAS) _ resBuilder: \(RESULT_BUILDER_CLOSURE_ALIAS)) {
        guard let this = try? resBuilder(\(BUILDER_CLASS)()).get() else {
        return nil
        }
        self.init(\(strct.properties.map { "\($0.name): this.\($0.name)" }.joined(separator: ", ")))
        }
        """
    }
}
