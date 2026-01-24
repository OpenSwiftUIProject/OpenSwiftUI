//
//  CommandOperation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: D0FEA817F8A31FD09583FBBAADEB778B (SwiftUI)

struct CommandAccumulator {
    struct Result {
        var viewContent: AnyView
    }

    var result: CommandAccumulator.Result
    var updatedPlacements: Set<CommandGroupPlacementBox>

    private mutating func visit<V: View>(
        _ view: V,
        operation: CommandOperation
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - CommandOperation

struct CommandOperation {
    enum Mutation {
        case append
        case prepend
        case replace
        case topLevel
        case initialize
    }

    var mutation: CommandOperation.Mutation
    var placement: CommandGroupPlacement
    var resolver: ((CommandOperation, inout _ResolvedCommands) -> ())?

    init<V: View>(
        mutation: CommandOperation.Mutation,
        placement: CommandGroupPlacement,
        content: V
    ) {
        self.mutation = mutation
        self.placement = placement
        self.resolver = { operation, resolved in
            _openSwiftUIUnimplementedFailure()
        }
    }
}
