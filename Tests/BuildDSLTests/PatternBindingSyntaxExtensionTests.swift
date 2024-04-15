//
//  PatternBindingSyntaxExtensionTests.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftDiagnostics
import SwiftSyntax
import XCTest
@testable import BuildDSLMacros

final class PatternBindingSyntaxExtensionTests: XCTestCase {
    func testInitialValue() throws {
        let variable = try VariableDeclSyntax("let myVar: Int = 10, other: Int = 20")
        XCTAssertEqual(variable.bindings.first?.initialValue, "10")
        XCTAssertEqual(variable.bindings.last?.initialValue, "20")
    }

    func testType() throws {
        let variable =
            try VariableDeclSyntax(
                "let first: Int = 10, other: Int?, thirs: Int!, closure: () -> Void, closure2: (() -> Void)?, closure2: (() -> Void)!"
            )
        let bindings = Array(variable.bindings)
        XCTAssertEqual(bindings[0].type, "Int")
        XCTAssertEqual(bindings[1].type, "Int")
        XCTAssertEqual(bindings[2].type, "Int")
        XCTAssertEqual(bindings[3].type, "() -> Void")
        XCTAssertEqual(bindings[4].type, "() -> Void")
        XCTAssertEqual(bindings[5].type, "() -> Void")
    }

    func testIsClosure() throws {
        let variable =
            try VariableDeclSyntax(
                "let closure: () -> Void, closure2: (() -> Void)?, closure3: (() -> Void)!"
            )
        let bindings = Array(variable.bindings)
        XCTAssertEqual(bindings[0].isClosure, true)
        XCTAssertEqual(bindings[1].isClosure, true)
        XCTAssertEqual(bindings[2].isClosure, true)
    }
}

/**

 var rawType: String? {
     typeAnnotation?.type.trimmedDescription
 }

 var type: String? {
     rawType?.replacingOccurrences(of: "!", with: "")
         .replacingOccurrences(of: "?", with: "")
 }

 var name: String? {
     pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmedDescription
 }

 var isOptional: Bool {
     guard let type = typeAnnotation?.type else {
         return false
     }
     return type.is(OptionalTypeSyntax.self) || type
         .is(ImplicitlyUnwrappedOptionalTypeSyntax.self)
 }

 var isClosure: Bool {
     typeAnnotation?.type.as(FunctionTypeSyntax.self) != nil
 }
 */
