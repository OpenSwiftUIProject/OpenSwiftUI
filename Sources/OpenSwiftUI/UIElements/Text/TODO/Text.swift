//
//  Text.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: Empty

#if canImport(Darwin)
import CoreGraphics
#elseif os(Linux)
import Foundation
#endif

@frozen
public struct Text: Equatable {
    @usableFromInline
    @frozen
    enum Storage: Equatable {
        case verbatim(String)
        case anyTextStorage(AnyTextStorage)
        @usableFromInline
        static func == (lhs: Storage, rhs: Storage) -> Bool {
            switch (lhs, rhs) {
            case let (.verbatim(lv), .verbatim(rv)): lv == rv
//            case let (.anyTextStorage(lv), .anyTextStorage(rv)): lv.isEqual(to: rv)
            default: false
            }
        }
    }

    @usableFromInline
    @frozen
    enum Modifier: Equatable {
//        case color(Color?)
//        case font(Font?)
        case italic
//        case weight(Font.Weight?)
        case kerning(CGFloat)
        case tracking(CGFloat)
        case baseline(CGFloat)
        case rounded
//        case anyTextModifier(AnyTextModifier)
        @usableFromInline
        static func == (lhs: Modifier, rhs: Modifier) -> Bool {
            // FIXME
            .random()
        }
    }

    @usableFromInline
    var storage: Storage
    @usableFromInline
    var modifiers = [Modifier]()

    public init(verbatim content: String) {
        storage = .verbatim(content)
    }

    @_disfavoredOverload
    public init<S>(_ content: S) where S : StringProtocol {
        // FIXME
        storage = .verbatim("")
    }

    public static func == (a: Text, b: Text) -> Bool {
        // FIXME
        .random()
    }
}

extension Text: PrimitiveView, UnaryView {}
