//
//  InterfaceIdiom.swift
//
//
//  Created by Kyle-Ye on 2023/8/28.

// Identifier: _2FFD16F575FFD9B8AC17BCAE09549F2
// Introduced by iOS 14.0
// Updated to iOS 15.0

import UIKit

// MARK: InterfaceIdiomType

internal protocol InterfaceIdiomType {
    static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiomType
}

extension InterfaceIdiomType {
    internal static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiomType {
        self.self == type
    }
}

internal enum InterfaceIdiom {
}

extension InterfaceIdiom {
    internal struct TouchBar: InterfaceIdiomType {}
    internal struct Pad: InterfaceIdiomType {}
    internal struct Watch: InterfaceIdiomType {}
    internal struct TV: InterfaceIdiomType {}
    internal struct Phone: InterfaceIdiomType {}
    internal struct Mac: InterfaceIdiomType {}
    internal struct CarPlay: InterfaceIdiomType {}
}

// MARK: AnyInterfaceIdiomType

internal struct AnyInterfaceIdiomType: Equatable {
    internal static func == (lhs: AnyInterfaceIdiomType, rhs: AnyInterfaceIdiomType) -> Bool {
        lhs.base.isEqual(to: rhs.base)
    }
    
    fileprivate let base: AnyInterfaceIdiomTypeBox.Type
}

extension InterfaceIdiom {
    internal struct Input: ViewInput {
        internal typealias Value = AnyInterfaceIdiomType?
        internal static var defaultValue: AnyInterfaceIdiomType? = nil
    }
}

extension UIUserInterfaceIdiom {
    internal var idiom: AnyInterfaceIdiomType? {
        // TODO: Align with iOS 15.0 We should add visionOS(6) later
        switch rawValue {
        case UIUserInterfaceIdiom.unspecified.rawValue: return nil
        case UIUserInterfaceIdiom.phone.rawValue: return AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Phone>.self)
        case UIUserInterfaceIdiom.pad.rawValue: return AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Pad>.self)
        case UIUserInterfaceIdiom.tv.rawValue: return AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.TV>.self)
        case UIUserInterfaceIdiom.carPlay.rawValue: return AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.CarPlay>.self)
        // There is no UIUserInterfaceIdiom.watch exposed currently
        case 4: return AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Watch>.self)
        // UIUserInterfaceIdiom.mac.rawValue
        case 5: return AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Mac>.self)
        default: return nil
        }
    }
}

// MARK: - InterfaceIdiomTypeBox

private struct InterfaceIdiomTypeBox<IdiomType>: AnyInterfaceIdiomTypeBox where IdiomType: InterfaceIdiomType {
    // pwt + 0x10
    static func isEqual(to type: AnyInterfaceIdiomTypeBox.Type) -> Bool {
        type is InterfaceIdiomTypeBox<IdiomType>.Type
    }
    
    // pwt + 0x20
    static func accepts(_ type: (some InterfaceIdiomType).Type) -> Bool {
        IdiomType.accepts(type)
    }
}


// MARK: - AnyInterfaceIdiomTypeBox

private protocol AnyInterfaceIdiomTypeBox {
    static func isEqual(to: AnyInterfaceIdiomTypeBox.Type) -> Bool
    static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiomType
}
