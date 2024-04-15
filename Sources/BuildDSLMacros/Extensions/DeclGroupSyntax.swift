//
//  DeclGroupSyntax.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import SwiftSyntax

let accessLevelText: [Keyword: String] = [
    .package: "package ",
    .public: "public "
]

extension DeclGroupSyntax {
    var accessLevel: String {
        for m in modifiers {
            if case let .keyword(kw) = m.name.tokenKind,
               let visibility = accessLevelText[kw] {
                return visibility
            }
        }
        return ""
    }

    var isOptionSet: Bool {
        inheritanceClause?.inheritedTypes.contains { $0.trimmedDescription == "OptionSet" } ?? false
    }

    var asStruct: StructDeclSyntax? {
        self.as(StructDeclSyntax.self)
    }
}
