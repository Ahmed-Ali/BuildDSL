//
//  MacroUsageTests.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import BuildDSL
import XCTest

@Builder
struct Author: Equatable {
    let name: String
}

@Builder
struct Post: Equatable {
    let id: UUID
    let author: Author
    let content: String
    let mediaUrl: String?
    var comments: [Comment] = []
    var views: Int = 0
}

@Builder
public struct Comment: Equatable {
    let content: String
    var isTopAnswer: Bool = false

    @Default("ThumbsUp")
    let upvoteEmoji: String
}

@Builder
struct ComplexStrcut: Equatable {
    @Ignore
    var post: Post = .init(
        id: UUID(),
        author: Author(name: "Ahmed"),
        content: "Content",
        mediaUrl:
        nil
    )
    @Default(Comment(
        content: "",
        isTopAnswer: false,
        upvoteEmoji: ""
    ))
    let comment: Comment

    @Default(["ThumbsUp", "ThumbsDown"])
    let upvoteEmojis: [String]

    let nonDefault: Int
}

@Builder
struct StructWithExplitClosures {
    let closure: () -> String

    @Default({ "Default from @Default attribute" })
    let withDefualt: () -> String

    var closureWithInitializationValue: () -> String = { "Default through initialization value" }

    let optionalClosure: (() -> String)!
}

@Builder
struct StructWithClosureType {
    typealias ClosureType = () -> String

    @Escaping
    let closure: ClosureType

    @Default({ "Default from @Default attribute" })
    @Escaping
    let withDefualt: ClosureType

    @Escaping
    var closureWithInitializationValue: ClosureType = { "Default through initialization value" }

    @Escaping
    let optionalClosure: ClosureType?
}

final class MacroUsageTests: XCTestCase {
    func testInitWithMissingValues_ShouldReturnNil() throws {
        XCTAssertNil(Comment { $0 })
    }

    func testInitWithAllRequiredValues_ShouldReturnValue() throws {
        XCTAssertEqual(Comment { $0
                .content("content")
        }, Comment(content: "content", upvoteEmoji: "ThumbsUp"))
    }

    func testBuildMethoWithMissingValues_ShouldFail() throws {
        XCTAssertThrowsError(try Comment.build { $0 }.get())
    }

    func testBuildMethoWithNoMissingValues_ShouldFail() throws {
        XCTAssertNotEqual(try Comment.build { $0
                .content("content")
        }.get(), Comment(content: "content", upvoteEmoji: "Name"))
    }

    func testInitOuterAndInnerStructs_ShouldReturnValue() throws {
        let expectedPost = Post(
            id: UUID(),
            author: Author(name: "Ahmed"),
            content: "Content",
            mediaUrl: nil
        )

        XCTAssertEqual(Post { $0
                .id(expectedPost.id)
                .author(Author(name: "Ahmed"))
                .content("Content")
        }, expectedPost)
    }

    func testInitOuterAndBuildInnerStructsWithMissingInnerStructValues_ShouldReturnNil() throws {
        XCTAssertNil(Post { $0
                .id(UUID())
                .authorBuilder { $0 }
                .content("Content")
        })
    }

    func testInitOuterAndBuildInnerStructsWithNoMissingInnerStructValues_ShouldReturnValue() throws {
        let expectedPost = Post(
            id: UUID(),
            author: Author(name: "Ahmed"),
            content: "Content",
            mediaUrl: nil
        )
        XCTAssertEqual(Post { $0
                .id(expectedPost.id)
                .authorBuilder { $0
                    .name("Ahmed")
                }
                .content("Content")
        }, expectedPost)
    }

    func testBuildOuterAndBuildInnerStructsWithMissingInnerStructValues_ShouldFail() throws {
        XCTAssertThrowsError(try Post.build { $0
                .id(UUID())
                .authorBuilder { $0 }
                .content("Content")
        }.get())
    }

    func testBuildOuterAndBuildInnerStructsWithNoMissingInnerStructValues_ShouldReturnValue(
    ) throws {
        let expectedPost = Post(
            id: UUID(),
            author: Author(name: "Ahmed"),
            content: "Content",
            mediaUrl: nil
        )
        XCTAssertEqual(try Post.build { $0
                .id(expectedPost.id)
                .authorBuilder { $0
                    .name("Ahmed")
                }
                .content("Content")
        }.get(), expectedPost)
    }

    func testVarWithDefaultValueUnchanged_ShouldRetainDefaultValue(
    ) throws {
        XCTAssertEqual(Comment { $0
                .content("Content")
        }?.isTopAnswer, false)
    }

    func testVarWithDefaultValueChanged_ShouldRetainChangedValue(
    ) throws {
        XCTAssertEqual(Comment { $0
                .content("Content")
                .isTopAnswer(true)
        }?.isTopAnswer, true)
    }

    func testComplexType() throws {
        let complex = ComplexStrcut { $0
            .nonDefault(10)
        }!
        XCTAssertEqual(complex.post.author.name, "Ahmed")
        XCTAssertEqual(complex.nonDefault, 10)
    }

    func testExplicitClosures() throws {
        let instance = StructWithExplitClosures { $0
            .closure {
                "closure"
            }
            .optionalClosure {
                "optionalClosure"
            }
        }

        XCTAssertEqual(instance?.closure(), "closure")
        XCTAssertEqual(instance?.optionalClosure?(), "optionalClosure")
        XCTAssertEqual(instance?.withDefualt(), "Default from @Default attribute")
        XCTAssertEqual(
            instance?.closureWithInitializationValue(),
            "Default through initialization value"
        )
    }

    func testEscaping() throws {
        let instance = StructWithClosureType { $0
            .closure {
                "closure"
            }
            .optionalClosure {
                "optionalClosure"
            }
        }

        XCTAssertEqual(instance?.closure(), "closure")
        XCTAssertEqual(instance?.optionalClosure?(), "optionalClosure")
        XCTAssertEqual(instance?.withDefualt(), "Default from @Default attribute")
        XCTAssertEqual(
            instance?.closureWithInitializationValue(),
            "Default through initialization value"
        )
    }

    func testUseBuildersInUserAPIs() throws {
        func createComment(@Comment.ResultBuilder with resultBuilder: Comment.Closure) -> Comment? {
            try? Comment.build(resultBuilder).get()
        }

        let comment = createComment { $0
            .content("Content")
            .isTopAnswer(true)
        }

        XCTAssertEqual(comment?.content, "Content")
        XCTAssertEqual(comment?.isTopAnswer, true)
        XCTAssertEqual(comment?.upvoteEmoji, "ThumbsUp")
    }
}
