//
//  BuilderMacro.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private var buildableTypes: Set<String> = Set()

public struct BuilderMacro: ExtensionMacro {
    public static func expansion(
        of _: AttributeSyntax,
        attachedTo decl: some DeclGroupSyntax,
        providingExtensionsOf _: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let builder = try Struct(decl, buildableTypes: buildableTypes),
              !builder.properties.isEmpty else {
            return []
        }

        buildableTypes.insert(builder.type.name)

        let generatedExtension = try Extension.gen(withBuilder: builder)
        return [generatedExtension]
    }
}
