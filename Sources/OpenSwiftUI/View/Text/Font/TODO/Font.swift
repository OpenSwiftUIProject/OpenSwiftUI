#if canImport(Darwin)
import CoreGraphics
#else
import Foundation
#endif

@frozen
public struct Font: Hashable {
    @usableFromInline
    var provider: AnyFontBox

    @inline(__always)
    init(storage: AnyFontBox) {
        provider = storage
    }

    @inline(__always)
    init(provider: some FontProvider) {
        self.init(storage: FontBox(provider: provider))
    }

    @inline(__always)
    public static func == (lhs: Font, rhs: Font) -> Bool {
        lhs.provider == rhs.provider
    }

    // FIXME
    public static let body = Font(provider: TextStyleProvider(textStyle: .body, design: .default))
}

@usableFromInline
class AnyFontBox: Hashable {
    @usableFromInline
    func hash(into _: inout Hasher) {
        fatalError()
    }

    @usableFromInline
    static func == (_: AnyFontBox, _: AnyFontBox) -> Bool {
        fatalError()
    }
}

private class FontBox<P: FontProvider>: AnyFontBox, FontProvider {
    fileprivate typealias Provider = P

    private let _provider: Provider

    fileprivate init(provider: Provider) {
        _provider = provider
    }
}

protocol FontProvider: Hashable {}

extension Font {
    public enum Design: Hashable {
        case `default`
    }

    @frozen
    public struct Weight: Hashable {
        var value: CGFloat
        public static let regular: Weight = .init(value: 0)

        public static let semibold: Weight = .init(value: 0.3)
    }

    struct TextStyleProvider: FontProvider {
        private let textStyle: TextStyle
        private let design: Design
        private let weight: Weight?

        @inline(__always)
        init(textStyle: TextStyle, design: Design, weight: Weight? = nil) {
            self.textStyle = textStyle
            self.design = design
            self.weight = weight
        }
    }
}

extension Font {
    public enum TextStyle: Hashable, CaseIterable {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption
        case caption2
    }
}

