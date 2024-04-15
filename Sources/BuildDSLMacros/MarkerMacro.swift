//
//  MarkerMacro.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/**
 No-op macro. Its main purpose is to retain the attribute where it is placed
 to indicate property configuration
 */
public struct MarkerMacro: PeerMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingPeersOf _: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}
