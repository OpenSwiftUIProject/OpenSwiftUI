//
//  FocusSection.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 96B0FDB8101CA4B64D25EA023C3F4AF2 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - FocusSectionResponder

class FocusSectionResponder: DefaultLayoutViewResponder, BaseFocusResponder {
    var transform: ViewTransform = .init()
    var size: CGSize = .zero
    var isEnabled: Bool = false
    var effectiveLayoutDirection: LayoutDirection?

    #if os(iOS) || os(visionOS)
    var speedBumpEdges: Edge.Set = []
    fileprivate var _uikitFocusItem: UIKitFocusSectionResponderItem?

    var platformItem: PlatformFocusItem? { hostedItem }

    var uiSpeedBumpEdges: UIRectEdge {
        UIRectEdge(speedBumpEdges, layoutDirection: effectiveLayoutDirection ?? .leftToRight)
    }

    var viewItem: FocusItem.ViewItem? { _openSwiftUIUnreachableCode() }
    var frame: CGRect? { _openSwiftUIUnreachableCode() }
    var focusGroupID: FocusGroupIdentifier? { _openSwiftUIUnreachableCode() }
    #elseif os(macOS)
    var platformItem: PlatformFocusItem? { _openSwiftUIUnreachableCode() }
    var viewItem: FocusItem.ViewItem? { nil }

    var frame: CGRect? {
        var frame = CGRect(origin: .zero, size: size)
        frame.convert(to: .id(hostingViewCoordinateSpace), transform: transform)
        return frame
    }

    var firstKeyViewInSubtree: NSView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }

    var lastKeyViewInSubtree: NSView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }
    #else
    var platformItem: PlatformFocusItem? { _openSwiftUIUnimplementedFailure() }
    var viewItem: FocusItem.ViewItem? { _openSwiftUIUnimplementedFailure() }
    var frame: CGRect? { _openSwiftUIUnimplementedFailure() }
    #endif
}

#if os(iOS) || os(visionOS)
extension FocusSectionResponder: AnyUIKitHostedFocusItemResponder {
    var hostedItem: (any AnyUIKitHostedFocusItem)? {
        if _uikitFocusItem == nil {
            _uikitFocusItem = UIKitFocusSectionResponderItem(self, speedBumpEdges: uiSpeedBumpEdges)
        }
        return _uikitFocusItem
    }
}

// MARK: - UIKitFocusSectionResponderItem

private class UIKitFocusSectionResponderItem: UIKitContainerFocusResponderItem<FocusSectionResponder> {
    @objc var _focusSpeedBumpEdges: UIRectEdge

    init(_ base: FocusSectionResponder, speedBumpEdges: UIRectEdge) {
        _focusSpeedBumpEdges = speedBumpEdges
        super.init(base)
    }

    override func _focusGuideBehavior(forFocusMovement movement: AnyObject?) -> UInt { 1 }
}
#endif

// MARK: - _FocusSectionModifier

private struct _FocusSectionModifier: UnaryViewModifier, PrimitiveViewModifier {
    var speedBumpEdges: Edge.Set

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresViewResponders {
            let responder = FocusSectionResponder(inputs: inputs)
            let filter = Attribute(FocusSectionResponderFilter(
                transform: inputs.transform,
                position: inputs.animatedPosition(),
                size: inputs.animatedSize(),
                isEnabled: inputs.base.isEnabled,
                layoutDirection: inputs.base.layoutDirection,
                speedBumpEdges: modifier.value[offset: { .of(&$0.speedBumpEdges) }],
                children: outputs.viewResponders(),
                responder: responder
            ))
            #if os(iOS) || os(visionOS)
            let lifecycle = Attribute(UIKitHostedFocusItemLifecycle(inputs: inputs, responder: filter))
            lifecycle.flags = [.removable, .transactional]
            #endif
            outputs.preferences.viewResponders = filter
        }
        return outputs
    }
}

// MARK: - FocusSectionResponderFilter

private struct FocusSectionResponderFilter: StatefulRule {
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var isEnabled: Bool
    @Attribute var layoutDirection: LayoutDirection
    @Attribute var speedBumpEdges: Edge.Set
    @Attribute var children: [ViewResponder]
    let responder: FocusSectionResponder

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        let (position, positionChanged) = $position.changedValue()
        let (transform, transformChanged) = $transform.changedValue()
        let (size, sizeChanged) = $size.changedValue()
        let (isEnabled, isEnabledChanged) = $isEnabled.changedValue()
        let (layoutDirection, layoutDirectionChanged) = $layoutDirection.changedValue()
        let (speedBumpEdges, speedBumpEdgesChanged) = $speedBumpEdges.changedValue()
        responder.updateChildren($children.changedValue())
        if positionChanged || transformChanged || sizeChanged || isEnabledChanged
            || layoutDirectionChanged || speedBumpEdgesChanged || !hasValue {
            var transform = transform
            transform.appendPosition(position)
            responder.transform = transform
            responder.size = size.value
            responder.isEnabled = isEnabled
            responder.effectiveLayoutDirection = layoutDirection
            #if os(iOS) || os(visionOS)
            responder.speedBumpEdges = speedBumpEdges
            if let item = responder._uikitFocusItem {
                item._focusSpeedBumpEdges = responder.uiSpeedBumpEdges
            }
            #endif
        }
        if !hasValue {
            value = [responder]
        }
    }
}
