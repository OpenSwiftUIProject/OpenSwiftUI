//
//  ViewGraphDelegate.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package protocol ViewGraphDelegate: GraphDelegate {
    func `as`<T>(_ type: T.Type) -> T?
    func updateViewGraph<T>(body: (ViewGraph) -> T) -> T
    func requestUpdate(after: Double) -> ()
}

@_spi(ForOpenSwiftUIOnly)
extension ViewGraphDelegate {
    package func `as`<T>(_ type: T.Type) -> T? { nil }

    public func updateGraph<T>(body: (GraphHost) -> T) -> T {
        updateViewGraph { body($0) }
    }
}
