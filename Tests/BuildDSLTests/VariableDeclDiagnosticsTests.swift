//
//  VariableDeclDiagnosticsTests.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftDiagnostics
import SwiftSyntax
import XCTest
@testable import BuildDSLMacros

final class VariableDeclDiagnosticsTests: XCTestCase {
    func testValidProperties() throws {
        XCTAssertFalse(try VariableDeclSyntax("let p: String").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("var p: String = \"\"").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("@Default(10) let p: Int").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("private let p: Int").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("let p: () -> Int").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("private let p: () -> Int").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("var p: () -> Int").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("private var p: Int = 90").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("private let p: Int?").validateAsVar().hasError)
        XCTAssertFalse(try VariableDeclSyntax("let p: Int = 10").validateAsVar().hasError)
    }

    func testRejectingStaticWithBuilderAttributes() throws {
        XCTAssertTrue(
            try VariableDeclSyntax("@Ignore static var p: String").validateAsVar().hasError
        )

        XCTAssertTrue(
            try VariableDeclSyntax("@Escaping static var p: String").validateAsVar().hasError
        )

        XCTAssertTrue(
            try VariableDeclSyntax("@Default static var p: String").validateAsVar().hasError
        )
    }

    func testRejectingVarWithDefaultAndInitialValues() throws {
        XCTAssertTrue(
            try VariableDeclSyntax("@Default(10) var p: int = 10").validateAsVar().hasError
        )
    }

    func testRejectingVarWithNoName() throws {
        XCTAssertTrue(
            try VariableDeclSyntax("var _: int = 10").validateAsVar().hasError
        )
    }

    func testRejectingVarWithNoType() throws {
        XCTAssertTrue(
            try VariableDeclSyntax("var m = 10").validateAsVar().hasError
        )
    }

    func testRejectingInvalidDecl() throws {
        XCTAssertTrue(
            try VariableDeclSyntax("var m: Str = ``").validateAsVar().hasError
        )
    }
}
