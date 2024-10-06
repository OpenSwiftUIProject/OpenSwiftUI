//
//  ObservableObjectLocation.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by PropertyList.Element

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
internal import COpenSwiftUICore
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

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
    
    // FIXME
    static func == (lhs: ObservableObjectLocation<Root, Value>, rhs: ObservableObjectLocation<Root, Value>) -> Bool {
        lhs.base === rhs.base && lhs.keyPath == rhs.keyPath
    }
}

//extension ObservableObjectLocation: TransactionHostProvider {
//    // TODO
//    var mutationHost: GraphHost? { nil }
//}
