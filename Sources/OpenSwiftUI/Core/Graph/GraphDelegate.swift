//
//  GraphDelegate.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete

//@_spi(ForOpenSwiftUIOnly)
/*public*/
protocol GraphDelegate: AnyObject {
    func updateGraph<T>(body: (GraphHost) -> T) -> T
    func graphDidChange()
    func preferencesDidChange()
    func beginTransaction()
}

@_spi(ForOpenSwiftUIOnly)
extension GraphDelegate {
    public func beginTransaction() {
        // TODO
    }
}
