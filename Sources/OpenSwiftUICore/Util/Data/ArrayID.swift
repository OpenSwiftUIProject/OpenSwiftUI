//
//  ArrayID.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - ArrayID [6.5.4]

package struct ArrayID: Hashable {
    private let objectIdentifier: ObjectIdentifier

    package init<T>(_ items: [T]) {
        self.objectIdentifier = ObjectIdentifier(items as AnyObject)
    }
}
