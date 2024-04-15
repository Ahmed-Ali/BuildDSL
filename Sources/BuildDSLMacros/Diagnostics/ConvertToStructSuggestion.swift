//
//  ConvertToStructSuggestion.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftSyntax

protocol ConvertToStructSuggestion {
    var token: TokenSyntax { get }
}

extension ConvertToStructSuggestion {
    var toStructToken: TokenSyntax {
        token.with(\.tokenKind, .identifier("struct"))
    }
}

extension EnumDeclSyntax: ConvertToStructSuggestion {
    var token: TokenSyntax {
        enumKeyword
    }
}

extension ActorDeclSyntax: ConvertToStructSuggestion {
    var token: TokenSyntax {
        actorKeyword
    }
}

extension ClassDeclSyntax: ConvertToStructSuggestion {
    var token: TokenSyntax {
        classKeyword
    }
}

extension DeclGroupSyntax {
    var toStructConversion: ConvertToStructSuggestion? {
        self.as(ClassDeclSyntax.self) ?? self.as(ActorDeclSyntax.self) ?? self
            .as(EnumDeclSyntax.self)
    }
}
