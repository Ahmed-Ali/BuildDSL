//
//  main.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

import BuildDSL
import Foundation
#if canImport(OSLog)
import OSLog
let logger = Logger(subsystem: "Examples", category: "BuildDSL")
#else
struct Logger {
    init(subsystem: String, category: String) {}
    func info(_ message: String) {}
    func error(_ message: String) {}
}
let logger = Logger(subsystem: "Examples", category: "BuildDSL")
#endif

/**
 Example usages of the @Builder macro and its suplimentary @Default, @Ignore and @Escaping macros.
 Try to right click and choose the "Expand Macro" option to get better idea of what code being generated and how it works
 */
@Builder
public struct Talk {
    let speaker: String
    let topic: String

    @Ignore
    let maxDuration: Int = 20
}

@Builder
struct Schedule {
    @Default(Date.timeIntervalSinceReferenceDate)
    let startTime: TimeInterval

    /**
     Becaue the Talk struct also
     uses the `@Builder` macro
     you will get two setters
     normal one
     `.keynote(Talk(speaker:topic:))`
     and another nested builder
      ```
     .keynoteBuilder { talk in
     }
     ```
     */
    let keynote: Talk

    // Use can also regular Swift defaults
    var talks: [Talk] = []
}

@Builder
struct Conferance {
    let name: String
    let schedule: Schedule
    let sendInvitation: (String) -> Void
}

// All builders have a optional initializer
let conference = Conferance { $0
    .name("Hot NSTalk")
    .sendInvitation { destination in
        print("Sending invitation to: \(destination)")
    }
    // Any nested struct that also has a builder
    // will have a setter using a result builder
    .scheduleBuilder { schedule in
        schedule
            // you can also use the non-builder setter
            .keynote(Talk(speaker: "Keynote Speakr", topic: "Key note"))
            .talks([
                Talk(speaker: "Speaker 1", topic: "Topic 1"),
                Talk(speaker: "Speaker 2", topic: "Topic 2")
            ])
    }
}

logger.info("\(String(reflecting: conference))")

conference!.sendInvitation("Swift Devs")

// You can also use the `build` for better error report
do {
    let conf = try Conferance.build { $0
        .schedule(
            Schedule { $0
                .keynoteBuilder { $0
                    .speaker("")
                    .topic("")
                }
            }!
        )
    }.get()
    logger.info("\(String(reflecting: conf))")
} catch {
    logger.error("\(String(describing: error))")
}

// you can also offer the builder API through your methods
func create(@Talk.ResultBuilder talk resultBuilder: Talk.Closure) -> Talk.Result {
    Talk.build(resultBuilder)
}

let talk = create { talk in
    p(talk)
}

logger.info("\(String(describing: talk))")

func p(_ v: Talk.Builder) -> Talk.Builder {
    v
}
