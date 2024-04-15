//
//  Protocols.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import Foundation

public protocol BuildableAPI<Builder> {
    associatedtype Builder: BuilderAPI where Builder.Buildable == Self

    typealias ResultBuilder = DSLResultBuilder<Builder>
    typealias Result = Swift.Result<Self, BuilderError>
    typealias Closure = (Builder) -> Self.Builder.Result
}

public protocol BuilderAPI<Buildable> {
    associatedtype Buildable: BuildableAPI
    typealias Result = Buildable.Result

    init()

    func build() -> Result
}

extension BuildableAPI {
    public static func build(
        @ResultBuilder _ resBuilder: Self
            .Closure
    ) -> Self.Result {
        resBuilder(Self.Builder())
    }
}
