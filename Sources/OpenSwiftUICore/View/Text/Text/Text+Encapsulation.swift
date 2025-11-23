//
//  Text+Encapsulation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenCoreGraphicsShims
import UIFoundation_Private

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension Text {
    public struct Encapsulation: Hashable, Sendable {
        var scale: Scale?
        var shape: Shape?
        var style: Style?
        var lineWeight: CGFloat?
        var color: Color?
        var minimumWidth: CGFloat?
        var platterSize: PlatterSize?

        @_disfavoredOverload
        public init(
            scale: Text.Encapsulation.Scale? = nil,
            shape: Text.Encapsulation.Shape? = nil,
            style: Text.Encapsulation.Style? = nil,
            lineWeight: CGFloat? = nil,
            color: Color? = nil,
            minimumWidth: CGFloat? = nil
        ) {
            self.scale = scale
            self.shape = shape
            self.style = style
            self.lineWeight = lineWeight
            self.color = color
            self.minimumWidth = minimumWidth
        }

        @available(OpenSwiftUI_v5_0, *)
        public init(
            scale: Text.Encapsulation.Scale? = nil,
            shape: Text.Encapsulation.Shape? = nil,
            style: Text.Encapsulation.Style? = nil,
            platterSize: Text.Encapsulation.PlatterSize? = nil,
            lineWeight: CGFloat? = nil,
            color: Color? = nil,
            minimumWidth: CGFloat? = nil
        ) {
            self.scale = scale
            self.shape = shape
            self.style = style
            self.platterSize = platterSize
            self.lineWeight = lineWeight
            self.color = color
            self.minimumWidth = minimumWidth
        }

        public struct Scale: Hashable, Sendable {
            let nsScale: NSTextEncapsulationScale

            public static let small: Text.Encapsulation.Scale = .init(nsScale: .small)

            public static let medium: Text.Encapsulation.Scale = .init(nsScale: .medium)

            public static let large: Text.Encapsulation.Scale = .init(nsScale: .large)
        }

        public struct Shape: Hashable, Sendable {
            let nsShape: NSTextEncapsulationShape

            public static let rectangle: Text.Encapsulation.Shape = .init(nsShape: .rectangle)

            public static let roundedRectangle: Text.Encapsulation.Shape = .init(nsShape: .roundedRectangle)

            public static let capsule: Text.Encapsulation.Shape = .init(nsShape: .capsule)
        }

        public struct Style: Hashable, Sendable {
            let nsStyle: NSTextEncapsulationStyle

            public static let outline: Text.Encapsulation.Style = .init(nsStyle: .outline)

            public static let fill: Text.Encapsulation.Style = .init(nsStyle: .fill)
        }

        @available(OpenSwiftUI_v5_0, *)
        public struct PlatterSize: Hashable, Sendable {
            let nsPlatterSize: NSTextEncapsulationPlatterSize

            public static let regular: Text.Encapsulation.PlatterSize = .init(nsPlatterSize: .regular)

            public static let large: Text.Encapsulation.PlatterSize = .init(nsPlatterSize: .large)
        }
    }
}
