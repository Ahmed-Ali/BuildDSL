//
//  MacroPlugins.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

let PACKAGE_NAME = "BuildDSL"
let MACRO_ATTRIBUTE_NAMES = [
    "Default",
    "Escaping",
    "Ignore"
]

@main
struct DSLBuilderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BuilderMacro.self,
        MarkerMacro.self
    ]
}
