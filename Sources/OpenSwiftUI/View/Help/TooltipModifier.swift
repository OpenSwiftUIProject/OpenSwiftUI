//
//  TooltipModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 260978DE3FF5445B342BD9F05199EF00 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - TooltipResponder

class TooltipResponder: DefaultLayoutViewResponder {
    fileprivate var _text: OptionalAttribute<String> = .init()
    var position: CGPoint = .zero
    var size: CGSize = .invalidValue
    var transform: ViewTransform = .init()

    var text: String? {
        Update.dispatchImmediately(reason: nil) {
            Graph.withoutUpdate {
                guard let text = _text.wrappedValue, !text.isEmpty else {
                    return nil
                }
                return text
            }
        }
    }

    override func extendPrintTree(string: inout String) {
        string += "tooltip (\(text ?? "nil"))"
    }
}

// MARK: - HasTooltipKey

struct HasTooltipKey: HostPreferenceKey {
    static var defaultValue: Bool { false }

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - TooltipModifier

struct TooltipModifier: PrimitiveViewModifier, MultiViewModifier {
    var text: Text

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        let text = Attribute(ResolveText(modifier: modifier.value, environment: inputs.environment))
        if inputs.platformItemListFlags.contains(.layout) {
            outputs.transformPlatformItemList(
                inputs: inputs,
                transform: Attribute(TransformPlatformItems(text: text))
            )
        }
        guard inputs.preferences.requiresDisplayList else {
            return outputs
        }
        if Semantics.ResponderBasedTooltips.isEnabled {
            if inputs.preferences.requiresViewResponders {
                outputs.preferences.makePreferenceWriter(
                    inputs: inputs.preferences,
                    key: HasTooltipKey.self,
                    value: inputs.intern(true, id: .trueValue)
                )
                outputs.preferences.viewResponders = Attribute(TooltipResponderUpdater(
                    responder: TooltipResponder(inputs: inputs),
                    children: outputs.viewResponders(),
                    text: text,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedSize(),
                    transform: inputs.transform
                ))
            }
        }
        // TODO: PointerHost and PointerRegionUpdater for legacy macOS tooltip semantics.
        _openSwiftUIUnimplementedWarning()
        return outputs
    }

    private struct TransformPlatformItems: Rule {
        @Attribute var text: String

        var value: (inout PlatformItemList) -> Void {
            { list in
                for index in list.items.indices {
                    list.items[index].tooltip = text
                }
            }
        }
    }

    private struct TooltipResponderUpdater: StatefulRule {
        let responder: TooltipResponder
        @Attribute var children: [ViewResponder]
        @Attribute var text: String
        @Attribute var position: CGPoint
        @Attribute var size: ViewSize
        @Attribute var transform: ViewTransform

        typealias Value = [ViewResponder]

        mutating func updateValue() {
            responder._text = OptionalAttribute($text)
            let (position, positionChanged) = $position.changedValue()
            let (size, sizeChanged) = $size.changedValue()
            let (transform, transformChanged) = $transform.changedValue()
            if positionChanged || sizeChanged || transformChanged || !hasValue {
                responder.position = position
                responder.size = size.value
                responder.transform = transform
            }
            responder.updateChildren($children.changedValue())
            if !hasValue {
                value = [responder]
            }
        }
    }

    private struct ResolveText: Rule {
        @Attribute var modifier: TooltipModifier
        @Attribute var environment: EnvironmentValues

        var value: String {
            modifier.text.resolveString(in: environment)
        }
    }
}
