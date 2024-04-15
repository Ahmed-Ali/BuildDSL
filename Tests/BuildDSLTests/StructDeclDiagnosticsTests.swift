//
//  StructDeclDiagnosticsTests.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftDiagnostics
import SwiftSyntax
import XCTest
@testable import BuildDSLMacros

final class StructDeclDiagnosticsTests: XCTestCase {
    func testValidStruct() throws {
        XCTAssertNotNil(try? Struct(StructDeclSyntax("struct MyStruct {}"), buildableTypes: Set()))
        XCTAssertNotNil(try? Struct(
            StructDeclSyntax("public struct MyStruct {}"),
            buildableTypes: Set()
        ))
        XCTAssertNotNil(try? Struct(
            StructDeclSyntax("package struct MyStruct {}"),
            buildableTypes: Set()
        ))
        XCTAssertNotNil(try? Struct(
            StructDeclSyntax("package struct MyStruct: Codable {}"),
            buildableTypes: Set()
        ))
        XCTAssertNotNil(try? Struct(StructDeclSyntax("""
                                         @resultBuilder struct MyStruct {
                                            let m: Int
                                            func getM() -> Int { m }
                                         }
        """), buildableTypes: Set()))

        XCTAssertNotNil(try Struct(
            StructDeclSyntax("public struct MyStruct {let v : Int = 1}"),
            buildableTypes: Set()
        ))
    }

    func testNonStructTypes_ShouldThrow() throws {
        XCTAssertThrowsError(try Struct(
            StructDeclSyntax("actor MyStruct {}"),
            buildableTypes: Set()
        ))
        XCTAssertThrowsError(try Struct(
            StructDeclSyntax("public class MyStruct {}"),
            buildableTypes: Set()
        ))
        XCTAssertThrowsError(try Struct(
            StructDeclSyntax("package enum MyStruct {}"),
            buildableTypes: Set()
        ))
        XCTAssertThrowsError(try Struct(
            StructDeclSyntax("package protocol MyStruct: Codable {}"),
            buildableTypes: Set()
        ))
        XCTAssertThrowsError(try Struct(StructDeclSyntax("""
                                         struct MyStruct: OptionSet {
                                            let m: Int
                                         }
        """), buildableTypes: Set()))
    }

    func testInvalidStructContent_ShouldThrow() throws {
        XCTAssertThrowsError(try Struct(
            StructDeclSyntax("struct MyStruct { @Default(1) var v : Int = 1}"),
            buildableTypes: Set()
        ))

        XCTAssertThrowsError(try Struct(
            StructDeclSyntax("package struct MyStruct {let v = 1}"),
            buildableTypes: Set()
        ))
        XCTAssertThrowsError(try Struct(
            StructDeclSyntax("package struct MyStruct: Codable { @Default(2) static var m: Int}"),
            buildableTypes: Set()
        ))
        XCTAssertThrowsError(try Struct(StructDeclSyntax("""
                                         struct MyStruct {
                                            @Default(2)
                                            let m: Int, k: String
                                         }
        """), buildableTypes: Set()))
    }
}
