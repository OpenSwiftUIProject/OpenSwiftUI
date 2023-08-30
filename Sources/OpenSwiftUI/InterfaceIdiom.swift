//
//  InterfaceIdiom.swift
//
//
//  Created by Kyle-Ye on 2023/8/28.

// Identifier: _2FFD16F575FFD9B8AC17BCAE09549F2
// Introduced by iOS 14.0
// Updated to iOS 15.5

// MARK: InterfaceIdiomType

protocol InterfaceIdiomType {
    static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiomType
}

extension InterfaceIdiomType {
    static func accepts(_ type: (some InterfaceIdiomType).Type) -> Bool {
        self.self == type
    }
}

enum InterfaceIdiom {}

extension InterfaceIdiom {
    struct TouchBar: InterfaceIdiomType {}
    struct Pad: InterfaceIdiomType {}
    struct Watch: InterfaceIdiomType {}
    struct TV: InterfaceIdiomType {}
    struct Phone: InterfaceIdiomType {}
    struct Mac: InterfaceIdiomType {}
    struct CarPlay: InterfaceIdiomType {}
    struct Vision: InterfaceIdiomType {}
}

// MARK: AnyInterfaceIdiomType

struct AnyInterfaceIdiomType {
    fileprivate let base: AnyInterfaceIdiomTypeBox.Type
}

extension AnyInterfaceIdiomType: Equatable {
    static func == (lhs: AnyInterfaceIdiomType, rhs: AnyInterfaceIdiomType) -> Bool {
        lhs.base.isEqual(to: rhs.base)
    }
}

extension AnyInterfaceIdiomType {
    @inline(__always)
    static var touchBar: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.TouchBar>.self) }
    @inline(__always)
    static var pad: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Pad>.self) }
    @inline(__always)
    static var watch: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Watch>.self) }
    @inline(__always)
    static var tv: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.TV>.self) }
    @inline(__always)
    static var phone: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Phone>.self) }
    @inline(__always)
    static var mac: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Mac>.self) }
    @inline(__always)
    static var carplay: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.CarPlay>.self) }
    @inline(__always)
    static var vision: AnyInterfaceIdiomType { AnyInterfaceIdiomType(base: InterfaceIdiomTypeBox<InterfaceIdiom.Vision>.self) }
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

// MARK: - Internal API

extension InterfaceIdiom {
    struct Input: ViewInput {
        typealias Value = AnyInterfaceIdiomType?
        static var defaultValue: AnyInterfaceIdiomType? = nil
        static var targetValue: AnyInterfaceIdiomType = .phone
    }
}

#if canImport(UIKit)
import UIKit

extension UIUserInterfaceIdiom {
    var idiom: AnyInterfaceIdiomType? {
        switch rawValue {
        case UIUserInterfaceIdiom.unspecified.rawValue: return nil
        case UIUserInterfaceIdiom.phone.rawValue: return .phone
        case UIUserInterfaceIdiom.pad.rawValue: return .pad
        case UIUserInterfaceIdiom.tv.rawValue: return .tv
        case UIUserInterfaceIdiom.carPlay.rawValue: return .carplay
        case 4: return .watch // There is no UIUserInterfaceIdiom.watch exposed currently
        case 5: return .mac // iOS 14 UIUserInterfaceIdiom.mac.rawValue
        case 6: return .vision // iOS 17 UIUserInterfaceIdiom.vision.rawValue
        default: return nil
        }
    }
}
#endif
