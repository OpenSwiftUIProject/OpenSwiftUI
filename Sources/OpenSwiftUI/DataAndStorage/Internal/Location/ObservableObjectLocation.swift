//
//  ObservableObjectLocation.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Blocked by PropertyList.Element

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
internal import OpenSwiftUIShims

struct ObservableObjectLocation<Root, Value>: Location where Root: ObservableObject {
    let base: Root
    let keyPath: ReferenceWritableKeyPath<Root, Value>

    var wasRead: Bool {
        get { true }
        set {}
    }
    func get() -> Value { base[keyPath: keyPath] }
    // FIXME
    func set(_ value: Value, transaction: Transaction) {
        let element = _threadTransactionData().map { Unmanaged<PropertyList.Element>.fromOpaque($0).takeRetainedValue() }
        let newElement: PropertyList.Element?
        if let element = transaction.plist.elements {
            newElement = element.byPrepending(element)
        } else {
            newElement = element
        }

        let data = _threadTransactionData()
        defer { _setThreadTransactionData(data) }
        _setThreadTransactionData(newElement.map { Unmanaged.passUnretained($0).toOpaque() })
        base[keyPath: keyPath] = value
    }
}
