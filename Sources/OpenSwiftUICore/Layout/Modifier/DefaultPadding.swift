//
//  DefaultPadding.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 47C1BD8C61550BB60F4F3D12F752D53D (SwiftUICore)

import Foundation
import OpenGraphShims

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    @_spi(_)
    public var defaultPadding: EdgeInsets {
        get { self[DefaultPaddingKey.self] }
        set { self[DefaultPaddingKey.self] = newValue }
    }
}

// MARK: - DefaultPaddingKey

private struct DefaultPaddingKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = .init(_all: 16.0)
}

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// For use by children in containers to disable the automatic padding that
    /// those containers apply.
    public func _ignoresAutomaticPadding(_ ignoresPadding: Bool) -> some View {
        modifier(IgnoresAutomaticPaddingLayout(ignoresPadding: ignoresPadding))
    }

    /// Applies explicit padding to a view that allows being disabled by that
    /// view using `_ignoresAutomaticPadding`.
    public func _automaticPadding(_ edgeInsets: EdgeInsets? = nil) -> some View {
        modifier(AutomaticPaddingViewModifier(padding: edgeInsets))
    }
}

// MARK: - AutomaticPaddingViewModifier

private struct AutomaticPaddingViewModifier: MultiViewModifier, PrimitiveViewModifier {
    var padding: EdgeInsets?

    nonisolated static func _makeView(
        modifier: _GraphValue<AutomaticPaddingViewModifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.requestsLayoutComputer || inputs.needsGeometry else {
            return body(_Graph(), inputs)
        }
        let layout = Attribute(PaddingLayout(
            modifier: modifier.value,
            environment: inputs.environment,
            childLayoutComputer: .init()
        ))
        return PaddingLayout.Value.makeDebuggableView(
            modifier: _GraphValue(layout),
            inputs: inputs,
            body: body
        )
    }

    struct PaddingLayout: Rule, AsyncAttribute {
        @Attribute var modifier: AutomaticPaddingViewModifier
        @Attribute var environment: EnvironmentValues
        @OptionalAttribute var childLayoutComputer: LayoutComputer?

        typealias Value = ModifiedContent<WrappedLayout, _SafeAreaInsetsModifier>

        var value: Value {
            let ignoresAutomaticPadding = childLayoutComputer?.ignoresAutomaticPadding() ?? false
            let padding: EdgeInsets
            if ignoresAutomaticPadding {
                padding = .zero
            } else {
                padding = modifier.padding ?? environment.defaultPadding
            }
            return WrappedLayout(base: .init(insets: padding))
                .concat(_SafeAreaInsetsModifier(insets: padding))
        }

        struct WrappedLayout: UnaryLayout {
            var base: _PaddingLayout

            func placement(
                of child: LayoutProxy,
                in context: PlacementContextType
            ) -> _Placement {
                base.placement(of: child, in: context)
            }

            func sizeThatFits(
                in proposedSize: _ProposedSize,
                context: SizeAndSpacingContext,
                child: LayoutProxy
            ) -> CGSize {
                base.sizeThatFits(in: proposedSize, context: context, child: child)
            }
        }
    }
}

// MARK: - IgnoresAutomaticPaddingLayout

private struct IgnoresAutomaticPaddingLayout: UnaryLayout {
    var ignoresPadding: Bool

    func placement(of child: LayoutProxy, in context: PlacementContext) -> _Placement {
        _Placement(
            proposedSize: context.proposedSize,
            aligning: .center,
            in: context.size
        )
    }

    func sizeThatFits(in proposedSize: _ProposedSize, context: SizeAndSpacingContext, child: LayoutProxy) -> CGSize {
        child.size(in: proposedSize)
    }

    func layoutPriority(child: LayoutProxy) -> Double {
        child.layoutPriority
    }

    func ignoresAutomaticPadding(child: LayoutProxy) -> Bool {
        ignoresPadding
    }
}
