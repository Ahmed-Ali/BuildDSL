//
//  DSLResultBuilder.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import Foundation

/**
 This result builder is one of the pieces that helps ensure the safety of the builder closures.
 Without it, the user of the builder closure can excute any code in the closure.
 Using result builder, ensure only the builder APIs are usable within that closure
 */

@resultBuilder
public struct DSLResultBuilder<Builder: BuilderAPI> {
    public static func buildExpression(_ instance: Builder) -> Builder {
        instance
    }

    public static func buildEither(first instance: Builder) -> Builder {
        instance
    }

    public static func buildEither(second instance: Builder) -> Builder {
        instance
    }

    public static func buildBlock(_ builder: Builder) -> Builder {
        builder
    }

    public static func buildFinalResult(_ builder: Builder) -> Builder.Result {
        builder.build()
    }
}
