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

    // FIXME
    public enum Graphic {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        case image(NSImage)
        #elseif canImport(UIKit)
        case image(UIImage)
        #else
        case image(NSObject)
        #endif
    }

    public private(set) var metadataText: WidgetAuxiliaryViewMetadata.Text?

    @available(OpenSwiftUI_v5_0, *)
    public private(set) var metadataSecondaryText: WidgetAuxiliaryViewMetadata.Text?

    public private(set) var graphic: WidgetAuxiliaryViewMetadata.Graphic?
}

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
@available(OpenSwiftUI_v4_0, *)
extension WidgetAuxiliaryViewMetadata: Codable {
    public func encode(to encoder: any Encoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    public init(from decoder: any Decoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}
