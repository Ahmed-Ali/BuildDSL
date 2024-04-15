//
//  AccessLevelTests.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not
// available when cross-compiling. Cross-compiled tests may still make use of
// the macro itself in end-to-end tests.

#if canImport(BuildDSLMacros)
import BuildDSLMacros

private let testMacros: [String: Macro.Type] = [
    "Builder": BuilderMacro.self
]

#endif

/**
 We want to make sure that all the APIs access modifier is called out explicitly only when it is public or package.
 If we didn't, it will default to the default access level, which is more restrictive than `public` or `package`
 */
final class AccessLevelTests: XCTestCase {
    func expansion(accessLevel: String, explicit: Bool) -> String {
        let outputAccessLevel = explicit ? "\(accessLevel) " : ""
        return
            """
            \(accessLevel) struct Config {
               let strProperty: String
            }

            extension Config: BuildableAPI {
                \(outputAccessLevel)typealias ResultBuilder = DSLResultBuilder<Self.Builder>

                \(outputAccessLevel)final class Builder: BuilderAPI {
                    \(outputAccessLevel)typealias Buildable = Config

                    private var strProperty: String?
                    \(outputAccessLevel)init() {
                    }
                    @discardableResult
                    \(outputAccessLevel)func strProperty(_ value: String) -> Config.Builder {
                        self.strProperty = value
                        return self
                    }
                    \(outputAccessLevel)func build() -> Config.Result {
                        guard let strProperty else {
                            return .failure(BuilderError.missingValueFor("strProperty", container: "Config"))
                        }
                        return .success(Config(strProperty: strProperty))
                    }
                }

                \(outputAccessLevel)init?(@ResultBuilder _ resBuilder: Closure) {
                    guard let this = try? resBuilder(Builder()).get() else {
                        return nil
                    }
                    self.init(strProperty: this.strProperty)
                }
            }
            """
    }

    func testInheritedAccessLevel() throws {
        #if canImport(BuildDSLMacros)

        for accessLevel in ["internal", "private", "fileprivate"] {
            assertMacroExpansion(
                """
                @Builder
                \(accessLevel) struct Config {
                   let strProperty: String
                }
                """,
                expandedSource: expansion(accessLevel: accessLevel, explicit: false),
                macros: testMacros
            )
        }

        #else
        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )
        #endif
    }

    func testExplicitAccessLevel() throws {
        #if canImport(BuildDSLMacros)

        for accessLevel in ["public", "package"] {
            assertMacroExpansion(
                """
                @Builder
                \(accessLevel) struct Config {
                   let strProperty: String
                }
                """,
                expandedSource: expansion(accessLevel: accessLevel, explicit: true),
                macros: testMacros
            )
        }

        #else
        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )
        #endif
    }
}
