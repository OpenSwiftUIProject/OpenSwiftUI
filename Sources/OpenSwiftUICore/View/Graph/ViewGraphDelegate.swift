//
//  ViewGraphDelegate.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package protocol ViewGraphDelegate: GraphDelegate {
    func `as`<T>(_ type: T.Type) -> T?
    func modifyViewInputs(_ inputs: inout _ViewInputs)
    func updateViewGraph<T>(body: (ViewGraph) -> T) -> T
    func requestUpdate(after: Double) -> ()
    func rootTransform() -> ViewTransform
}

@_spi(ForOpenSwiftUIOnly)
extension ViewGraphDelegate {
    package func `as`<T>(_ type: T.Type) -> T? { nil }
    package func modifyViewInputs(_ inputs: inout _ViewInputs) {}
    
    public func updateGraph<T>(body: (GraphHost) -> T) -> T {
        updateViewGraph { body($0) }
    }
    
    package func rootTransform() -> ViewTransform {
        ViewTransform()
    }
}
