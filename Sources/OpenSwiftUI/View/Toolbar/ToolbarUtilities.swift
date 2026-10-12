//
//  ToolbarUtilities.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 0E31079E853BF37F2F0477B683D77398 (SwiftUI)

#if os(macOS)
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - View + Dynamic Toolbar Style Context

extension View {
    func dynamicToolbarStyleContext() -> some View {
        modifier(
            StaticIf(in: .toolbar) {
                ToolbarStyleContextModifier()
            } else: {
                EmptyModifier()
            }
        )
    }
}

// MARK: - ToolbarStyleContextModifier

struct ToolbarStyleContextModifier: UnaryViewModifier, PrimitiveViewModifier {
    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard let isInOverflow = inputs[ToolbarIsInOverflowInput.self].attribute else {
            return body(_Graph(), inputs)
        }
        var newInputs = inputs
        newInputs.base.pushStyleContext(ToolbarStyleContext())
        newInputs[ToolbarIsInOverflowInput.self] = .init()
        let content = Attribute(MakeContent(isInOverflow: isInOverflow))
        return DynamicContextModifier.makeDebuggableView(
            modifier: _GraphValue(content),
            inputs: newInputs,
            body: body
        )
    }

    private struct MakeContent: Rule {
        @Attribute var isInOverflow: Bool

        var value: DynamicContextModifier {
            DynamicContextModifier(isInOverflow: isInOverflow)
        }
    }

    private struct DynamicContextModifier: ViewModifier {
        var isInOverflow: Bool

        func body(content: Content) -> some View {
            if isInOverflow {
                content.styleContext(.menu)
            } else {
                content.styleContext(.toolbar)
            }
        }
    }
}

// MARK: - ToolbarIsInOverflowInput

struct ToolbarIsInOverflowInput: ViewInput {
    static let defaultValue: OptionalAttribute<Bool> = .init()
}
#endif
