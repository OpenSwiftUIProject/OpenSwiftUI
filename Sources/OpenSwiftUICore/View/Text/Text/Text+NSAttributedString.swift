//
//  Text+NSAttributedString.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import UIFoundation_Private

#if !canImport(Darwin)
class NSParagraphStyle {}
class NSMutableParagraphStyle {}
#endif

package func makeParagraphStyle(environment: EnvironmentValues) -> NSMutableParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    #if canImport(Darwin)
    // TODO
    #endif
    return paragraphStyle
}

#if canImport(CoreText)
@_silgen_name("kCTUIFontTextStyleTitle0")
let kCTTextScaleRatioAttributeName: CFString
#endif

extension NSAttributedString.Key {
    package static let resolvableAttributeConfiguration: NSAttributedString.Key = .init("OpenSwiftUI.resolvableAttributeConfiguration")

    package static let _textScale: NSAttributedString.Key = .init("NSTextScale")

    #if canImport(CoreText)
    package static let _textScaleRatio: NSAttributedString.Key = .init(kCTTextScaleRatioAttributeName as String)
    #endif

    package static let _textScaleStaticWeightMatching: NSAttributedString.Key = .init("NSTextScaleStaticWeightMatching")
}

extension NSAttributedString {
    package func firstAttribute<T>(_ type: T.Type) -> T? where T: ResolvableStringAttribute {
        _openSwiftUIUnimplementedFailure()
    }
}

extension NSMutableAttributedString {
    package func addResolvableAttributes(with config: ResolvableAttributeConfiguration) {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolveAttributes(in context: ResolvableStringResolutionContext) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text {
    package func resolveAttributedString(
        in environment: EnvironmentValues,
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = [.includeSupportForRepeatedResolution],
        idiom: AnyInterfaceIdiom? = nil
    ) -> NSAttributedString? {
        _openSwiftUIUnimplementedFailure()
    }

    package func resolveAttributedStringAndProperties(
        in environment: EnvironmentValues,
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = [.includeSupportForRepeatedResolution],
        idiom: AnyInterfaceIdiom? = nil
    ) -> (NSAttributedString?, Text.ResolvedProperties) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension EnvironmentValues {
    package func resolveNSAttributes(
        includeDefaultAttributes: Bool = true,
        options: Text.ResolveOptions = []
    ) -> [NSAttributedString.Key: Any] {
        _openSwiftUIUnimplementedFailure()
    }
}

extension NSAttributedString {
    package func scaled(by factor: CGFloat) -> NSAttributedString {
        guard factor != 1.0 else {
            return self
        }
        #if canImport(Darwin)
        return _ui_attributedSubstring(
            from: NSRange(location: 0, length: length),
            scaledBy: factor
        )
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return self
        #endif
    }

    package struct EncodedFontMetrics {
        package var capHeight: CGFloat, ascender: CGFloat, descender: CGFloat, leading: CGFloat
        package var outsets: EdgeInsets
    }

    package var maxFontMetrics: EncodedFontMetrics {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text.Style {
    package func nsAttributes(
        content: (() -> String)?,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        with options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> [NSAttributedString.Key: Any] {
        _openSwiftUIUnimplementedFailure()
    }
}
