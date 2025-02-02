//
//  HostingViewRegistry.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 08E507B775941708E73E5FD8531D9361 (SwiftUI)

@_spi(Private)
public import OpenSwiftUICore

@_spi(Private)
public protocol HostingViewProtocol: AnyObject {
    func preferenceValue<K>(_ key: K.Type) -> K.Value where K: HostPreferenceKey
    func convertAnchor<Value>(_ anchor: Anchor<Value>) -> Value
}

@_spi(Private)
public class HostingViewRegistry {
    public static let shared: HostingViewRegistry = HostingViewRegistry()
    
    public func forEach(_ body: (any HostingViewProtocol) throws -> Void) rethrows {
        try elements.values.forEach { box in
            guard let element = box.base as? HostingViewProtocol else {
                return
            }
            try body(element)
        }
    }
    
    private var elements: [ObjectIdentifier: WeakBox<AnyObject>] = [:]
    
    func add<V>(_ element: V) where V: HostingViewProtocol {
        elements[ObjectIdentifier(element)] = WeakBox(element)
    }
    
    func remove<V>(_ element: V) where V: HostingViewProtocol {
        elements.removeValue(forKey: ObjectIdentifier(element))
    }
}

@_spi(Private)
@available(*, unavailable)
extension HostingViewRegistry: Sendable {}
