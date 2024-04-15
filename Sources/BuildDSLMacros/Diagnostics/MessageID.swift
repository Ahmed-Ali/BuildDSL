//
//  MessageID.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftDiagnostics

extension MessageID {
    static let unsupportedDeclType =
        MessageID(
            domain: PACKAGE_NAME,
            id: "WrongTypeDeclarationKeyword"
        )

    static let invalidProperty =
        MessageID(
            domain: PACKAGE_NAME,
            id: "InvalidPropertyBindings"
        )
}
