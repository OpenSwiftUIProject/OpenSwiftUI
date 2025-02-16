//
//  CachedEnvironment.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: C424ABD9FC88B2DFD0B7B2319F2E7987

import Foundation
package import OpenGraphShims

package struct CachedEnvironment {
    package var environment: Attribute<EnvironmentValues>
    private var items: [Item]
    private var constants: [HashableConstant: AnyAttribute]
//    private var animatedFrame: AnimatedFrame?
    // private var resolvedFgStyles: [ResolvedFgStyle : Swift<_ShapeStyle_Resolved.ResolvedFg>]
    
    package init(_ environment: Attribute<EnvironmentValues>) {
        self.environment = environment
        items = []
        constants = [:]
//        animatedFrame = nil
        // resolvedFgStyles = [:] FIXME: 0x100: ?
    }
    
    package mutating func attribute<Value>(keyPath: KeyPath<EnvironmentValues, Value>) -> Attribute<Value> {
        if let item = items.first(where: { $0.key == keyPath }) {
            return Attribute(identifier: item.value)
        } else {
            let value = environment[keyPath: keyPath]
            items.append(Item(key: keyPath, value: value.identifier))
            return value
        }
    }
    
    package mutating func intern<Value>(_ value: Value, id: Int) -> Attribute<Value> {
        let constant = HashableConstant(value, id: id)
        if let identifier = constants[constant] {
            return Attribute(identifier: identifier)
        } else {
            let attribute = Attribute(value: value)
            constants[constant] = attribute.identifier
            return attribute
        }
    }
    
    func animatedPosition(for inputs: _ViewInputs) -> Attribute<ViewOrigin> {
        preconditionFailure("TODO")
    }
    
    func animatedSize(for inputs: _ViewInputs) -> Attribute<ViewSize> {
        preconditionFailure("TODO")
    }
    
    func animatedCGSize(for inputs: _ViewInputs) -> Attribute<CGSize> {
        preconditionFailure("TODO")
    }
    
    // func resolvedForegroundStyle() {}
}

extension CachedEnvironment {
    private struct Item {
        var key: PartialKeyPath<EnvironmentValues>
        var value: AnyAttribute
    }
}

private protocol _Constant {
    func hash(into hasher: inout Hasher)
    func isEqual(to other: _Constant) -> Bool
}

private struct Constant<Value>: _Constant {
    let value: Value
    let id: Int
    
    init(_ value: Value, id: Int) {
        self.value = value
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Value.self))
        hasher.combine(id)
    }
    
    func isEqual(to other: _Constant) -> Bool {
        let otherConstant = other as? Constant<Value>
        return otherConstant.map { id == $0.id } ?? false
    }
}

private struct HashableConstant: Hashable {
    let value: _Constant
    
    init<Value>(_ value: Value, id: Int) {
        self.value = Constant(value, id: id)
    }
    
    func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
    
    static func == (lhs: HashableConstant, rhs: HashableConstant) -> Bool {
        lhs.value.isEqual(to: rhs.value)
    }
}

//private struct AnimatedFrame {
//    let position: Attribute<ViewOrigin>
//    let size: Attribute<ViewSize>
//    let pixelLength: Attribute<CGFloat>
//    let time: Attribute<Time>
//    let transaction: Attribute<Transaction>
//    let viewPhase: Attribute<_GraphInputs.Phase>
//    let animatedFrame: Attribute<ViewFrame>
//    private var _animatedPosition: Attribute<ViewOrigin>?
//    private var _animatedSize: Attribute<ViewSize>?
//    
//    mutating func animatePosition() -> Attribute<ViewOrigin> {
//        guard let _animatedPosition else {
//            // FIXME
//            let animatePosition = animatedFrame.unsafeOffset(
//                at: 0,
//                as:ViewOrigin.self
//            )
//            _animatedPosition = animatePosition
//            return animatePosition
//        }
//        return _animatedPosition
//    }
//    
//    mutating func animateSize() -> Attribute<ViewSize> {
//        guard let _animatedSize else {
//            // FIXME
//            let animatedSize = animatedFrame.unsafeOffset(
//                at: MemoryLayout<ViewOrigin>.size,
//                as: ViewSize.self
//            )
//            _animatedSize = animatedSize
//            return animatedSize
//        }
//        return _animatedSize
//    }
//}
