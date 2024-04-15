//
//  VariableDeclExtensionTests.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 15/04/2024.
//

import SwiftDiagnostics
import SwiftSyntax
import XCTest
@testable import BuildDSLMacros

final class VariableDeclExtensionTests: XCTestCase {
    func testIsConst() throws {
        XCTAssertFalse(try VariableDeclSyntax("var myVar: Int").isConst)
        XCTAssertTrue(try VariableDeclSyntax("let myVar: Int").isConst)
    }

    func testIsStatic() throws {
        XCTAssertTrue(try VariableDeclSyntax("static var myVar: Int").isStatic)
        XCTAssertTrue(try VariableDeclSyntax("static let myVar: Int").isStatic)

        XCTAssertTrue(try VariableDeclSyntax("private static var myVar: Int").isStatic)
        XCTAssertTrue(try VariableDeclSyntax("private static let myVar: Int").isStatic)

        XCTAssertFalse(try VariableDeclSyntax("private var myVar: Int").isStatic)
        XCTAssertFalse(try VariableDeclSyntax("private let myVar: Int").isStatic)
        XCTAssertFalse(try VariableDeclSyntax("internal let myVar: Int").isStatic)
    }

    func testDefaultValue() throws {
        XCTAssertNil(try VariableDeclSyntax("var myVar: Int").defaultValue)
        XCTAssertNil(try VariableDeclSyntax("var myVar: (Int) -> Void").defaultValue)

        XCTAssertEqual(
            try VariableDeclSyntax("@Default(10) var myVar: Int").defaultValue,
            Optional("10")
        )
        XCTAssertEqual(
            try VariableDeclSyntax("@Default({}) var myVar: (Int) -> Void").defaultValue,
            Optional("{}")
        )
    }

    func testIgnore() throws {
        XCTAssertFalse(try VariableDeclSyntax("var myVar: Int").ignore)
        XCTAssertTrue(try VariableDeclSyntax("@Ignore var myVar: Int").ignore)
    }

    func testEscaping() throws {
        XCTAssertFalse(try VariableDeclSyntax("var myVar: Int").escaping)
        XCTAssertTrue(try VariableDeclSyntax("@Escaping var myVar: MyClosureTypeAlias").escaping)
        XCTAssertTrue(
            try VariableDeclSyntax("@Escaping @Default({}) var myVar: MyClosureTypeAlias ")
                .escaping
        )
    }
}

/**
 var buildableBindngs: PatternBindingListSyntax {
     isConst ? bindings.filter { $0.storedProperty && $0.initialValue == nil }
         : bindings.filter(\.storedProperty)
 }

 var defaultValue: String? {
     let attr = attributes.compactMap {
         switch $0 {
         case let .attribute(attr):
             return attr.attributeName.trimmedDescription == "Default" ? attr : nil
         case .ifConfigDecl:
             return nil
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
 */
