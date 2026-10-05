//
//  FocusEffectView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B9E8471D77A01696E0731B43A95A9346 (SwiftUI)

#if os(macOS)
import AppKit
import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - _FocusRingView

private class _FocusRingView: NSView, FocusRingDelegate {
    var focused: Bool = false
    weak var responder: ViewResponder?
    final lazy var helper = FocusRingHelper(responder: responder, focusRingView: self)

    var canShowFocusRing: Bool { true }

    init(responder: ViewResponder) {
        self.responder = responder
        super.init(frame: .zero)
        setFlipped(true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var focusRingMaskBounds: NSRect {
        helper.focusRingMaskBounds
    }

    override func drawFocusRingMask() {
        helper.drawFocusRingMask()
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}

extension _FocusRingView: CustomRecursiveStringConvertible {
    var descriptionAttributes: [(name: String, value: String)] {
        var attributes: [(name: String, value: String)] = []
        if let responder = responder as? any FocusResponder,
           responder.delegatesFocusEffect {
            attributes.append((name: "containerDefinesFocusEffect", value: "true"))
        }
        return attributes
    }

    var defaultDescriptionAttributes: Set<DefaultDescriptionAttribute> {
        _TestApp.isIntending(to: .ignoreGeometry) ? [] : [.rect]
    }
}

// MARK: - UpdateFocusEffectView

struct UpdateFocusEffectView: StatefulRule {
    @Attribute var isEnabled: Bool
    let responder: ViewResponder

    typealias Value = FocusEffectView

    mutating func updateValue() {
        let (isEnabled, changed) = $isEnabled.changedValue()
        if changed || !hasValue {
            value = .init(responder: responder, shouldDisplay: isEnabled)
        }
    }
}

// MARK: - FocusEffectView

struct FocusEffectView: RendererLeafView, PlatformViewFactory {
    let responder: ViewResponder
    var shouldDisplay: Bool

    static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        var newInputs = inputs
        newInputs.preferences.requiresViewResponders = false
        return makeLeafView(view: view, inputs: newInputs)
    }

    func content() -> DisplayList.Content.Value {
        shouldDisplay ? .platformView(self) : .color(.clear)
    }

    func makePlatformView() -> AnyObject? {
        let view = _FocusRingView(responder: responder)
        (responder as? any FocusResponder)?.setFocusRingView(view)
        return view
    }

    func updatePlatformView(_ view: inout AnyObject) {
        _openSwiftUIEmptyStub()
    }

    func renderPlatformView(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        _openSwiftUIEmptyStub()
    }
}
#endif
