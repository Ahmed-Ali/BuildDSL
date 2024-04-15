//
//  PatternBindingSyntax.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import Foundation
import SwiftSyntax

extension PatternBindingSyntax {
    var storedProperty: Bool {
        switch accessorBlock?.accessors {
        case let .accessors(accessor):
            for a in accessor {
                switch a.accessorSpecifier.tokenKind {
                case .keyword(.willSet),
                     .keyword(.didSet),
                     .keyword(.set):
                    return true
                default:
                    return false
                }
            }
        case .getter:
            return false

        case .none:
            break
        }

        return true
    }

    var initialValue: String? {
        initializer?.value.trimmedDescription
    }

    var rawType: String? {
        typeAnnotation?.type.trimmedDescription
    }

    var type: String? {
        closureType?.trimmedDescription ??
            (optionalWrappedType ?? typeAnnotation?.type)?.trimmedDescription
    }

    var name: String? {
        pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmedDescription
    }

    var isOptional: Bool {
        optionalWrappedType != nil
    }

    var isClosure: Bool {
        closureType != nil
    }

    private var optionalType: OptionalTypeSyntax? {
        typeAnnotation?.type.as(OptionalTypeSyntax.self)
    }

    private var implicitlyUnwrapOptionalType: ImplicitlyUnwrappedOptionalTypeSyntax? {
        typeAnnotation?.type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self)
    }

    private var optionalWrappedType: TypeSyntax? {
        optionalType?.wrappedType ?? implicitlyUnwrapOptionalType?.wrappedType
    }

    private var optionalWrappedTupple: TupleTypeSyntax? {
        optionalWrappedType?.as(TupleTypeSyntax.self)
    }

    private var closureType: FunctionTypeSyntax? {
        guard let optionalWrappedTupple, optionalWrappedTupple.elements.count == 1,
              let element = optionalWrappedTupple.elements.first else {
            return typeAnnotation?.type.as(FunctionTypeSyntax.self)
        }
        return element.type.as(FunctionTypeSyntax.self)
    }
}
