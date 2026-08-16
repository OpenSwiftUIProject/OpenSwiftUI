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
#if os(macOS)
public import AppKit
#elseif canImport(UIKit)
public import UIKit
#endif

// MARK: - WidgetAuxiliaryViewMetadata

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public struct WidgetAuxiliaryViewMetadata {
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

            init(
                kind: Kind,
                range: NSRange,
                color: Color? = nil,
                features: [CFDictionary]? = nil,
                textScale: OpenSwiftUICore.Text.Scale? = nil
            ) {
                self.kind = kind
                self.range = range
                self.color = color
                self.features = features
                self.textScale = textScale
            }
        }

        public var text: NSAttributedString

        public var metadata: [Metadata] {
            guard text.length != 0 else {
                return []
            }
            var result: [Metadata] = []
            text.enumerateAttributes(
                in: NSRange(location: 0, length: text.length),
                options: []
            ) { attributes, range, _ in
                result.append(
                    Metadata(
                        kind: Self.metadataKind(
                            from: attributes,
                            fallback: text.attributedSubstring(from: range).string
                        ),
                        range: range,
                        color: Self.color(from: attributes),
                        features: Self.features(from: attributes),
                        textScale: Self.textScale(from: attributes)
                    )
                )
            }
            return result
        }

        init(_ text: NSAttributedString) {
            self.text = text
        }

        private static func metadataKind(
            from attributes: [NSAttributedString.Key: Any],
            fallback: String
        ) -> Metadata.Kind {
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *),
               let value = attributes[TimeDataFormattingContainer.attribute] {
                if let container = value as? TimeDataFormattingContainer {
                    return .timedata(container)
                }
                if let container = TimeDataFormattingContainer(resolvable: value) {
                    return .timedata(container)
                }
            }
            #if os(macOS)
            if let attachment = attributes[.attachment] as? NSTextAttachment,
               let kind = metadataKind(from: attachment) {
                return kind
            }
            #elseif canImport(UIKit)
            if let attachment = attributes[.attachment] as? NSTextAttachment,
               let kind = metadataKind(from: attachment) {
                return kind
            }
            #endif
            return .string(fallback)
        }

        #if os(macOS)
        private static func metadataKind(
            from attachment: NSTextAttachment
        ) -> Metadata.Kind? {
            attachment.image.map { .graphic(.image($0)) }
        }
        #elseif canImport(UIKit)
        private static func metadataKind(
            from attachment: NSTextAttachment
        ) -> Metadata.Kind? {
            attachment.image.map { .graphic(.image($0)) }
        }
        #endif

        private static func color(
            from attributes: [NSAttributedString.Key: Any]
        ) -> Color? {
            #if os(macOS)
            (attributes[.foregroundColor] as? NSColor).map(Color.init(nsColor:))
            #elseif canImport(UIKit)
            (attributes[.foregroundColor] as? UIColor).map(Color.init(uiColor:))
            #else
            nil
            #endif
        }

        private static func features(
            from attributes: [NSAttributedString.Key: Any]
        ) -> [CFDictionary]? {
            #if os(macOS)
            guard let font = attributes[.font] as? NSFont,
                  let settings = font.fontDescriptor.object(forKey: .featureSettings) as? [NSDictionary] else {
                return nil
            }
            #elseif canImport(UIKit)
            guard let font = attributes[.font] as? UIFont,
                  let settings = font.fontDescriptor.fontAttributes[.featureSettings] as? [NSDictionary] else {
                return nil
            }
            #else
            return nil
            #endif
            return settings.map { $0 as CFDictionary }
        }

        private static func textScale(
            from attributes: [NSAttributedString.Key: Any]
        ) -> OpenSwiftUICore.Text.Scale? {
            guard let scale = attributes[._textScale] as? String else {
                return nil
            }
            return OpenSwiftUICore.Text.Scale(scale)
        }
    }

    public enum Graphic {
        case named(Named)

        #if os(macOS)
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

            private var _colors: [Color.Resolved]?

            fileprivate var _tintColor: Color.Resolved?

            private var _mode: SymbolRenderingMode.Storage?

            private var _symbolEffects: [SymbolEffect]

            private var _contentTransition: ContentTransition

            public var colors: [Color]? {
                _colors?.map(Color.init)
            }

            @available(OpenSwiftUI_v6_0, *)
            public var tintColor: Color? {
                _tintColor.map(Color.init)
            }

            public var symbolRenderingMode: SymbolRenderingMode? {
                _mode.map { SymbolRenderingMode(storage: $0) }
            }

            @available(OpenSwiftUI_v6_0, *)
            public var symbolEffects: [SymbolEffect] {
                _symbolEffects
            }

            @available(OpenSwiftUI_v6_0, *)
            public var contentTransition: ContentTransition {
                _contentTransition
            }

            init(_ named: Image.NamedResolved, _ resolvedImage: Image.Resolved?) {
                name = named.name
                switch named.location {
                case let .bundle(bundle):
                    location = .bundle(bundle.bundleURL)
                case .system:
                    location = .system(false)
                case .privateSystem:
                    location = .system(true)
                }
                value = named.value
                switch resolvedImage?.image.contents {
                case .vectorGlyph?:
                    isSymbol = true
                default:
                    isSymbol = false
                }
                _mode = named.symbolRenderingMode
                if let maskColor = resolvedImage?.image.maskColor {
                    _colors = [maskColor]
                } else if named.isTemplate {
                    _colors = named.environment._effectiveForegroundColor.map {
                        [$0.resolve(in: named.environment)]
                    } ?? []
                } else {
                    _colors = nil
                }
                _tintColor = named.environment.tintColor?.resolve(in: named.environment)
                _symbolEffects = named.environment.symbolEffects.map {
                    SymbolEffect(base: $0.effect)
                }
                _contentTransition = named.environment.contentTransition
            }

            private init(
                name: String,
                location: Location,
                value: Float?,
                isSymbol: Bool,
                colors: [Color.Resolved]?,
                tintColor: Color.Resolved?,
                mode: SymbolRenderingMode.Storage?,
                symbolEffects: [SymbolEffect],
                contentTransition: ContentTransition
            ) {
                self.name = name
                self.location = location
                self.value = value
                self.isSymbol = isSymbol
                _colors = colors
                _tintColor = tintColor
                _mode = mode
                _symbolEffects = symbolEffects
                _contentTransition = contentTransition
            }
        }
    }

    public struct Progress {
        public enum Kind {
            case absolute(Double?, Bool)
            case date(ClosedRange<Date>, Bool)

            @inline(__always)
            init(_ value: ProgressViewValue) {
                switch value {
                case let .absolute(fractionCompleted, alwaysIndeterminate):
                    self = .absolute(fractionCompleted, alwaysIndeterminate)
                case let .dateRelative(interval, countdown):
                    self = .date(interval, countdown)
                }
            }
        }

        public var kind: Kind
        private var _labelBox: MutableBox<WidgetAuxiliaryViewMetadata?>
        private var _currentValueLabelBox: MutableBox<WidgetAuxiliaryViewMetadata?>
        private var _tint: ResolvedGradient?

        public var label: WidgetAuxiliaryViewMetadata? {
            get { _labelBox.wrappedValue }
            set { _labelBox.wrappedValue = newValue }
        }

        public var currentValueLabel: WidgetAuxiliaryViewMetadata? {
            get { _currentValueLabelBox.wrappedValue }
            set { _currentValueLabelBox.wrappedValue = newValue }
        }

        public var tint: Gradient? {
            _tint.map(Self.gradient)
        }

        init(
            kind: Kind,
            label: WidgetAuxiliaryViewMetadata?,
            currentValueLabel: WidgetAuxiliaryViewMetadata?,
            tint: ResolvedGradient?
        ) {
            self.kind = kind
            _labelBox = MutableBox(label)
            _currentValueLabelBox = MutableBox(currentValueLabel)
            _tint = tint
        }

        private static func gradient(_ resolved: ResolvedGradient) -> Gradient {
            Gradient(
                stops: resolved.stops.map {
                    Gradient.Stop(
                        color: Color($0.color),
                        location: $0.location
                    )
                }
            )
        }
    }

    public struct Gauge {
        public var value: Double

        private var _labelBox: MutableBox<WidgetAuxiliaryViewMetadata?>

        private var _currentValueLabelBox: MutableBox<WidgetAuxiliaryViewMetadata?>

        private var _minimumValueLabelBox: MutableBox<WidgetAuxiliaryViewMetadata?>

        private var _maximumValueLabelBox: MutableBox<WidgetAuxiliaryViewMetadata?>

        private var _tint: ResolvedGradient?

        public var label: WidgetAuxiliaryViewMetadata? {
            get { _labelBox.wrappedValue }
            set { _labelBox.wrappedValue = newValue }
        }

        public var currentValueLabel: WidgetAuxiliaryViewMetadata? {
            get { _currentValueLabelBox.wrappedValue }
            set { _currentValueLabelBox.wrappedValue = newValue }
        }

        public var minimumValueLabel: WidgetAuxiliaryViewMetadata? {
            get { _minimumValueLabelBox.wrappedValue }
            set { _minimumValueLabelBox.wrappedValue = newValue }
        }

        public var maximumValueLabel: WidgetAuxiliaryViewMetadata? {
            get { _maximumValueLabelBox.wrappedValue }
            set { _maximumValueLabelBox.wrappedValue = newValue }
        }

        public var tint: Gradient? {
            _tint.map { resolved in
                Gradient(
                    stops: resolved.stops.map {
                        Gradient.Stop(
                            color: Color($0.color),
                            location: $0.location
                        )
                    }
                )
            }
        }

        init(
            value: Double,
            label: WidgetAuxiliaryViewMetadata?,
            currentValueLabel: WidgetAuxiliaryViewMetadata?,
            minimumValueLabel: WidgetAuxiliaryViewMetadata?,
            maximumValueLabel: WidgetAuxiliaryViewMetadata?,
            tint: ResolvedGradient?
        ) {
            self.value = value
            _labelBox = MutableBox(label)
            _currentValueLabelBox = MutableBox(currentValueLabel)
            _minimumValueLabelBox = MutableBox(minimumValueLabel)
            _maximumValueLabelBox = MutableBox(maximumValueLabel)
            _tint = tint
        }
    }

    public struct Accessibility {
        public var label: String?

        public var value: String?

        public var identifier: String?

        @available(OpenSwiftUI_v6_0, *)
        public var hint: String?
    }

    public private(set) var metadataText: Text?

    @available(OpenSwiftUI_v6_0, *)
    public private(set) var metadataSecondaryText: Text?

    public private(set) var graphic: Graphic?

    public private(set) var fallbacks: [WidgetAuxiliaryViewMetadata]?

    public private(set) var progress: Progress?

    public private(set) var gauge: Gauge?

    public private(set) var url: URL?

    public private(set) var accessibility: Accessibility?

    public init(progress: Progress?) {
        metadataText = nil
        metadataSecondaryText = nil
        graphic = nil
        fallbacks = nil
        self.progress = progress
        gauge = nil
        url = nil
        accessibility = nil
    }

    public init(gauge: Gauge?) {
        metadataText = nil
        metadataSecondaryText = nil
        graphic = nil
        fallbacks = nil
        progress = nil
        self.gauge = gauge
        url = nil
        accessibility = nil
    }

    @available(*, deprecated)
    public init(fallbacks: [WidgetAuxiliaryViewMetadata]?) {
        metadataText = nil
        metadataSecondaryText = nil
        graphic = nil
        self.fallbacks = fallbacks
        progress = nil
        gauge = nil
        url = nil
        accessibility = nil
    }

    init(
        item: PlatformItemList.Item?,
        url: URL?,
        accessibility: Accessibility?,
        child: WidgetAuxiliaryViewMetadata?
    ) {
        metadataText = item?.text.map(Text.init) ?? child?.metadataText
        metadataSecondaryText = item?.secondaryText.map(Text.init) ?? child?.metadataSecondaryText
        graphic = item?.widgetAuxiliaryGraphic ?? child?.graphic
        fallbacks = item?.children?.items.map {
            WidgetAuxiliaryViewMetadata(
                item: $0,
                url: nil,
                accessibility: nil,
                child: nil
            )
        } ?? child?.fallbacks
        self.progress = child?.progress
        gauge = child?.gauge
        self.url = url ?? child?.url
        self.accessibility = accessibility ?? child?.accessibility
    }
}

// MARK: - TimeDataFormattingContainer

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension TimeDataFormattingContainer {
    public func representation(
        for version: _ArchivedViewStates.DeploymentVersion
    ) -> WidgetAuxiliaryViewMetadata.Text.Metadata.Kind? {
        let representation = representation(for: version.base)
        if let absoluteDate = representation as? ResolvableAbsoluteDate {
            return .dateAbsolute(absoluteDate.date, absoluteDate.style)
        }
        guard version >= .v6 else {
            return nil
        }
        return .timedata(self)
    }
}

// MARK: - WidgetAuxiliaryViewMetadata tint

@_spi(Private)
extension WidgetAuxiliaryViewMetadata {
    public var tint: Color? {
        resolvedTint.map(Color.init)
    }

    public var resolvedTint: Color.Resolved? {
        guard case let .named(named) = graphic else {
            return nil
        }
        return named._tintColor
    }
}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Gauge: Sendable {}

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
extension WidgetAuxiliaryViewMetadata.Accessibility: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Progress: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Progress.Kind: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Text: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Text.Metadata: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Text.Metadata.Kind: Sendable {}

// MARK: - WidgetAuxiliaryViewMetadata deprecated properties

@_spi(Private)
extension WidgetAuxiliaryViewMetadata {
    @available(*, deprecated, message: "Use metadataText instead")
    public var text: NSAttributedString? {
        metadataText?.text
    }

    #if os(macOS)
    @available(*, deprecated, message: "Use graphic instead")
    public var image: NSImage? {
        guard case let .image(image) = graphic else {
            return nil
        }
        return image
    }
    #elseif canImport(UIKit)
    @available(*, deprecated, message: "Use graphic instead")
    public var image: UIImage? {
        guard case let .image(image) = graphic else {
            return nil
        }
        return image
    }
    #else
    @available(*, deprecated, message: "Use graphic instead")
    public var image: NSObject? {
        guard case let .image(image) = graphic else {
            return nil
        }
        return image
    }
    #endif
}

// MARK: - WidgetAuxiliaryViewMetadata Codable

@_spi(Private)
extension WidgetAuxiliaryViewMetadata: Codable {}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Text: Codable {
    private enum CodingKeys: CodingKey {
        case text
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .text)
        guard let text = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSAttributedString else {
            throw DecodingError.dataCorruptedError(
                forKey: .text,
                in: container,
                debugDescription: "The archived value is not an NSAttributedString."
            )
        }
        self.text = text
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: text,
            requiringSecureCoding: false
        )
        try container.encode(data, forKey: .text)
    }
}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Graphic: Codable {
    private enum CodingKeys: CodingKey {
        case named
        case image
    }

    private enum Error: Swift.Error {
        case missingContent
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let named = try container.decodeIfPresent(Named.self, forKey: .named) {
            self = .named(named)
            return
        }
        if let data = try container.decodeIfPresent(Data.self, forKey: .image) {
            #if os(macOS)
            guard let image = NSImage(data: data) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .image,
                    in: container,
                    debugDescription: "The encoded data is not an NSImage."
                )
            }
            self = .image(image)
            #elseif canImport(UIKit)
            guard let image = UIImage(data: data) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .image,
                    in: container,
                    debugDescription: "The encoded data is not a UIImage."
                )
            }
            self = .image(image)
            #else
            throw Error.missingContent
            #endif
            return
        }
        throw Error.missingContent
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .named(named):
            try container.encode(named, forKey: .named)
        #if os(macOS)
        case let .image(image):
            guard let data = image.tiffRepresentation else {
                throw EncodingError.invalidValue(
                    image,
                    EncodingError.Context(
                        codingPath: encoder.codingPath,
                        debugDescription: "The NSImage does not have a TIFF representation."
                    )
                )
            }
            try container.encode(data, forKey: .image)
        #elseif canImport(UIKit)
        case let .image(image):
            guard let data = image.pngData() else {
                throw EncodingError.invalidValue(
                    image,
                    EncodingError.Context(
                        codingPath: encoder.codingPath,
                        debugDescription: "The UIImage does not have a PNG representation."
                    )
                )
            }
            try container.encode(data, forKey: .image)
        #else
        case let .image(image):
            throw EncodingError.invalidValue(
                image,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Platform images cannot be encoded on this platform."
                )
            )
        #endif
        }
    }
}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Graphic.Named: Codable {
    private enum CodingKeys: CodingKey {
        case name
        case location
        case value
        case isSymbol
        case _colors
        case _tintColor
        case _mode
        case _contentTransition
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            location: try container.decode(Location.self, forKey: .location),
            value: try container.decodeIfPresent(Float.self, forKey: .value),
            isSymbol: try container.decode(Bool.self, forKey: .isSymbol),
            colors: try container.decodeIfPresent([Color.Resolved].self, forKey: ._colors),
            tintColor: try container.decodeIfPresent(Color.Resolved.self, forKey: ._tintColor),
            mode: try container.decodeIfPresent(SymbolRenderingMode.Storage.self, forKey: ._mode),
            symbolEffects: [],
            contentTransition: .identity
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(location, forKey: .location)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encode(isSymbol, forKey: .isSymbol)
        try container.encodeIfPresent(_colors, forKey: ._colors)
        try container.encodeIfPresent(_tintColor, forKey: ._tintColor)
        try container.encodeIfPresent(_mode, forKey: ._mode)
    }
}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Graphic.Named.Location: Codable {}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Progress: Codable {
    private enum CodingKeys: CodingKey {
        case kind
        case labelBox
        case currentValueLabelBox
        case _tint
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(Kind.self, forKey: .kind)
        _labelBox = try container.decode(MutableBox<WidgetAuxiliaryViewMetadata?>.self, forKey: .labelBox)
        _currentValueLabelBox = try container.decode(MutableBox<WidgetAuxiliaryViewMetadata?>.self, forKey: .currentValueLabelBox)
        _tint = try container.decodeIfPresent(ResolvedGradient.self, forKey: ._tint)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(_labelBox, forKey: .labelBox)
        try container.encode(_currentValueLabelBox, forKey: .currentValueLabelBox)
        try container.encodeIfPresent(_tint, forKey: ._tint)
    }
}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Progress.Kind: Codable {}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Gauge: Codable {
    private enum CodingKeys: CodingKey {
        case value
        case labelBox
        case currentValueLabelBox
        case minimumValueLabelBox
        case maximumValueLabelBox
        case _tint
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Double.self, forKey: .value)
        _labelBox = try container.decode(MutableBox<WidgetAuxiliaryViewMetadata?>.self, forKey: .labelBox)
        _currentValueLabelBox = try container.decode(MutableBox<WidgetAuxiliaryViewMetadata?>.self, forKey: .currentValueLabelBox)
        _minimumValueLabelBox = try container.decode(MutableBox<WidgetAuxiliaryViewMetadata?>.self, forKey: .minimumValueLabelBox)
        _maximumValueLabelBox = try container.decode(MutableBox<WidgetAuxiliaryViewMetadata?>.self, forKey: .maximumValueLabelBox)
        _tint = try container.decodeIfPresent(ResolvedGradient.self, forKey: ._tint)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(_labelBox, forKey: .labelBox)
        try container.encode(_currentValueLabelBox, forKey: .currentValueLabelBox)
        try container.encode(_minimumValueLabelBox, forKey: .minimumValueLabelBox)
        try container.encode(_maximumValueLabelBox, forKey: .maximumValueLabelBox)
        try container.encodeIfPresent(_tint, forKey: ._tint)
    }
}

@_spi(Private)
extension WidgetAuxiliaryViewMetadata.Accessibility: Codable {}

extension MutableBox: Codable where T == WidgetAuxiliaryViewMetadata? {
    private enum CodingKeys: CodingKey {
        case value
    }

    package convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(try container.decodeIfPresent(WidgetAuxiliaryViewMetadata.self, forKey: .value))
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

// MARK: - WidgetAuxiliaryViewMetadata Equatable

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic.Named.Location: Equatable {}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic.Named: Equatable {}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension WidgetAuxiliaryViewMetadata.Graphic: Equatable {}

// MARK: - WidgetAuxiliaryViewMetadata.Key

@_spi(Private)
extension WidgetAuxiliaryViewMetadata {
    public struct Key: HostPreferenceKey {
        public static var defaultValue: WidgetAuxiliaryViewMetadata?

        public static func reduce(
            value: inout WidgetAuxiliaryViewMetadata?,
            nextValue: () -> WidgetAuxiliaryViewMetadata?
        ) {
            value = WidgetAuxiliaryViewMetadata.reduce(value, nextValue())
        }

        public typealias Value = WidgetAuxiliaryViewMetadata?
    }

    public static func reduce(
        _ lhs: WidgetAuxiliaryViewMetadata?,
        _ rhs: WidgetAuxiliaryViewMetadata?
    ) -> WidgetAuxiliaryViewMetadata? {
        guard var result = lhs else {
            return rhs
        }
        guard let rhs else {
            return result
        }
        result.graphic = rhs.graphic ?? result.graphic
        result.fallbacks = rhs.fallbacks ?? result.fallbacks
        result.metadataText = rhs.metadataText ?? result.metadataText
        result.accessibility = rhs.accessibility ?? result.accessibility
        return result
    }
}

@_spi(Private)
@available(*, unavailable)
extension WidgetAuxiliaryViewMetadata.Key: Sendable {}

extension WidgetAuxiliaryViewMetadata {
    static func tint(from environment: EnvironmentValues) -> ResolvedGradient? {
        guard let tint = environment.tint else {
            return nil
        }
        if let gradient = tint.resolveGradient(in: environment) {
            return gradient
        }
        guard let color = tint.fallbackColor(in: environment) else {
            return nil
        }
        return Gradient(colors: [color]).resolve(in: environment)
    }
}

// MARK: - PlatformItemList.Item metadata conversion

private extension PlatformItemList.Item {
    var widgetAuxiliaryGraphic: WidgetAuxiliaryViewMetadata.Graphic? {
        if let namedResolvedImage {
            return .named(
                WidgetAuxiliaryViewMetadata.Graphic.Named(
                    namedResolvedImage,
                    resolvedImage
                )
            )
        }
        #if os(macOS)
        if let image = resolvedImage?.basePlatformItemImage as? NSImage {
            return .image(image)
        }
        if let resolvedImage, case let .cgImage(image) = resolvedImage.image.contents {
            return .image(NSImage(cgImage: image, size: resolvedImage.image.size))
        }
        #elseif canImport(UIKit)
        if let image = resolvedImage?.basePlatformItemImage as? UIImage {
            return .image(image)
        }
        if let resolvedImage, case let .cgImage(image) = resolvedImage.image.contents {
            return .image(UIImage(cgImage: image, scale: resolvedImage.image.scale, orientation: .up))
        }
        #endif
        return nil
    }
}

extension PreferencesInputs {
    @inline(__always)
    func containsWidgetAuxiliaryViewMetadata() -> Bool {
        contains(WidgetAuxiliaryViewMetadata.Key.self)
    }
}

// MARK: - Widget auxiliary text and image metadata

struct WidgetAuxiliaryTextImagePreference {
    var list: PlatformItemList?
}

struct LazyWidgetAuxiliaryMetadataTextImage<Content>: StatefulRule where Content: View {
    let subgraph: Subgraph
    @Attribute var content: Content
    let inputs: _ViewInputs
    @OptionalAttribute var textImagePref: WidgetAuxiliaryTextImagePreference??

    init(
        flags _: AnyAttribute.Flags.Type,
        content: Attribute<Content>,
        inputs: _ViewInputs
    ) {
        subgraph = Subgraph.current!
        _content = content
        self.inputs = inputs
        _textImagePref = OptionalAttribute()
    }

    typealias Value = WidgetAuxiliaryTextImagePreference?

    static var initialValue: WidgetAuxiliaryTextImagePreference?? { nil }

    mutating func updateValue() {
        if $textImagePref == nil {
            _textImagePref = subgraph.apply {
                makeTextImage()
            }
        }
        value = textImagePref ?? nil
    }

    private func makeTextImage() -> OptionalAttribute<WidgetAuxiliaryTextImagePreference?> {
        var inputs = inputs
        inputs.addPlatformItemListKey(
            flags: WidgetMetadataPlatformItemListFlags.self,
            editOperation: .replace
        )
        let outputs = Content.makeDebuggableView(
            view: _GraphValue($content),
            inputs: inputs
        )
        return OptionalAttribute(
            Attribute(
                WidgetAuxiliaryMetadataTextImageWriter(
                    list: WeakAttribute(outputs.preferences.platformItemList)
                )
            )
        )
    }
}

private struct WidgetAuxiliaryMetadataTextImageWriter: Rule, AsyncAttribute {
    @WeakAttribute var list: PlatformItemList?

    var value: WidgetAuxiliaryTextImagePreference? {
        list.map { WidgetAuxiliaryTextImagePreference(list: $0) }
    }
}
