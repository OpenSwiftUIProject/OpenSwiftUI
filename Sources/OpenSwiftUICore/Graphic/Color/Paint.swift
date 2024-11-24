//
//  Paint.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by Gradient, Image and Shader

package import Foundation

// MARK: - ResolvedPaint

package protocol ResolvedPaint: Equatable, Animatable, ProtobufEncodableMessage {
    func draw(path: Path, style: PathDrawingStyle, in context: GraphicsContext, bounds: CGRect?)
    var isClear: Bool { get }
    var isOpaque: Bool { get }
    var resolvedGradient: ResolvedGradient? { get }
    var isCALayerCompatible: Bool { get }
    static var leafProtobufTag: CodableResolvedPaint.Tag? { get }
    func encodePaint(to encoder: inout ProtobufEncoder) throws
}

// MARK: - ResolvedPaint + Default Implementations

extension ResolvedPaint {
    package var isClear: Bool { false }
    package var isOpaque: Bool { false }
    package var resolvedGradient: ResolvedGradient? { nil }
    package var isCALayerCompatible: Bool { true }
    package func encodePaint(to encoder: inout ProtobufEncoder) throws {
        if let tag = Self.leafProtobufTag {
            try encoder.messageField(tag.rawValue, self)
        } else {
            try encode(to: &encoder)
        }
    }
}

// MARK: - AnyResolvedPaint

package class AnyResolvedPaint: Equatable {
    package func draw(path: Path, style: PathDrawingStyle, in ctx: GraphicsContext, bounds: CGRect?) {}
    package var protobufPaint: Any? { nil }
    package var isClear: Bool { false }
    package var isOpaque: Bool { false }
    package var resolvedGradient: ResolvedGradient? { nil }
    package var isCALayerCompatible: Bool { false }
    package func isEqual(to other: AnyResolvedPaint) -> Bool { false }
    package func visit<V>(_ visitor: inout V) where V : ResolvedPaintVisitor {}
    package func encode(to encoder: any Encoder) throws { preconditionFailure("") }
    package func encode(to encoder: inout ProtobufEncoder) throws { preconditionFailure("") }
    package static func == (lhs: AnyResolvedPaint, rhs: AnyResolvedPaint) -> Bool { lhs.isEqual(to: rhs) }
}

// MARK: - _AnyResolvedPaint

final package class _AnyResolvedPaint<P>: AnyResolvedPaint where P: ResolvedPaint {
    package let paint: P
    package init(_ paint: P) {
        self.paint = paint
    }
    
    override package func draw(path: Path, style: PathDrawingStyle, in ctx: GraphicsContext, bounds: CGRect?) {
        paint.draw(path: path, style: style, in: ctx, bounds: bounds)
    }
    
    override package var protobufPaint: Any? {
        paint
    }
    
    override package var isClear: Bool {
        paint.isClear
    }
    
    override package var isOpaque: Bool {
        paint.isOpaque
    }
    
    override package var resolvedGradient: ResolvedGradient? {
        paint.resolvedGradient
    }
    
    override package var isCALayerCompatible: Bool {
        paint.isCALayerCompatible
    }
    
    override package func isEqual(to other: AnyResolvedPaint) -> Bool {
        guard let other = other as? _AnyResolvedPaint<P> else {
            return false
        }
        return self == other
    }
    
    override package func visit<V>(_ visitor: inout V) where V : ResolvedPaintVisitor {
        visitor.visitPaint(paint)
    }
    
    override package func encode(to encoder: inout ProtobufEncoder) throws {
        try paint.encodePaint(to: &encoder)
    }
}

// FIXME
extension AnyResolvedPaint: @unchecked Sendable {}
extension _AnyResolvedPaint: @unchecked Sendable {}

// MARK: - ResolvedPaintVisitor

package protocol ResolvedPaintVisitor {
    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint
}

// MARK: - CodableResolvedPaint [TODO]

package struct CodableResolvedPaint: ProtobufMessage  {
    package struct Tag: Equatable, ProtobufTag {
        package let rawValue: UInt

        package init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        package static let color: CodableResolvedPaint.Tag = .init(rawValue: 1)
        package static let linearGradient: CodableResolvedPaint.Tag = .init(rawValue: 2)
        package static let radialGradient: CodableResolvedPaint.Tag = .init(rawValue: 3)
        package static let angularGradient: CodableResolvedPaint.Tag = .init(rawValue: 4)
        package static let ellipticalGradient: CodableResolvedPaint.Tag = .init(rawValue: 5)
        package static let image: CodableResolvedPaint.Tag = .init(rawValue: 6)
        package static let anchorRect: CodableResolvedPaint.Tag = .init(rawValue: 7)
        package static let shader: CodableResolvedPaint.Tag = .init(rawValue: 8)
        package static let meshGradient: CodableResolvedPaint.Tag = .init(rawValue: 9)
    }

    package var base: AnyResolvedPaint
    
    package init(_ paint: AnyResolvedPaint) {
        base = paint
    }
    
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try base.encode(to: &encoder)
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var base: AnyResolvedPaint?
        while let field = try decoder.nextField() {
            switch field.tag {
                case Tag.color.rawValue:
                    let color: Color.Resolved = try decoder.messageField(field)
                    base = _AnyResolvedPaint(color)
                case Tag.linearGradient.rawValue:
                    break // TODO
                case Tag.radialGradient.rawValue:
                    break // TODO
                case Tag.angularGradient.rawValue:
                    break // TODO
                case Tag.ellipticalGradient.rawValue:
                    break // TODO
                case Tag.image.rawValue:
                    break // TODO
                case Tag.anchorRect.rawValue:
                    break // TODO
                case Tag.shader.rawValue:
                    break // TODO
                case Tag.meshGradient.rawValue:
                    break // TODO
                default:
                    try decoder.skipField(field)
            }
        }
        if let base {
            self.init(base)
        } else {
            throw ProtobufDecoder.DecodingError.failed
        }
    }
}
