//
//  InterfaceIdiom.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 39057DDA72E946BD17E1F42CCA55F7F6 (SwiftUICore)

#if OPENSWIFTUI_SUPPORT_2024_API

// MARK: - InterfaceIdiom

package protocol InterfaceIdiom {
    static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiom
    static var hashValue: InterfaceIdiomKind { get }
}

// MARK: - InterfaceIdiomKind

package enum InterfaceIdiomKind {
    case carPlay
    case clarity
    case complication
    case widget
    case mac
    case macCatalyst
    case phone
    case pad
    case tv
    case touchBar
    case watch
    case vision
    case nokit
}

// MARK: - InterfaceIdiom + Extensions

extension InterfaceIdiom {
    @inlinable
    package static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiom {
        self.self == type
    }
    
    @inlinable
    package static func accepts<I>(_ idiom: I) -> Bool where I: InterfaceIdiom {
        accepts(I.self)
    }
}

extension InterfaceIdiom where Self == CarPlayInterfaceIdiom {
    @inlinable
    package static var carPlay: CarPlayInterfaceIdiom {
        CarPlayInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == ClarityUIInterfaceIdiom {
    @inlinable
    package static var clarityUI: ClarityUIInterfaceIdiom {
        ClarityUIInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == ComplicationInterfaceIdiom {
    @inlinable
    package static var complication: ComplicationInterfaceIdiom {
        ComplicationInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == WidgetInterfaceIdiom {
    @inlinable
    package static var widget: WidgetInterfaceIdiom {
        WidgetInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == MacInterfaceIdiom {
    @inlinable
    package static var mac: MacInterfaceIdiom {
        MacInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == MacCatalystInterfaceIdiom {
    @inlinable
    package static var macCatalyst: MacCatalystInterfaceIdiom {
        MacCatalystInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == PhoneInterfaceIdiom {
    @inlinable
    package static var phone: PhoneInterfaceIdiom {
        PhoneInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == PadInterfaceIdiom {
    @inlinable
    package static var pad: PadInterfaceIdiom {
        PadInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == TVInterfaceIdiom {
    @inlinable
    package static var tv: TVInterfaceIdiom {
        TVInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == TouchBarInterfaceIdiom {
    @inlinable
    package static var touchBar: TouchBarInterfaceIdiom {
        TouchBarInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == WatchInterfaceIdiom {
    @inlinable
    package static var watch: WatchInterfaceIdiom {
        WatchInterfaceIdiom()
    }
}

extension InterfaceIdiom where Self == VisionInterfaceIdiom {
    @inlinable
    package static var vision: VisionInterfaceIdiom {
        VisionInterfaceIdiom()
    }
}
extension InterfaceIdiom where Self == NoKitInterfaceIdiom {
    @inlinable
    package static var nokit: NoKitInterfaceIdiom {
        NoKitInterfaceIdiom()
    }
}

package struct CarPlayInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .carPlay
}

package struct ClarityUIInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .clarity
}

package struct ComplicationInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .complication
    package static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiom {
        type == WidgetInterfaceIdiom.self || type == ComplicationInterfaceIdiom.self
    }
}

package struct WidgetInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .widget
}

package struct MacInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .mac
}

package struct MacCatalystInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .macCatalyst
}

package struct PhoneInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .phone
}

package struct PadInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .pad
}

package struct TVInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .tv
}

package struct TouchBarInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .touchBar
}

package struct WatchInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .watch
}

package struct VisionInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .vision
}

package struct NoKitInterfaceIdiom: InterfaceIdiom {
    package static let hashValue: InterfaceIdiomKind = .nokit
}

package struct AnyInterfaceIdiom: Hashable {
    private let base: any AnyInterfaceIdiomBox.Type
    
    package init<I>(_: I) where I: InterfaceIdiom {
        base = InterfaceIdiomBox<I>.self
    }
    
    package static func == (lhs: AnyInterfaceIdiom, rhs: AnyInterfaceIdiom) -> Bool {
        lhs.base.isEqual(to: rhs.base)
    }
    
    package func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
    
    package func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiom {
        base.accepts(type)
    }
    
    package func accepts<I>(_ idiom: I) -> Bool where I: InterfaceIdiom {
        accepts(I.self)
    }
}

private protocol AnyInterfaceIdiomBox {
    static func isEqual(to type: any AnyInterfaceIdiomBox.Type) -> Bool
    static func accepts<I>(_ type: I.Type) -> Bool where I: InterfaceIdiom
    static func hash(into hasher: inout Hasher)
}

private struct InterfaceIdiomBox<Base>: AnyInterfaceIdiomBox where Base: InterfaceIdiom {
    static func isEqual(to type: any AnyInterfaceIdiomBox.Type) -> Bool {
        type is InterfaceIdiomBox<Base>.Type
    }
    
    static func accepts<I>(_ type: I.Type) -> Bool where I : InterfaceIdiom {
        Base.accepts(type)
    }
    
    static func hash(into hasher: inout Hasher) {
        hasher.combine(Base.hashValue)
    }
}

#endif
