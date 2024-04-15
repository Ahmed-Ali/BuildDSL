//
//  VariableDeclSyntax.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftSyntax

extension VariableDeclSyntax {
    var isConst: Bool {
        bindingSpecifier.tokenKind == .keyword(.let)
    }

    var isStatic: Bool {
        !modifiers.filter { $0.name.tokenKind == .keyword(.static) }.isEmpty
    }

    var buildableBindngs: PatternBindingListSyntax {
        isConst ? bindings.filter { $0.storedProperty && $0.initialValue == nil }
            : bindings.filter(\.storedProperty)
    }

    var defaultValue: String? {
        let attr = attributes.compactMap {
            switch $0 {
            case let .attribute(attr):
                attr.attributeName.trimmedDescription == "Default" ? attr : nil
            case .ifConfigDecl:
                nil
            }
        }.first

        return attr?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.trimmedDescription
    }

    var ignore: Bool {
        has(attributeWithName: "Ignore")
    }

    var escaping: Bool {
        has(attributeWithName: "Escaping")
    }

    var hasBuilderAttributes: Bool {
        for attrName in MACRO_ATTRIBUTE_NAMES {
            if has(attributeWithName: attrName) {
                return true
            }
        }

        return false
    }

    private func has(attributeWithName name: String) -> Bool {
        !attributes.compactMap {
            switch $0 {
            case let .attribute(attr):
                attr.attributeName.trimmedDescription.starts(with: name) ? attr : nil
            case .ifConfigDecl:
                nil
            }
        }.isEmpty
    }
}
