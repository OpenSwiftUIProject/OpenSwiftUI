//
//  ShapeStylePack.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete - Blocked by Gradient and Shader
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

// [Animatable support] [Generated]

// MARK: - _ShapeStyle_Pack + Animatable

extension _ShapeStyle_Pack: Animatable {
    package struct AnimatableData: VectorArithmetic {
        package typealias StyleData = _ShapeStyle_Pack.Style.AnimatableData

        package typealias Element = (key: _ShapeStyle_Pack.Key, data: StyleData)

        package var elements: [Element]

        package static func == (lhs: _ShapeStyle_Pack.AnimatableData, rhs: _ShapeStyle_Pack.AnimatableData) -> Bool {
            guard lhs.elements.count == rhs.elements.count else { return false }
            for i in lhs.elements.indices {
                guard lhs.elements[i].key == rhs.elements[i].key else { return false }
                guard lhs.elements[i].data == rhs.elements[i].data else { return false }
            }
            return true
        }

        package static var zero: _ShapeStyle_Pack.AnimatableData {
            AnimatableData(elements: [])
        }

        package static func += (lhs: inout _ShapeStyle_Pack.AnimatableData, rhs: _ShapeStyle_Pack.AnimatableData) {
            guard !rhs.elements.isEmpty else { return }
            guard !lhs.elements.isEmpty else {
                lhs = rhs
                return
            }
            var li = 0
            var ri = 0
            while li < lhs.elements.count && ri < rhs.elements.count {
                let lKey = lhs.elements[li].key
                let rKey = rhs.elements[ri].key
                if lKey == rKey {
                    lhs.elements[li].data += rhs.elements[ri].data
                    li += 1
                    ri += 1
                } else if lKey < rKey {
                    li += 1
                } else {
                    ri += 1
                }
            }
            if li < lhs.elements.count {
                lhs.elements.removeSubrange(li...)
            }
        }

        package static func -= (lhs: inout _ShapeStyle_Pack.AnimatableData, rhs: _ShapeStyle_Pack.AnimatableData) {
            guard !rhs.elements.isEmpty else { return }
            guard !lhs.elements.isEmpty else {
                lhs = rhs
                return
            }
            var li = 0
            var ri = 0
            while li < lhs.elements.count && ri < rhs.elements.count {
                let lKey = lhs.elements[li].key
                let rKey = rhs.elements[ri].key
                if lKey == rKey {
                    lhs.elements[li].data -= rhs.elements[ri].data
                    li += 1
                    ri += 1
                } else if lKey < rKey {
                    li += 1
                } else {
                    ri += 1
                }
            }
            if li < lhs.elements.count {
                lhs.elements.removeSubrange(li...)
            }
        }

        package mutating func scale(by rhs: Double) {
            for i in elements.indices {
                elements[i].data.scale(by: rhs)
            }
        }

        @_transparent
        package static func + (lhs: _ShapeStyle_Pack.AnimatableData, rhs: _ShapeStyle_Pack.AnimatableData) -> _ShapeStyle_Pack.AnimatableData {
            var result = lhs
            result += rhs
            return result
        }

        @_transparent
        public static func - (lhs: _ShapeStyle_Pack.AnimatableData, rhs: _ShapeStyle_Pack.AnimatableData) -> _ShapeStyle_Pack.AnimatableData {
            var result = lhs
            result -= rhs
            return result
        }

        package var magnitudeSquared: Double {
            var result = 0.0
            for element in elements {
                result += element.data.magnitudeSquared
            }
            return result
        }
    }

    package var animatableData: _ShapeStyle_Pack.AnimatableData {
        get {
            AnimatableData(elements: styles.map { (key: $0.key, data: $0.style.animatableData) })
        }
        set {
            guard !newValue.elements.isEmpty, !styles.isEmpty else { return }
            var si = 0
            var di = 0
            while si < styles.count && di < newValue.elements.count {
                let sKey = styles[si].key
                let dKey = newValue.elements[di].key
                if sKey == dKey {
                    styles[si].style.animatableData = newValue.elements[di].data
                    si += 1
                    di += 1
                } else if sKey < dKey {
                    si += 1
                } else {
                    di += 1
                }
            }
        }
    }
}

// MARK: - _ShapeStyle_Pack.Style + Animatable

extension _ShapeStyle_Pack.Style: Animatable {
    package typealias AnimatableData = AnimatablePair<_ShapeStyle_Pack.Fill.AnimatableData, AnimatablePair<Float, AnimatableArray<_ShapeStyle_Pack.Effect.AnimatableData>>>

    package var animatableData: AnimatableData {
        get {
            AnimatablePair(
                fill.animatableData,
                AnimatablePair(
                    opacity,
                    AnimatableArray(effects.map { $0.animatableData })
                )
            )
        }
        set {
            fill.animatableData = newValue.first
            opacity = newValue.second.first
            let effectsData = newValue.second.second.elements
            for i in effects.indices where i < effectsData.count {
                effects[i].animatableData = effectsData[i]
            }
        }
    }
}

// MARK: - _ShapeStyle_Pack.Fill + Animatable

extension _ShapeStyle_Pack.Fill: Animatable {
    package enum AnimatableData: VectorArithmetic {
        case zero
        case color(Color.Resolved.AnimatableData)
        case vibrantColor(Color.ResolvedVibrant.AnimatableData)
        // TODO: Gradient + Shader
        // case linearGradient(LinearGradient._Paint.AnimatableData)
        // case radialGradient(RadialGradient._Paint.AnimatableData)
        // case ellipticalGradient(EllipticalGradient._Paint.AnimatableData)
        // case angularGradient(AngularGradient._Paint.AnimatableData)
        // case meshGradient(MeshGradient._Paint.AnimatableData)
        // case shader(Shader.ResolvedShader.AnimatableData)
        case colorMatrix(_ColorMatrix)

        package init(_ fill: _ShapeStyle_Pack.Fill) {
            switch fill {
            case let .color(resolved):
                self = .color(resolved.animatableData)
            case let .paint(anyPaint):
                var data: AnimatableData = .zero
                withUnsafeMutablePointer(to: &data) { ptr in
                    var visitor = PaintInitVisitor(result: ptr)
                    anyPaint.visit(&visitor)
                }
                self = data
            case let .foregroundMaterial(resolved, _):
                self = .color(resolved.animatableData)
            case .backgroundMaterial:
                self = .zero
            case let .vibrantColor(vibrant):
                self = .vibrantColor(vibrant.animatableData)
            case let .vibrantMatrix(matrix):
                self = .colorMatrix(matrix)
            case .multicolor:
                self = .zero
            }
        }

        package func set(fill: inout _ShapeStyle_Pack.Fill) {
            switch fill {
            case var .color(resolved):
                switch self {
                case let .color(data):
                    resolved.animatableData = data
                    fill = .color(resolved)
                case .zero:
                    fill = .color(.clear)
                default: break
                }
            case let .paint(anyPaint):
                _ = anyPaint
                // TODO: PaintSetVisitor for gradient/shader types
                break
            case .foregroundMaterial(var resolved, let materialStyle):
                switch self {
                case let .color(data):
                    resolved.animatableData = data
                    fill = .foregroundMaterial(resolved, materialStyle)
                case .zero:
                    fill = .foregroundMaterial(.clear, materialStyle)
                default: break
                }
            case .backgroundMaterial:
                break
            case var .vibrantColor(vibrant):
                if case let .vibrantColor(data) = self {
                    vibrant.animatableData = data
                    fill = .vibrantColor(vibrant)
                }
            case .vibrantMatrix:
                if case let .colorMatrix(matrix) = self {
                    fill = .vibrantMatrix(matrix)
                }
            case .multicolor:
                break
            }
        }

        package static func += (lhs: inout _ShapeStyle_Pack.Fill.AnimatableData, rhs: _ShapeStyle_Pack.Fill.AnimatableData) {
            switch rhs {
            case .zero: return
            case let .color(rhsData):
                guard case var .color(lhsData) = lhs else {
                    lhs = rhs
                    return
                }
                lhsData += rhsData
                lhs = .color(lhsData)
            case let .vibrantColor(rhsData):
                guard case var .vibrantColor(lhsData) = lhs else {
                    lhs = rhs
                    return
                }
                lhsData += rhsData
                lhs = .vibrantColor(lhsData)
            case let .colorMatrix(rhsData):
                guard case var .colorMatrix(lhsData) = lhs else {
                    lhs = rhs
                    return
                }
                lhsData.add(rhsData)
                lhs = .colorMatrix(lhsData)
            }
        }

        package static func -= (lhs: inout _ShapeStyle_Pack.Fill.AnimatableData, rhs: _ShapeStyle_Pack.Fill.AnimatableData) {
            switch rhs {
            case .zero: return
            case let .color(rhsData):
                guard case var .color(lhsData) = lhs else {
                    lhs = rhs
                    return
                }
                lhsData -= rhsData
                lhs = .color(lhsData)
            case let .vibrantColor(rhsData):
                guard case var .vibrantColor(lhsData) = lhs else {
                    lhs = rhs
                    return
                }
                lhsData -= rhsData
                lhs = .vibrantColor(lhsData)
            case let .colorMatrix(rhsData):
                guard case var .colorMatrix(lhsData) = lhs else {
                    lhs = rhs
                    return
                }
                lhsData.subtract(rhsData)
                lhs = .colorMatrix(lhsData)
            }
        }

        @_transparent
        package static func + (lhs: _ShapeStyle_Pack.Fill.AnimatableData, rhs: _ShapeStyle_Pack.Fill.AnimatableData) -> _ShapeStyle_Pack.Fill.AnimatableData {
            var result = lhs
            result += rhs
            return result
        }

        @_transparent
        public static func - (lhs: _ShapeStyle_Pack.Fill.AnimatableData, rhs: _ShapeStyle_Pack.Fill.AnimatableData) -> _ShapeStyle_Pack.Fill.AnimatableData {
            var result = lhs
            result -= rhs
            return result
        }

        package mutating func scale(by rhs: Double) {
            guard rhs != 1.0 else { return }
            switch self {
            case .zero: break
            case var .color(data):
                data.scale(by: rhs)
                self = .color(data)
            case var .vibrantColor(data):
                data.scale(by: rhs)
                self = .vibrantColor(data)
            case var .colorMatrix(data):
                data.scale(by: rhs)
                self = .colorMatrix(data)
            }
        }

        package var magnitudeSquared: Double {
            switch self {
            case .zero: return 0.0
            case let .color(data): return data.magnitudeSquared
            case let .vibrantColor(data): return data.magnitudeSquared
            case let .colorMatrix(data): return data.magnitudeSquared
            }
        }

        package static func == (a: _ShapeStyle_Pack.Fill.AnimatableData, b: _ShapeStyle_Pack.Fill.AnimatableData) -> Bool {
            switch (a, b) {
            case (.zero, .zero): return true
            case let (.color(lhs), .color(rhs)): return lhs == rhs
            case let (.vibrantColor(lhs), .vibrantColor(rhs)): return lhs == rhs
            case let (.colorMatrix(lhs), .colorMatrix(rhs)): return lhs == rhs
            default: return false
            }
        }

        private struct PaintSetVisitor<Paint>: ResolvedPaintVisitor where Paint: ResolvedPaint {
            var data: Paint.AnimatableData

            var result: _ShapeStyle_Pack.Fill

            mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
                guard var typedPaint = paint as? Paint else { return }
                typedPaint.animatableData = data
                result = .paint(_AnyResolvedPaint(typedPaint))
            }
        }

        private struct PaintInitVisitor: ResolvedPaintVisitor {
            var result: UnsafeMutablePointer<_ShapeStyle_Pack.Fill.AnimatableData>

            func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
                if let color = paint as? Color.Resolved {
                    result.pointee = .color(color.animatableData)
                }
                // TODO: Handle gradient and shader paint types
            }
        }
    }

    package var animatableData: _ShapeStyle_Pack.Fill.AnimatableData {
        get { AnimatableData(self) }
        set { newValue.set(fill: &self) }
    }
}

// MARK: - _ShapeStyle_Pack.Effect + Animatable

extension _ShapeStyle_Pack.Effect: Animatable {
    package typealias AnimatableData = AnimatablePair<Float, _ShapeStyle_Pack.Effect.Kind.AnimatableData>

    package var animatableData: AnimatableData {
        get { AnimatablePair(opacity, kind.animatableData) }
        set {
            opacity = newValue.first
            kind.animatableData = newValue.second
        }
    }
}

// MARK: - _ShapeStyle_Pack.Effect.Kind + Animatable

extension _ShapeStyle_Pack.Effect.Kind: Animatable {
    package enum AnimatableData: VectorArithmetic {
        case zero
        case shadow(ResolvedShadowStyle.AnimatableData)

        package init(_ fill: _ShapeStyle_Pack.Effect.Kind) {
            switch fill {
            case .none:
                self = .zero
            case let .shadow(resolved):
                self = .shadow(resolved.animatableData)
            }
        }

        package func set(effect: inout _ShapeStyle_Pack.Effect.Kind) {
            guard case let .shadow(data) = self, case var .shadow(resolved) = effect else {
                effect = .none
                return
            }
            resolved.animatableData = data
            effect = .shadow(resolved)
        }

        package static func += (lhs: inout _ShapeStyle_Pack.Effect.Kind.AnimatableData, rhs: _ShapeStyle_Pack.Effect.Kind.AnimatableData) {
            guard case let .shadow(rhsData) = rhs else { return }
            guard case var .shadow(lhsData) = lhs else {
                lhs = rhs
                return
            }
            lhsData += rhsData
            lhs = .shadow(lhsData)
        }

        package static func -= (lhs: inout _ShapeStyle_Pack.Effect.Kind.AnimatableData, rhs: _ShapeStyle_Pack.Effect.Kind.AnimatableData) {
            guard case let .shadow(rhsData) = rhs else { return }
            guard case var .shadow(lhsData) = lhs else {
                lhs = rhs
                return
            }
            lhsData -= rhsData
            lhs = .shadow(lhsData)
        }

        @_transparent
        package static func +(lhs: _ShapeStyle_Pack.Effect.Kind.AnimatableData, rhs: _ShapeStyle_Pack.Effect.Kind.AnimatableData) -> _ShapeStyle_Pack.Effect.Kind.AnimatableData {
            var result = lhs
            result += rhs
            return result
        }

        @_transparent
        public static func -(lhs: _ShapeStyle_Pack.Effect.Kind.AnimatableData, rhs: _ShapeStyle_Pack.Effect.Kind.AnimatableData) -> _ShapeStyle_Pack.Effect.Kind.AnimatableData {
            var result = lhs
            result -= rhs
            return result
        }

        package mutating func scale(by rhs: Double) {
            guard rhs != 1.0, case var .shadow(data) = self else { return }
            data.scale(by: rhs)
            self = .shadow(data)
        }

        package var magnitudeSquared: Double {
            switch self {
            case .zero: return 0.0
            case let .shadow(data): return data.magnitudeSquared
            }
        }

        package static func == (a: _ShapeStyle_Pack.Effect.Kind.AnimatableData, b: _ShapeStyle_Pack.Effect.Kind.AnimatableData) -> Bool {
            switch (a, b) {
            case (.zero, .zero): return true
            case let (.shadow(lhs), .shadow(rhs)): return lhs == rhs
            default: return false
            }
        }
    }

    package var animatableData: _ShapeStyle_Pack.Effect.Kind.AnimatableData {
        get { AnimatableData(self) }
        set { newValue.set(effect: &self) }
    }
}

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
