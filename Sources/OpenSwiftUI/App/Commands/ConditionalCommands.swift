//
//  ConditionalCommands.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7823B10F4F8D6B5D9D46ED7A4A8B7B47 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - CommandsBuilder + _ConditionalContent

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension CommandsBuilder {
    @_alwaysEmitIntoClient
    public static func buildIf<C>(_ content: C?) -> C? where C: Commands {
        content
    }

    @_alwaysEmitIntoClient
    public static func buildEither<T, F>(first: T) -> _ConditionalContent<T, F> where T: Commands, F: Commands {
        _ConditionalContent<T, F>(storage: .trueContent(first))
    }

    @_alwaysEmitIntoClient
    public static func buildEither<T, F>(second: F) -> _ConditionalContent<T, F> where T: Commands, F: Commands {
        _ConditionalContent<T, F>(storage: .falseContent(second))
    }

    @available(OpenSwiftUI_v5_5, *)
    @_alwaysEmitIntoClient
    public static func buildLimitedAvailability(_ content: any Commands) -> some Commands {
        if #unavailable(iOS 17.5, macOS 14.5) {
            return EmptyCommands()
        } else {
            return LimitedAvailabilityCommandContent(erasing: content)
        }
    }

    @available(iOS, deprecated: 16.0, obsoleted: 17.5, message: "this code may crash on earlier versions of the OS; specify '#available(iOS 17.5, *)' or newer instead")
    @available(macOS, deprecated: 13.0, obsoleted: 14.5, message: "this code may crash on earlier versions of the OS; specify '#available(macOS 14.5, *)' or newer instead")
    @_alwaysEmitIntoClient
    public static func buildLimitedAvailability<C>(_ content: C) -> some Commands where C : Commands {
        content
    }
}


// MARK: - _ConditionalContent + Commands

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension _ConditionalContent: PrimitiveCommands, Commands where TrueContent: Commands, FalseContent: Commands {

    nonisolated public static func _makeCommands(
        content: _GraphValue<Self>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        var outputs = _CommandsOutputs(preferences: inputs.preferences.makeIndirectOutputs())
        let provider = CommandsProvider(
            inputs: inputs,
            outputs: outputs
        )
        let container = Attribute(
            Container(
                content: content.value,
                provider: provider
            )
        )
        outputs.preferences.setIndirectDependency(container.identifier)
        return outputs
    }

    @usableFromInline
    init(storage: Storage) {
        self.init(__storage: storage)
    }

    private struct CommandsProvider: ConditionalContentProvider {
        var inputs: _CommandsInputs
        var outputs: _CommandsOutputs

        init(inputs: _CommandsInputs, outputs: _CommandsOutputs) {
            self.inputs = inputs
            self.outputs = outputs
        }

        func detachOutputs() {
            outputs.preferences.detachIndirectOutputs()
        }

        func attachOutputs(to child: _CommandsOutputs) {
            outputs.preferences.attachIndirectOutputs(to: child.preferences)
        }

        func makeChildInputs() -> _CommandsInputs {
            var inputs = inputs
            inputs.copyCaches()
            return inputs
        }

        func makeTrueOutputs(child: Attribute<TrueContent>, inputs: _CommandsInputs) -> _CommandsOutputs {
            TrueContent._makeCommands(content: .init(child), inputs: inputs)
        }

        func makeFalseOutputs(child: Attribute<FalseContent>, inputs: _CommandsInputs) -> _CommandsOutputs {
            FalseContent._makeCommands(content: .init(child), inputs: inputs)
        }
    }
}

// MARK: - Optional + Commands

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Optional: PrimitiveCommands, Commands where Wrapped: Commands {

    nonisolated public static func _makeCommands(
        content: _GraphValue<Optional<Wrapped>>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        _ConditionalContent<Wrapped, EmptyCommands>._makeCommands(
            content: .init(Child(content: content.value)),
            inputs: inputs
        )
    }

    private struct Child: Rule, AsyncAttribute {
        @Attribute var content: Wrapped?

        var value: _ConditionalContent<Wrapped, EmptyCommands> {
            _ConditionalContent(
                storage: content.map {
                    _ConditionalContent.Storage.trueContent($0)
                } ?? .falseContent(EmptyCommands())
            )
        }
    }
}
