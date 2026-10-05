//
//  PlatformUnaryViewResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS) || os(macOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

class PlatformUnaryViewResponder: PlatformViewResponder {
    var layoutResponder: DefaultLayoutViewResponder

    init(layoutResponder: DefaultLayoutViewResponder) {
        self.layoutResponder = layoutResponder
        super.init()
        layoutResponder.parent = self
    }

    override func bindEvent(_ event: any EventType) -> ResponderNode? {
        layoutResponder.bindEvent(event)
    }

    override func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        layoutResponder.makeGesture(inputs: inputs)
    }

    override func resetGesture() {
        layoutResponder.resetGesture()
    }

    override var children: [ViewResponder] {
        [layoutResponder]
    }

    @discardableResult
    override func visit(
        applying visitor: (ResponderNode) -> ResponderVisitorResult
    ) -> ResponderVisitorResult {
        let result = visitor(self)
        guard result == .next else {
            return result
        }
        return layoutResponder.visit(applying: visitor)
    }
}
#endif
