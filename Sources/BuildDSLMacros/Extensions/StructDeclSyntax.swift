//
//  StructDeclSyntax.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftSyntax

extension StructDeclSyntax {
    var memberVariables: [VariableDeclSyntax] {
        memberBlock.members.compactMap {
            guard let v = $0.decl.as(VariableDeclSyntax.self), !v.ignore else {
                return nil
            }
            return v
        }
    }
}
