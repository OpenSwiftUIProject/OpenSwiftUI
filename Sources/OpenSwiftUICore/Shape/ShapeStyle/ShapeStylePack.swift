//
//  ShapeStylePack.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by other ShapeStyle and Animatable
//  ID: 4DBF651155A4B32ED86C55EAB1B96C61 (SwiftUICore)

package struct _ShapeStyle_Pack: Equatable {
    package struct Style: Equatable, Sendable {
        package var fill: _ShapeStyle_Pack.Fill
        package var opacity: Float
        package var _blend: GraphicsBlendMode?
        
        package var blend: GraphicsBlendMode {
            _blend ?? .normal
        }

        package var effects: [_ShapeStyle_Pack.Effect]
        
        package init(_ fill: _ShapeStyle_Pack.Fill) {
            self.fill = fill
            self.opacity = 1.0
            self._blend = nil
            self.effects = []
        }
        
        package static let clear: _ShapeStyle_Pack.Style = .init(.color(.clear))
        package static func == (a: _ShapeStyle_Pack.Style, b: _ShapeStyle_Pack.Style) -> Bool {
            a.fill == b.fill && a.opacity == b.opacity && a._blend == b._blend && a.effects == b.effects
        }
    }
    
    package enum Fill: Equatable, Sendable {
        case color(Color.Resolved)
        case paint(AnyResolvedPaint)
        case foregroundMaterial(Color.Resolved/*, ContentStyle.MaterialStyle*/)
        // case backgroundMaterial(Material.ResolvedMaterial)
        case vibrantColor(Color.ResolvedVibrant)
        case vibrantMatrix(_ColorMatrix)
        // case multicolor(ResolvedMulticolorStyle)
        package static func == (a: _ShapeStyle_Pack.Fill, b: _ShapeStyle_Pack.Fill) -> Bool {
            switch (a, b) {
                case (.color(let a), .color(let b)): return a == b
                case (.paint(let a), .paint(let b)): return a == b
                // case (.foregroundMaterial(let a), .foregroundMaterial(let b)): return a == b
                case (.vibrantColor(let a), .vibrantColor(let b)): return a == b
                case (.vibrantMatrix(let a), .vibrantMatrix(let b)): return a == b
                // case (.multicolor(let a), .multicolor(let b)): return a == b
                default: return false
            }
        }
    }
    
    package struct Effect: Equatable, Sendable {
        package enum Kind: Equatable, Sendable {
            case none
            // case shadow(ResolvedShadowStyle)
            // package static func == (a: _ShapeStyle_Pack.Effect.Kind, b: _ShapeStyle_Pack.Effect.Kind) -> Bool
        }

        package var kind: _ShapeStyle_Pack.Effect.Kind
        package var opacity: Float
        package var _blend: GraphicsBlendMode?
        package var blend: GraphicsBlendMode {
            _blend ?? .normal
        }
        
        package static func == (a: _ShapeStyle_Pack.Effect, b: _ShapeStyle_Pack.Effect) -> Bool {
            a.kind == b.kind && a.opacity == b.opacity && a._blend == b._blend
        }
    }
        
    package struct Key: Comparable {
        package var name: _ShapeStyle_Name
        var _level: UInt8
        
        package init(_ name: _ShapeStyle_Name, _ level: Int) {
            self.name = name
            self._level = UInt8(level)
        }
        
        package var level: Int {
            get { Int(bitPattern: UInt(_level)) } // FIXME
            set { _level = UInt8(truncatingIfNeeded: newValue) }
        }
        
        package static func < (lhs: _ShapeStyle_Pack.Key, rhs: _ShapeStyle_Pack.Key) -> Bool {
            lhs.name < rhs.name || (lhs.name == rhs.name && lhs._level < rhs._level)
        }
        
        package static func == (a: _ShapeStyle_Pack.Key, b: _ShapeStyle_Pack.Key) -> Bool {
            a.name == b.name && a._level == b._level
        }
    }
    
    var styles: [(key: Key, style: Style)]
    
    package init() {
        styles = []
    }
    
    package static func style(_ style: _ShapeStyle_Pack.Style, name: _ShapeStyle_Name, level: Int = 0) -> _ShapeStyle_Pack {
        var pack = _ShapeStyle_Pack()
        pack.styles = [(key: Key(name, level), style: style)]
        return pack
    }
    
    package static func fill(_ fill: _ShapeStyle_Pack.Fill, name: _ShapeStyle_Name, level: Int = 0) -> _ShapeStyle_Pack {
        var pack = _ShapeStyle_Pack()
        pack.styles = [(key: Key(name, level), style: .init(fill))]
        return pack
    }
    
    package static func == (lhs: _ShapeStyle_Pack, rhs: _ShapeStyle_Pack) -> Bool {
        lhs.styles.elementsEqual(rhs.styles) { $0.key == $1.key && $0.style == $1.style }
    }
    
    package static let defaultValue: _ShapeStyle_Pack = .init()
    
    package subscript(name: _ShapeStyle_Name, level: Int) -> _ShapeStyle_Pack.Style {
        get {
            styles.first { $0.key.name == name && $0.key.level == level }?.style ?? _ShapeStyle_Pack.Style.clear
        }
        set {
            if let index = styles.firstIndex(where: { $0.key.name == name && $0.key.level == level }) {
                styles[index].style = newValue
            } else {
                styles.append((key: Key(name, level), style: newValue))
            }
        }
    }
    
    package subscript(name: _ShapeStyle_Name) -> _ShapeStyle_Pack.Slice {
        Slice(pack: self, name: name)
    }
    
    package struct Slice: RandomAccessCollection {
        var styles: ArraySlice<(key: Key, style: Style)>
        var baseLevel: UInt8
        
        init(pack: _ShapeStyle_Pack, name: _ShapeStyle_Name) {
            preconditionFailure("TODO")
        }
        
        package var startIndex: Int {
            styles.startIndex
        }
        
        package var endIndex: Int {
            preconditionFailure("TODO")
        }
        
        package subscript(level: Int) -> _ShapeStyle_Pack.Style {
            preconditionFailure("TODO")
        }
    }
    
    package mutating func modify(name: _ShapeStyle_Name, levels: Range<Int>, _ modifier: (inout _ShapeStyle_Pack.Style) -> Void) {
        preconditionFailure("TODO")
    }
    
    package mutating func adjustLevelIndices(of name: _ShapeStyle_Name, by offset: Int) {
        preconditionFailure("TODO")
    }
    
    package mutating func createOpacities(count: Int, name: _ShapeStyle_Name, environment: EnvironmentValues) {
        preconditionFailure("TODO")
    }
    
    package func isClear(name: _ShapeStyle_Name) -> Bool {
        preconditionFailure("TODO")
    }
    
    package subscript(colorName: String) -> Color.Resolved? {
        preconditionFailure("TODO")
    }
}

extension _ShapeStyle_Pack.Slice {
    package var allColors: Bool {
        preconditionFailure("TODO")
    }
}

extension _ShapeStyle_Pack.Style {
    package var isClear: Bool {
        if opacity == 0 {
            return true
        } else {
            switch fill {
                // TODO
                default: return false
            }
        }
    }
    
    package var ignoresBackdrop: Bool {
        preconditionFailure("TODO")
    }
    
    package mutating func applyOpacity(_ opacity: Float) {
        preconditionFailure("TODO")
    }
    
    package func applyingOpacity(_ opacity: Float) -> _ShapeStyle_Pack.Style {
        preconditionFailure("TODO")
    }
    
    package mutating func applyBlend(_ blend: GraphicsBlendMode) {
        preconditionFailure("TODO")
    }
    
    package var color: Color.Resolved? {
        preconditionFailure("TODO")
    }
}

// TODO: _ShapeStyle_Pack + Animatable

// MARK: - _ShapeStyle_Shape + _ShapeStyle_Pack

extension _ShapeStyle_Shape {
    package var stylePack: _ShapeStyle_Pack {
        get {
            switch result {
                case let .pack(pack): pack
                default: .defaultValue
            }
        }
        _modify {
            var pack = stylePack
            yield &pack
            result = .pack(pack)
        }
    }
}
