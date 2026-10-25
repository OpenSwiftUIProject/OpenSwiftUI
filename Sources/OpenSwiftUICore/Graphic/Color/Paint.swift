//
//  Paint.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by ImagePaint, Shader, and MeshGradient)
//  ID: 1A0B37DF690543DA63A8C3A51910F39C (SwiftUICore)

package import Foundation

// MARK: - Paint

protocol Paint: ShapeStyle {
    associatedtype ResolvedPaintType: ResolvedPaint

    func resolvePaint(in environment: EnvironmentValues) -> ResolvedPaintType

    func fallbackColor(in environment: EnvironmentValues) -> Color?
}

extension Paint {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            guard let level = levels.first else { return }
            let resolvedPaint = resolvePaint(in: shape.environment)
            let paint: AnyResolvedPaint
            if let bounds = shape.bounds {
                paint = _AnyResolvedPaint(AnchoredResolvedPaint(resolvedPaint, bounds: bounds))
            } else {
                paint = _AnyResolvedPaint(resolvedPaint)
            }
            var style = _ShapeStyle_Pack.Style(.paint(paint))
            style.applyOpacity(shape.opacity(at: level))
            shape.stylePack[name, level] = style
        case .fallbackColor:
            guard let color = fallbackColor(in: shape.environment) else { return }
            shape.result = .color(color)
        default:
            break
        }
    }
}

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
    package func draw(path: Path, style: PathDrawingStyle, in ctx: GraphicsContext, bounds: CGRect?) {
        _openSwiftUIEmptyStub()
    }

    package var protobufPaint: Any? { nil }

    package var isClear: Bool { false }

    package var isOpaque: Bool { false }

    package var resolvedGradient: ResolvedGradient? { nil }

    package var isCALayerCompatible: Bool { false }

    package func isEqual(to other: AnyResolvedPaint) -> Bool { false }

    package func visit<V>(_ visitor: inout V) where V: ResolvedPaintVisitor {
        _openSwiftUIEmptyStub()
    }

    package func encode(to encoder: any Encoder) throws {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package static func == (lhs: AnyResolvedPaint, rhs: AnyResolvedPaint) -> Bool { lhs.isEqual(to: rhs) }

    final func `as`<P>(type: P.Type) -> P? where P: ResolvedPaint {
        (self as? _AnyResolvedPaint<P>).map { $0.paint }
    }

    fileprivate final func anchorRect(_ rect: CGRect) -> AnyResolvedPaint {
        struct Visitor: ResolvedPaintVisitor {
            var rect: CGRect
            var wrapped: AnyResolvedPaint?

            mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
                wrapped = _AnyResolvedPaint(AnchoredResolvedPaint(paint, bounds: rect))
            }
        }

        var visitor = Visitor(rect: rect)
        visit(&visitor)
        return visitor.wrapped!
    }
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
        return paint == other.paint
    }
    
    override package func visit<V>(_ visitor: inout V) where V: ResolvedPaintVisitor {
        visitor.visitPaint(paint)
    }
    
    override package func encode(to encoder: inout ProtobufEncoder) throws {
        try paint.encodePaint(to: &encoder)
    }
}

// MARK: - ResolvedPaintVisitor

package protocol ResolvedPaintVisitor {
    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint
}

// MARK: - CodableResolvedPaint [WIP: ImagePaint, Shader, MeshGradient]

package struct CodableResolvedPaint: ProtobufMessage {
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
                    let paint: LinearGradient._Paint = try decoder.messageField(field)
                    base = _AnyResolvedPaint(paint)
                case Tag.radialGradient.rawValue:
                    let paint: RadialGradient._Paint = try decoder.messageField(field)
                    base = _AnyResolvedPaint(paint)
                case Tag.angularGradient.rawValue:
                    let paint: AngularGradient._Paint = try decoder.messageField(field)
                    base = _AnyResolvedPaint(paint)
                case Tag.ellipticalGradient.rawValue:
                    let paint: EllipticalGradient._Paint = try decoder.messageField(field)
                    base = _AnyResolvedPaint(paint)
                case Tag.image.rawValue:
                    // TODO: Decode ImagePaint._Paint.
                    _openSwiftUIUnimplementedFailure()
                case Tag.anchorRect.rawValue:
                    let rect: CGRect = try decoder.messageField(field)
                    base = base?.anchorRect(rect)
                case Tag.shader.rawValue:
                    // TODO: Decode Shader.ResolvedShader.
                    _openSwiftUIUnimplementedFailure()
                case Tag.meshGradient.rawValue:
                    // TODO: Decode MeshGradient._Paint.
                    _openSwiftUIUnimplementedFailure()
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
