//
//  ShapeStylePack.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4DBF651155A4B32ED86C55EAB1B96C61 (SwiftUICore)

package import Foundation

package struct _ShapeStyle_Pack: Equatable {
    package struct Style: Equatable, Sendable {
        package var fill: _ShapeStyle_Pack.Fill
        package var opacity: Float
        package private(set) var _blend: GraphicsBlendMode?

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
    }
    
    package enum Fill: Equatable, Sendable {
        case color(Color.Resolved)
        case paint(AnyResolvedPaint)
        case foregroundMaterial(Color.Resolved, ContentStyle.MaterialStyle)
        case backgroundMaterial(Material.ResolvedMaterial)
        case vibrantColor(Color.ResolvedVibrant)
        case vibrantMatrix(_ColorMatrix)
        case multicolor(ResolvedMulticolorStyle)
    }
    
    package struct Effect: Equatable, Sendable {
        package enum Kind: Equatable, Sendable {
            case none
            case shadow(ResolvedShadowStyle)
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
    
    private var styles: [(key: Key, style: Style)]

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

    private func indices(of name: ShapeStyle.Name) -> Range<Int> {
        let count = styles.count
        guard count != 0 else { return 0 ..< 0 }
        var start = 0
        while start < count && styles[start].key.name != name {
            start += 1
        }
        guard start < count else { return count ..< count }
        var end = start
        while end < count && styles[end].key.name == name {
            end += 1
        }
        return start ..< end
    }

    package subscript(name: _ShapeStyle_Name) -> _ShapeStyle_Pack.Slice {
        Slice(pack: self, name: name)
    }
    
    package struct Slice: RandomAccessCollection {
        var styles: ArraySlice<(key: Key, style: Style)>
        var baseLevel: UInt8
        
        init(pack: _ShapeStyle_Pack, name: _ShapeStyle_Name) {
            let range = pack.indices(of: name)
            self.styles = pack.styles[range]
            if range.isEmpty {
                self.baseLevel = 0
            } else {
                self.baseLevel = pack.styles[range.lowerBound].key._level
            }
        }
        
        package var startIndex: Int {
            Int(baseLevel)
        }
        
        package var endIndex: Int {
            Int(baseLevel) + styles.count
        }
        
        package subscript(level: Int) -> _ShapeStyle_Pack.Style {
            let offset = level - Int(baseLevel)
            return styles[styles.startIndex + offset].style
        }
    }
    
    package mutating func modify(
        name: ShapeStyle.Name,
        levels: Range<Int>,
        _ modifier: (inout ShapeStyle.Pack.Style) -> Void
    ) {
        let indices = indices(of: name)
        guard !indices.isEmpty else { return }
        var modifiedStyles = styles
        for index in indices {
            if levels.contains(modifiedStyles[index].key.level) {
                modifier(&modifiedStyles[index].style)
            }
        }
        styles = modifiedStyles
    }
    
    package mutating func adjustLevelIndices(of name: _ShapeStyle_Name, by offset: Int) {
        guard !styles.isEmpty else { return }
        var i = 0
        while i < styles.count {
            let currentName = styles[i].key.name
            guard currentName >= name else {
                i += 1
                continue
            }
            guard currentName <= name else {
                break
            }
            let newLevel = styles[i].key.level + offset
            if newLevel >= 0 {
                styles[i].key.level = newLevel
                i += 1
            } else {
                styles.remove(at: i)
            }
        }
    }
    
    package mutating func createOpacities(count: Int, name: _ShapeStyle_Name, environment: EnvironmentValues) {
        let range = indices(of: name)
        guard range.count == 1, count >= 2 else { return }
        let baseIndex = range.lowerBound
        let baseStyle = styles[baseIndex]
        let opacityFunc = environment.systemColorDefinition.base.opacity
        for i in 1 ..< count {
            let factor = opacityFunc(i, environment)
            var newStyle = baseStyle.style
            newStyle.opacity *= factor
            for j in newStyle.effects.indices {
                newStyle.effects[j].opacity *= factor
            }
            styles.insert(
                (key: Key(name, i), style: newStyle),
                at: baseIndex + i
            )
        }
    }
    
    package func isClear(name: _ShapeStyle_Name) -> Bool {
        for element in styles {
            guard element.key.name == name else { continue }
            guard element.style.isClear else { return false }
        }
        return true
    }
    
    package subscript(colorName: String) -> Color.Resolved? {
        let style = self[.multicolor, 0]
        guard case let .multicolor(resolved) = style.fill else {
            return nil
        }
        return resolved.resolve(name: colorName)
    }
}

extension _ShapeStyle_Pack.Slice {
    package var allColors: Bool {
        for element in styles {
            let style = element.style
            switch style.fill {
            case .color:
                guard style.blend == .normal else { return false }
                guard style.effects.isEmpty else { return false }
            case .multicolor:
                continue
            default:
                return false
            }
        }
        return true
    }
}

extension _ShapeStyle_Pack.Style {
    package var isClear: Bool {
        guard opacity != 0 else { return true }
        switch fill {
        case let .color(resolved):
            guard resolved.opacity == 0 else { return false }
        case let .paint(paint):
            guard paint.isClear else { return false }
        case let .foregroundMaterial(resolved, _):
            guard resolved.opacity == 0 else { return false }
        default:
            return false
        }
        for effect in effects {
            switch effect.kind {
            case .none:
                continue
            case .shadow:
                guard effect.opacity == 0 else { return false }
                continue
            }
        }
        return true
    }
    
    package var ignoresBackdrop: Bool {
        guard opacity == 1.0 else { return false }
        guard blend == .normal else { return false }
        switch fill {
        case let .color(resolved):
            return resolved.opacity == 1.0
        case let .paint(paint):
            return paint.isOpaque
        default:
            return false
        }
    }
    
    package mutating func applyOpacity(_ opacity: Float) {
        self.opacity *= opacity
        for i in effects.indices {
            effects[i].opacity *= opacity
        }
    }
    
    package func applyingOpacity(_ opacity: Float) -> _ShapeStyle_Pack.Style {
        var copy = self
        copy.applyOpacity(opacity)
        return copy
    }
    
    package mutating func applyBlend(_ blend: GraphicsBlendMode) {
        let shouldApply = !_SemanticFeature_v6.isEnabled
        if shouldApply || _blend == nil {
            _blend = blend
        }
        for index in effects.indices {
            if shouldApply || effects[index]._blend == nil {
                effects[index]._blend = blend
            }
        }
    }

    package var color: Color.Resolved? {
        guard case let .color(resolved) = fill else { return nil }
        guard blend == .normal else { return nil }
        guard effects.isEmpty else { return nil }
        return resolved
    }
}

// TODO: _ShapeStyle_Pack + Animatable

extension ShapeStyle.Pack: Animatable {}

// MARK: - _ShapeStyle_Shape + _ShapeStyle_Pack

extension _ShapeStyle_Shape {
    package var stylePack: ShapeStyle.Pack {
        get {
            switch result {
                case let .pack(pack): pack
                default: .defaultValue
            }
        }
        _modify {
            var styles: ShapeStyle.Pack
            switch result {
            case let .pack(pack):
                styles = pack
                result = .none
            default:
                styles = .defaultValue
            }
            yield &styles
            result = .pack(styles)
        }
    }
}
