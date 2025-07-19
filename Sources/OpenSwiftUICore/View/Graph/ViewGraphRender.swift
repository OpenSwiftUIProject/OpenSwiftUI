//
//  ViewGraphRender.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

package protocol ViewGraphRenderDelegate {
    var renderingRootView: AnyObject { get }
    func updateRenderContext(_ context: inout ViewGraphRenderContext)
    func withMainThreadRender(wasAsync: Bool, _ body: () -> Time) -> Time
}

package struct ViewGraphRenderContext {
    package var contentsScale: CGFloat
    package var opaqueBackground: Bool
}

package protocol ViewGraphRenderHost {
    func renderDisplayList(
        _ displayList: DisplayList,
        asynchronous: Bool,
        time: Time,
        nextTime: Time,
        targetTimestamp: Time?,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version
    ) -> Time
}

package protocol ViewGraphRenderObserver {
    func didRender()
}
