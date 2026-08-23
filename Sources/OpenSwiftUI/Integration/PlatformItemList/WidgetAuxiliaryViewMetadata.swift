//
//  WidgetAuxiliaryViewMetadata.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 5D203C4BCF4ED90873E64430FDF30283 (SwiftUI)

import Foundation
import CoreFoundation
import OpenAttributeGraphShims
import UIFoundation_Private
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public import AppKit
#elseif canImport(UIKit)
public import UIKit
#endif

// MARK: - WidgetAuxiliaryViewMetadata [WIP]

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public struct WidgetAuxiliaryViewMetadata {

    // MARK: - WidgetAuxiliaryViewMetadata.Text

    public struct Text {
        public struct Metadata {
            public enum Kind {
                case string(String)
                case graphic(Graphic)
                case dateAbsolute(Date, OpenSwiftUICore.Text.DateStyle)
                case dateInterval(DateInterval)
                case dateCurrent(String, Bool, TimeZone?)
                case dateTimer(DateInterval, TimeInterval?, Bool)
                @available(OpenSwiftUI_v6_0, *)
                case timedata(TimeDataFormattingContainer)
            }

            public var kind: Kind

            public var range: NSRange

            public var color: Color?

            public var features: [CFDictionary]?

            @available(OpenSwiftUI_v5_0, *)
            public var textScale: OpenSwiftUICore.Text.Scale?
        }

        public var text: NSAttributedString

        public var metadata: [Metadata] {
            var result: [Metadata] = []
            var previousResolvableTextSegment: ResolvableTextSegmentAttribute.Value?
            text.enumerateAttributes(
                in: text.range,
                options: []
            ) { attributes, range, _ in
                let resolvableTextSegment = attributes[.resolvableTextSegment] as? ResolvableTextSegmentAttribute.Value
                guard resolvableTextSegment == nil ||
                        resolvableTextSegment != previousResolvableTextSegment else {
                    return
                }
                previousResolvableTextSegment = resolvableTextSegment
                let kind: Metadata.Kind
                if let specialMetadata = Self.extractSpecialMetadata(from: attributes) {
                    kind = specialMetadata
                } else {
                    kind = .string(text.attributedSubstring(from: range).string)
                }
                #if canImport(AppKit) && !targetEnvironment(macCatalyst)
                let color = (attributes[.foregroundColor] as? NSColor).map(Color.init)
                #elseif canImport(UIKit)
                let color = (attributes[.foregroundColor] as? UIColor).map(Color.init)
                #else
                let color: Color? = nil
                #endif
                #if canImport(AppKit) && !targetEnvironment(macCatalyst)
                let font = attributes[.font] as? NSFont
                let features = font?.fontDescriptor.object(forKey: .featureSettings) as? [NSDictionary]
                #elseif canImport(UIKit)
                let font = attributes[.font] as? UIFont
                let features = font?.fontDescriptor.object(forKey: .featureSettings) as? [NSDictionary]
                #else
                let features: [CFDictionary]? = nil
                #endif
                let textScale = (attributes[._textScale] as? String).flatMap(OpenSwiftUICore.Text.Scale.init)
                result.append(
                    Metadata(
                        kind: kind,
                        range: range,
                        color: color,
                        features: features,
                        textScale: textScale
                    )
                )
            }
            return result
        }

        fileprivate static func extractSpecialMetadata(
            from attributes: [NSAttributedString.Key: Any]
        ) -> Metadata.Kind? {
            #if canImport(AppKit) || canImport(UIKit)
            if let attachment = attributes[.attachment] as? NSTextAttachment {
                return metadataKind(from: attachment)
            }
            #endif
            if let absoluteDate = attributes[ResolvableAbsoluteDate.attribute] as? ResolvableAbsoluteDate {
                return .dateAbsolute(absoluteDate.date, absoluteDate.style)
            }
            if let dateInterval = attributes[ResolvableDateInterval.attribute] as? ResolvableDateInterval {
                return .dateInterval(dateInterval.interval)
            }
            if let dateCurrent = attributes[ResolvableCurrentDate.attribute] as? ResolvableCurrentDate {
                let dateFormat: String
                let isTemplate: Bool
                switch dateCurrent.dateFormat {
                case let .format(format):
                    dateFormat = format
                    isTemplate = false
                case let .template(template):
                    dateFormat = template
                    isTemplate = true
                @unknown default: _openSwiftUIUnreachableCode()
                }
                return .dateCurrent(dateFormat, isTemplate, dateCurrent.timeZone)
            }
            if let dateTimer = attributes[ResolvableTimer.attribute] as? ResolvableTimer {
                return .dateTimer(dateTimer.interval, dateTimer.pause, dateTimer.countdown)
            }
            if let timeData = attributes[TimeDataFormatting.attribute] as? any ResolvableStringAttribute,
               let container = TimeDataFormattingContainer(resolvable: timeData) {
                return .timedata(container)
            }
            return nil
        }

        #if canImport(AppKit) || canImport(UIKit)
        private static func metadataKind(
            from attachment: NSTextAttachment
        ) -> Metadata.Kind? {
            if let contents = attachment.contents {
                guard let metadata = try? PropertyListDecoder().decode(
                    WidgetAuxiliaryViewMetadata.self,
                    from: contents
                ) else {
                    Log.internalWarning("text attachment contents of unknown type")
                    return nil
                }
                guard let graphic = metadata.graphic else {
                    return nil
                }
                return .graphic(graphic)
            } else if let image = attachment.image {
                return .graphic(.image(image))
            } else {
                Log.internalWarning("text attachment does not have contents or image")
                return nil
            }
        }
        #endif
    }

    // MARK: - WidgetAuxiliaryViewMetadata.Graphic [WIP]

    public enum Graphic {
        case named(Named)

        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        case image(NSImage)
        #elseif canImport(UIKit)
        case image(UIImage)
        #else
        case image(NSObject)
        #endif

        var isSymbol: Bool {
            guard case let .named(named) = self else {
                return false
            }
            return named.isSymbol
        }

        public struct Named {
            public enum Location {
                case bundle(URL)
                case system(Bool)
            }

            public var name: String

            public var location: Location

            public var value: Float?

            var isSymbol: Bool

            fileprivate var _colors: [Color.Resolved]?

            public var colors: [Color]? {
                _colors?.map(Color.init)
            }

            fileprivate var _tintColor: Color.Resolved?

            @available(OpenSwiftUI_v6_0, *)
            public var tintColor: Color? {
                _tintColor.map(Color.init)
            }

            private var _mode: SymbolRenderingMode.Storage?

            public var symbolRenderingMode: SymbolRenderingMode? {
                _mode.map { SymbolRenderingMode(storage: $0) }
            }

            // TODO: SymbolEffect
//            @ProtobufCodable
//            private var _symbolEffects: SymbolEffectArray
//            @available(OpenSwiftUI_v6_0, *)
//            public var symbolEffects: [SymbolEffect] {
//                _symbolEffects.effects.map { SymbolEffect(base: $0) }
//            }

            @ProtobufCodable
            private var _contentTransition: ContentTransition

            @available(OpenSwiftUI_v6_0, *)
            public var contentTransition: ContentTransition {
                _contentTransition
            }

            // TBA
            init(_ named: Image.NamedResolved, _ resolvedImage: Image.Resolved?) {
                let environment = named.environment
//                _symbolEffects = SymbolEffectArray(effects: environment.symbolEffects)
                _contentTransition = environment.contentTransition
                guard !environment.shouldRedactSymbolImages else {
                    name = "square.fill"
                    location = .system(false)
                    value = nil
                    isSymbol = true
                    _colors = environment._effectiveForegroundColor.map {
                        [$0.resolve(in: environment)]
                    } ?? []
                    _mode = .monochrome
                    return
                }
                name = named.name
                switch named.location {
                case let .bundle(bundle):
                    location = .bundle(bundle.bundleURL)
                    if case .vectorGlyph? = resolvedImage?.image.contents {
                        isSymbol = true
                    } else {
                        isSymbol = false
                    }
                case .system:
                    location = .system(false)
                    isSymbol = true
                case .privateSystem:
                    location = .system(true)
                    isSymbol = true
                }
                value = named.value
                _mode = named.symbolRenderingMode
                if _mode == nil,
                   case let .vectorGlyph(glyph)? = resolvedImage?.image.contents {
                    _mode = glyph.renderingMode
                }

                if let resolvedImage {
                    let levels: Int = {
                        let resolverMode = resolvedImage.styleResolverMode
                        var levels = Int(resolverMode.foregroundLevels)
                        if !resolverMode.options.contains(.foregroundPalette) {
                            if named.isTemplate {
                                levels = 1
                            } else {
                                levels = levels == 0 ? 0 : 1
                            }
                        }
                        return levels
                    }()
                    if levels == 0 {
                        _colors = nil
                    } else if let foregroundStyle = environment.foregroundStyle {
                        var shape = _ShapeStyle_Shape(
                            operation: .resolveStyle(
                                name: .foreground,
                                levels: 0 ..< levels
                            ),
                            environment: environment
                        )
                        foregroundStyle._apply(to: &shape)
                        var colors: [Color.Resolved] = []
                        for style in shape.stylePack[.foreground] {
                            guard let color = style.color else {
                                break
                            }
                            colors.append(color)
                        }
                        _colors = colors
                    } else {
                        _colors = []
                    }
                } else {
                    _colors = named.isTemplate ? [] : nil
                }
                _tintColor = environment.tintColor?.resolve(in: environment)
            }
        }
    }


    public private(set) var metadataText: WidgetAuxiliaryViewMetadata.Text?

    @available(OpenSwiftUI_v5_0, *)
    public private(set) var metadataSecondaryText: WidgetAuxiliaryViewMetadata.Text?

    public private(set) var graphic: WidgetAuxiliaryViewMetadata.Graphic?
}

//private struct SymbolEffectArray: CodableByProtobuf, Equatable {
//    var effects: [_SymbolEffect]
//
//    init(effects: [_SymbolEffect.Identified]) {
//        self.effects = effects.map(\.effect)
//    }
//
//    func encode(to encoder: inout ProtobufEncoder) throws {
//        for effect in effects {
//            try encoder.messageField(1, effect)
//        }
//    }
//
//    init(from decoder: inout ProtobufDecoder) throws {
//        effects = []
//        while let field = try decoder.nextField() {
//            switch field.tag {
//            case 1:
//                effects.append(try decoder.messageField(field))
//            default:
//                try decoder.skipField(field)
//            }
//        }
//    }
//}

extension TimeDataFormattingContainer {
    public func representation(
        for version: _ArchivedViewStates.DeploymentVersion
    ) -> WidgetAuxiliaryViewMetadata.Text.Metadata.Kind? {
        let representation = representation(for: version.base)
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[type(of: representation).attribute] = representation
        return WidgetAuxiliaryViewMetadata.Text.extractSpecialMetadata(from: attributes)
    }
}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata {
    public var tint: Color? {
        guard let graphic,
              case let .named(named) = graphic else {
            return nil
        }
        return named.tintColor
    }

    public var resolvedTint: Color.Resolved? {
        guard let graphic,
              case let .named(named) = graphic else {
            return nil
        }
        return named._tintColor
    }
}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Graphic: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Graphic.Named: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Graphic.Named.Location: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Text: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Text.Metadata: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Text.Metadata.Kind: Sendable {}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension WidgetAuxiliaryViewMetadata {
    @available(*, deprecated, message: "Use metadataText instead")
    public var text: NSAttributedString? {
        metadataText?.text
    }

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    @available(*, deprecated, message: "Use graphic instead")
    public var image: NSImage? {
        guard let graphic,
              case let .image(image) = graphic else {
            return nil
        }
        return image
    }
    #elseif canImport(UIKit)
    @available(*, deprecated, message: "Use graphic instead")
    public var image: UIImage? {
        guard let graphic,
              case let .image(image) = graphic else {
            return nil
        }
        return image
    }
    #else
    @available(*, deprecated, message: "Use graphic instead")
    public var image: NSObject? {
        guard let graphic,
              case let .image(image) = graphic else {
            return nil
        }
        return image
    }
    #endif
}

// MARK: - WidgetAuxiliaryViewMetadata + Codable [TODO]

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension WidgetAuxiliaryViewMetadata: Codable {
    public func encode(to encoder: any Encoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    public init(from decoder: any Decoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - WidgetAuxiliaryViewMetadata + CustomDebugStringConvertible [TODO]

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .named(named):
            "Graphic(\(named.debugDescription))"
        case let .image(image):
            "Graphic(\(image.debugDescription))"
        }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic.Named: CustomDebugStringConvertible {
    public var debugDescription: String {
        let locationDescription: String
        switch location {
        case let .bundle(url):
            locationDescription = "bundle(\(url.description))"
        case let .system(isPublic):
            locationDescription = isPublic ? "system" : "internal"
        }
        return "Named(name: \(name), location: \(locationDescription), value: \(value?.description ?? "--"), colors: \(colors?.debugDescription ?? "[]"))"
    }
}

// MARK: - WidgetAuxiliaryViewMetadata + Equatable

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic.Named.Location: Equatable {}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic.Named: Equatable {}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic: Equatable {}

// TODO: Preference
