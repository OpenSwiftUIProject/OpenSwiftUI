//
//  Transaction.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/2.
//  Lastest Version: iOS 15.5
//  Status: Empty
//  ID: 39EC6D46662E6D7A6963F5C611934B0A

@frozen
public struct Transaction {
    @usableFromInline
    var plist: PropertyList
  
    @inlinable
    public init() {
        plist = PropertyList()
    }
}

//extension Transaction {
    // Blocked by PropertyList implementation
//    public init(animation: Animation?) {
//
//    }
//    public var animation: Animation? {
//        get {}
//        set {}
//    }
//    public var disablesAnimations: Bool {
//        get
//        set
//    }
//}

//extension Transaction {
//    public var isContinuous: Bool {
//        get
//        set
//    }
//}
//
//extension Transaction {
//    public var _scrollViewAnimates: _ScrollViewAnimationMode {
//        get
//        set
//    }
//}

protocol TransactionKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

private struct AnimationKey: TransactionKey {
    static let defaultValue: Animation? = nil
}
