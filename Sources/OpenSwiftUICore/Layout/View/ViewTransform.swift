//
//  ViewTransform.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: CE19A3CEA6B9730579C42CE4C3071E74 (SwiftUI)
//  ID: 1CC2FE016A82CF91549A64E942CE8ED4 (SwiftUICore)

package import Foundation
#if !canImport(Darwin)
package import CoreGraphicsShims
#endif

@_spi(ForOpenSwiftUIOnly)
public struct ViewTransform: Equatable, CustomStringConvertible {
    package enum Conversion {
        case rootToSpace(CoordinateSpace)
        case spaceToRoot(CoordinateSpace)
        case localToSpace(CoordinateSpace)
        case spaceToLocal(CoordinateSpace)
        case spaceToSpace(CoordinateSpace, CoordinateSpace)
        
        package static func globalToSpace(_ space: CoordinateSpace) -> ViewTransform.Conversion {
            .spaceToSpace(.global, space)
        }
        
        package static func spaceToGlobal(_ space: CoordinateSpace) -> ViewTransform.Conversion {
            .spaceToSpace(space, .global)
        }
        
        // FIXME
        @inline(__always)
        func normalized() -> Conversion {
            guard case let .spaceToSpace(space1, space2) = self else { return self }
            if case .local = space1 {
                return .localToSpace(space2)
            } else if case .local = space2 {
                return .spaceToLocal(space1)
            } else if .root == space1 {
                return .rootToSpace(space2)
            } else if .root == space2 {
                return .spaceToRoot(space1)
            } else {
                return self
            }
        }
    }
    
    package enum Item: Equatable {
        case translation(CGSize)
        case affineTransform(CGAffineTransform, inverse: Bool)
        case projectionTransform(ProjectionTransform, inverse: Bool)
        case coordinateSpace(CoordinateSpace.Name)
        case sizedSpace(CoordinateSpace.Name, size: CGSize)
        case scrollGeometry(ViewTransform.ScrollGeometryItem)
        
        fileprivate func apply(to rect: inout CGRect?, name: CoordinateSpace.Name) {
            switch self {
                case let .translation(offset):
                    rect?.origin += offset
                case let .affineTransform(matrix, inverse):
                    #if canImport(CoreGraphics)
                    guard matrix.isRectilinear else {
                        rect = nil
                        break
                    }
                    let transform = inverse ? matrix.inverted() : matrix
                    if var rect {
                        rect = rect.applying(transform)
                    }
                    #else
                    preconditionFailure("CGAffineTransform+applying is not available on this platform")
                    #endif
                case .projectionTransform:
                    rect = nil
                case .coordinateSpace:
                    break
                case let .sizedSpace(spaceName, size):
                    guard spaceName == name else { break }
                    rect = CGRect(origin: .zero, size: size)
                case .scrollGeometry:
                    break
            }
        }
        
        fileprivate func apply(to geometry: inout ScrollGeometry?, allowUnclipped: Bool) {
            switch self {
                case let .translation(offset):
                    geometry?.contentOffset += offset
                case let .affineTransform(matrix, inverse):
                    #if canImport(CoreGraphics)
                    guard matrix.isRectilinear else {
                        geometry = nil
                        break
                    }
                    let transform = inverse ? matrix.inverted() : matrix
                    if var geometry {
                        geometry.contentOffset = geometry.contentOffset.applying(transform)
                        geometry.containerSize = geometry.containerSize.applying(transform)
                    }
                    #else
                    preconditionFailure("CGAffineTransform+applying is not available on this platform")
                    #endif
                case .projectionTransform:
                    geometry = nil
                case .coordinateSpace:
                    break
                case .sizedSpace:
                    break
                case let .scrollGeometry(geometryItem):
                    guard geometryItem.isClipped || allowUnclipped else {
                        break
                    }
                    geometry = geometryItem.base
            }
        }
    }
    
    package struct ScrollGeometryItem: ViewTransformElement {
        var base: ScrollGeometry
        var isClipped: Bool
        
        func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
            body(.scrollGeometry(self), &stop)
        }
        
        package static func == (lhs: ViewTransform.ScrollGeometryItem, rhs: ViewTransform.ScrollGeometryItem) -> Bool {
            lhs.base == rhs.base && lhs.isClipped == rhs.isClipped
        }
    }
    
    private var head: AnyElement?
    package private(set) var positionAdjustment: CGSize
    private var pendingTranslation: CGSize
    
    package init() {
        self.head = nil
        self.positionAdjustment = .zero
        self.pendingTranslation = .zero
    }
    
    package var isEmpty: Bool {
        head == nil && pendingTranslation == .zero
    }
    
    public static func == (lhs: ViewTransform, rhs: ViewTransform) -> Bool {
        guard lhs.positionAdjustment == rhs.positionAdjustment && lhs.pendingTranslation == rhs.pendingTranslation else { return false }
        guard let lhsHead = lhs.head, let rhsHead = rhs.head else { return lhs.head == nil && rhs.head == nil }
        guard lhsHead.depth == rhsHead.depth else { return false }
        
        var lhsNode: AnyElement? = lhsHead
        var rhsNode: AnyElement? = rhsHead
        
        while let lhsElement = lhsNode, let rhsElement = rhsNode {
            guard lhsElement !== rhsElement else { return true }
            guard lhsElement.isEqual(to: rhsElement) else { return false }
            lhsNode = lhsElement.next
            rhsNode = rhsElement.next
        }
        return lhsNode == nil && rhsNode == nil
    }
    
    package mutating func append(movingContentsOf elements: inout UnsafeBuffer) {
        head = BufferedElement(next: head, translation: pendingTranslation, elements: elements)
        pendingTranslation = .zero
        elements = UnsafeBuffer()
    }
    
    package mutating func appendPosition(_ position: CGPoint) {
        let adjustedPosition = position - positionAdjustment
        pendingTranslation = pendingTranslation - CGSize(adjustedPosition)
        positionAdjustment = CGSize(position)
    }
    
    package func withPosition(_ position: CGPoint) -> ViewTransform {
        var copy = self
        copy.appendPosition(position)
        return copy
    }
    
    package mutating func appendPosition(_ position: CGPoint, scale: CGFloat) {
        let adjustedPosition = position - positionAdjustment
        pendingTranslation = pendingTranslation - CGSize(adjustedPosition)
        positionAdjustment = CGSize(position) * scale
    }
    
    package mutating func resetPosition(_ position: CGPoint) {
        let adjustedPosition = position - positionAdjustment
        pendingTranslation = pendingTranslation - CGSize(adjustedPosition)
        positionAdjustment = .zero
    }
    
    package mutating func setPositionAdjustment(_ offset: CGSize) {
        positionAdjustment = offset
    }
    
    package mutating func appendTranslation(_ size: CGSize) {
        pendingTranslation += size
    }
    
    package mutating func appendAffineTransform(_ matrix: CGAffineTransform, inverse: Bool) {
        if matrix.isTranslation {
            let translation = CGSize(width: matrix.tx, height: matrix.ty)
            appendTranslation(inverse ? -translation : translation)
        } else {
            head = Element(next: head, translation: pendingTranslation, element: AffineTransformElement(matrix: matrix, inverse: inverse))
            pendingTranslation = .zero
        }
    }
    
    package mutating func appendProjectionTransform(_ matrix: ProjectionTransform, inverse: Bool) {
        if matrix.isAffine {
            appendAffineTransform(CGAffineTransform(matrix), inverse: inverse)
        } else {
            head = Element(next: head, translation: pendingTranslation, element: ProjectionTransformElement(matrix: matrix, inverse: inverse))
            pendingTranslation = .zero
        }
    }
    
    package mutating func appendCoordinateSpace(name: AnyHashable) {
        head = Element(next: head, translation: pendingTranslation, element: CoordinateSpaceElement(name: name))
        pendingTranslation = .zero
    }
    
    package mutating func appendCoordinateSpace(id: CoordinateSpace.ID) {
        head = Element(next: head, translation: pendingTranslation, element: CoordinateSpaceIDElement(id: id))
        pendingTranslation = .zero
    }
    
    package mutating func appendSizedSpace(name: AnyHashable, size: CGSize) {
        head = Element(next: head, translation: pendingTranslation, element: SizedSpaceElement(name: name, size: size))
        pendingTranslation = .zero
    }
    
    package mutating func appendSizedSpace(id: CoordinateSpace.ID, size: CGSize) {
        head = Element(next: head, translation: pendingTranslation, element: SizedSpaceIDElement(id: id, size: size))
        pendingTranslation = .zero
    }
    
    package mutating func appendScrollGeometry(_ geometry: ScrollGeometry, isClipped: Bool) {
        head = Element(next: head, translation: pendingTranslation, element: ScrollGeometryItem(base: geometry, isClipped: isClipped))
        pendingTranslation = .zero
    }
    
    package func forEach(inverted: Bool, _ body: (Item, inout Bool) -> Void) {
        guard let head else { return }
        var stop = false
        if inverted {
            if pendingTranslation != .zero {
                body(.translation(pendingTranslation), &stop)
                if stop { return }
            }
            var element: AnyElement = head
            repeat {
                element.forEach(inverted: true, stop: &stop, body)
                if stop { return }
                guard let next = element.next else { break }
                element = next
            } while true
        } else {
            withUnsafeTemporaryAllocation(
                of: AnyElement.self,
                capacity: head.depth
            ) { bufferPointer in
                bufferPointer.initializeElement(at: 0, to: head)
                var element = head
                var index = 0
                while let next = element.next {
                    bufferPointer.initializeElement(at: index, to: next)
                    element = next
                    index &+= 1
                }
                for element in bufferPointer.reversed() {
                    element.forEach(inverted: false, stop: &stop, body)
                    if stop { return }
                }
                if pendingTranslation != .zero {
                    body(.translation(pendingTranslation), &stop)
                }
            }
        }
    }
    
    package func forEach(_ body: (ViewTransform.Item, inout Bool) -> Void) {
        forEach(inverted: false, body)
    }
    
    private func spaceBeforeSpace(_ space1: CoordinateSpace, _ space2: CoordinateSpace) -> Bool {
        if case .global = space1 {
            return true
        } else if case .local = space1 {
            return false
        } else if case .global = space2 {
            return false
        } else if case .local = space2 {
            return true
        } else {
            forEach(inverted: false) { item, stop in
                // TODO
            }
            _openSwiftUIUnimplementedFailure()
        }
    }
    
    package func convert(_ conversion: ViewTransform.Conversion, _ body: (ViewTransform.Item) -> Void) {
        guard !isEmpty else { return }
        _openSwiftUIUnimplementedFailure()
    }
    
    package func convert(_ conversion: ViewTransform.Conversion, points: inout [CGPoint]) {
        guard !isEmpty else { return }
        _openSwiftUIUnimplementedFailure()
    }
    
    package func convert(_ conversion: ViewTransform.Conversion, point: CGPoint) -> CGPoint {
        guard !isEmpty else { return point }
        _openSwiftUIUnimplementedFailure()
    }
    
    package var containingScrollGeometry: ScrollGeometry? {
        _openSwiftUIUnimplementedFailure()
    }
    
    package var nearestScrollGeometry: ScrollGeometry? {
        _openSwiftUIUnimplementedFailure()
    }
    
    package func containingSizedCoordinateSpace(name: CoordinateSpace.Name) -> CGRect? {
        _openSwiftUIUnimplementedFailure()
    }
    
    public var description: String {
        var descriptionArray = pendingTranslation == .zero ? [] : [String(describing: pendingTranslation)]
        var element = head
        while let current = element {
            if let description = current.description {
                descriptionArray.append(description)
            }
            element = current.next
        }
        return descriptionArray.reversed().joined(separator: "; ")
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ViewTransform: Sendable {}

@_spi(ForOpenSwiftUIOnly)
extension ViewTransform {
    package struct UnsafeBuffer: Equatable {
        var contents: UnsafeHeterogeneousBuffer
        
        typealias Element = UnsafeHeterogeneousBuffer.Element
        
        package init() {
            contents = .init()
        }
        
        package mutating func destroy() {
            contents.destroy()
        }
        
        package mutating func appendTranslation(_ size: CGSize) {
            guard size != .zero else { return }
            contents.append(TranslationElement(offset: size), vtable: _VTable<TranslationElement>.self)
        }
        
        package mutating func appendAffineTransform(_ matrix: CGAffineTransform, inverse: Bool) {
            if matrix.isTranslation {
                let tranlation = CGSize(width: matrix.tx, height: matrix.ty)
                appendTranslation(inverse ? -tranlation : tranlation)
            } else {
                contents.append(AffineTransformElement(matrix: matrix, inverse: inverse), vtable: _VTable<AffineTransformElement>.self)
            }
        }
        
        package mutating func appendProjectionTransform(_ matrix: ProjectionTransform, inverse: Bool) {
            if matrix.isAffine {
                appendAffineTransform(CGAffineTransform(matrix), inverse: inverse)
            } else {
                contents.append(ProjectionTransformElement(matrix: matrix, inverse: inverse), vtable: _VTable<ProjectionTransformElement>.self)
            }
        }
        
        package mutating func appendCoordinateSpace(id: CoordinateSpace.ID) {
            contents.append(CoordinateSpaceIDElement(id: id), vtable: _VTable<CoordinateSpaceIDElement>.self)
        }
        
        package mutating func appendSizedSpace(id: CoordinateSpace.ID, size: CGSize) {
            contents.append(SizedSpaceIDElement(id: id, size: size), vtable: _VTable<SizedSpaceIDElement>.self)
        }
        
        package mutating func appendScrollGeometry(_ geometry: ScrollGeometry, isClipped: Bool) {
            contents.append(ScrollGeometryItem(base: geometry, isClipped: isClipped), vtable: _VTable<ScrollGeometryItem>.self)
        }
                
        package static func == (lhs: ViewTransform.UnsafeBuffer, rhs: ViewTransform.UnsafeBuffer) -> Bool {
            guard lhs.contents.count == rhs.contents.count else { return false }
            guard lhs.contents.count > 0 else { return true }
            for index in lhs.contents.indices {
                let lhsElement = lhs.contents[index]
                let rhsElement = rhs.contents[index]
                guard lhsElement.item.pointee.vtable == rhsElement.item.pointee.vtable,
                      lhsElement.vtable(as: VTable.self).equal(lhsElement, rhsElement)
                else { return false }
            }
            return true
        }
        
        fileprivate func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
            if inverted {
                withUnsafeTemporaryAllocation(
                    of: UnsafeBuffer.Element.self,
                    capacity: contents.count
                ) { bufferPointer in
                    for (index, element) in contents.enumerated() {
                        bufferPointer.initializeElement(at: index, to: element)
                    }
                    for element in bufferPointer.reversed() {
                        element.vtable(as: VTable.self).forEach(elt: element, inverted: true, stop: &stop, body)
                        if stop { return }
                    }
                }
            } else {
                for element in contents {
                    element.vtable(as: VTable.self).forEach(elt: element, inverted: false, stop: &stop, body)
                    if stop { return }
                }
            }
        }
        
        fileprivate var description: String {
            let contentsDescription = contents.map { element in
                element.vtable(as: VTable.self).description(elt: element)
            }
            return "[\(contentsDescription.joined(separator: ", "))]"
        }
        
        // MARK: - ViewTransform.UnsafeBuffer.VTable
        
        private class VTable: _UnsafeHeterogeneousBuffer_VTable {
            class func forEach(elt: _UnsafeHeterogeneousBuffer_Element, inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {}
            class func description(elt: _UnsafeHeterogeneousBuffer_Element) -> String { "" }
            class func equal(_ lhs: _UnsafeHeterogeneousBuffer_Element, _ rhs: _UnsafeHeterogeneousBuffer_Element) -> Bool { false }
        }
        
        private final class _VTable<Element>: VTable where Element: ViewTransformElement {
            override class func hasType<T>(_ type: T.Type) -> Bool {
                Element.self == type
            }
            
            override class func moveInitialize(elt: _UnsafeHeterogeneousBuffer_Element, from: _UnsafeHeterogeneousBuffer_Element) {
                let dest = elt.body(as: Element.self)
                let source = from.body(as: Element.self)
                dest.initialize(to: source.move())
            }
            
            override class func deinitialize(elt: UnsafeHeterogeneousBuffer.Element) {
                elt.body(as: Element.self).deinitialize(count: 1)
            }
            
            override class func forEach(elt: _UnsafeHeterogeneousBuffer_Element, inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
                elt.body(as: Element.self).pointee.forEach(inverted: inverted, stop: &stop, body)
            }
            
            override class func description(elt: _UnsafeHeterogeneousBuffer_Element) -> String {
                String(describing: elt.body(as: Element.self).pointee)
            }
            
            override class func equal(_ lhs: _UnsafeHeterogeneousBuffer_Element, _ rhs: _UnsafeHeterogeneousBuffer_Element) -> Bool {
                let lhs = lhs.body(as: Element.self)
                let rhs = rhs.body(as: Element.self)
                return lhs.pointee == rhs.pointee
            }
        }
    }
}

// MARK: - ViewTransformElement

private protocol ViewTransformElement: Equatable {
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ())
}

private struct TranslationElement: ViewTransformElement {
    var offset: CGSize
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        body(.translation(inverted ? -offset : offset), &stop)
    }
}

private struct AffineTransformElement: ViewTransformElement {
    var matrix: CGAffineTransform
    var inverse: Bool
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        body(.affineTransform(matrix, inverse: inverse), &stop)
    }
}

private struct ProjectionTransformElement: ViewTransformElement {
    var matrix: ProjectionTransform
    var inverse: Bool
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        body(.projectionTransform(matrix, inverse: inverse), &stop)
    }
}

private struct CoordinateSpaceElement: ViewTransformElement {
    var name: AnyHashable
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        body(.coordinateSpace(.name(name)), &stop)
    }
}

private struct CoordinateSpaceIDElement: ViewTransformElement {
    var id: CoordinateSpace.ID
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        body(.coordinateSpace(.id(id)), &stop)
    }
}

private struct SizedSpaceElement: ViewTransformElement {
    var name: AnyHashable
    var size: CGSize
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        body(.sizedSpace(.name(name), size: size), &stop)
    }
}

private struct SizedSpaceIDElement: ViewTransformElement {
    var id: CoordinateSpace.ID
    var size: CGSize
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        body(.sizedSpace(.id(id), size: size), &stop)
    }
}

// MARK: - AnyElement

private class AnyElement {
    var next: AnyElement?
    let depth: Int
    
    init(next: AnyElement?) {
        self.next = next
        self.depth = (next?.depth ?? 0) + 1
    }
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {}
    func isEqual(to other: AnyElement) -> Bool { false }
    var description: String? { nil }
}

private class Element<Value>: AnyElement where Value: ViewTransformElement {
    let translation: CGSize
    let element: Value

    init(next: AnyElement?, translation: CGSize, element: Value) {
        self.translation = translation
        self.element = element
        super.init(next: next)
    }
    
    override func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        if !inverted, translation != .zero {
            body(.translation(translation), &stop)
            if stop { return }
        }
        element.forEach(inverted: inverted, stop: &stop, body)
        if stop { return }
        if inverted, translation != .zero {
            body(.translation(-translation), &stop)
        }
    }
    
    override func isEqual(to other: AnyElement) -> Bool {
        guard let otherElement = other as? Element<Value> else { return false }
        return translation == otherElement.translation && element == otherElement.element
    }
    
    override var description: String? {
        let description = String(describing: element)
        if translation == .zero {
            return description
        } else {
            return "(\(translation), \(description))"
        }
    }
}

private class BufferedElement: AnyElement {
    let translation: CGSize
    var elements: ViewTransform.UnsafeBuffer
    
    init(next: AnyElement?, translation: CGSize, elements: ViewTransform.UnsafeBuffer) {
        self.translation = translation
        self.elements = elements
        super.init(next: next)
    }
    
    override func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        if !inverted, translation != .zero {
            body(.translation(translation), &stop)
            if stop { return }
        }
        elements.forEach(inverted: inverted, stop: &stop, body)
        if stop { return }
        if inverted, translation != .zero {
            body(.translation(-translation), &stop)
        }
    }
    
    override func isEqual(to other: AnyElement) -> Bool {
        guard let otherElement = other as? BufferedElement else { return false }
        return translation == otherElement.translation && elements == otherElement.elements
    }
    
    override var description: String? {
        let description = elements.description
        if translation == .zero {
            return description
        } else {
            return "(\(translation), \(description))"
        }
    }
}

// MARK: - ViewTransformable

private protocol ApplyViewTransform {
    mutating func applyTransform(item: ViewTransform.Item)
}

extension ApplyViewTransform {
    mutating func convert(to space: CoordinateSpace, transform: ViewTransform) {
        transform.convert(.localToSpace(space)) { item in
            applyTransform(item: item)
        }
    }
}

package protocol ViewTransformable {
    mutating func convert(to space: CoordinateSpace, transform: ViewTransform)
    mutating func convert(from space: CoordinateSpace, transform: ViewTransform)
}

extension ViewTransformable where Self: ApplyViewTransform {
    mutating func convert(to space: CoordinateSpace, transform: ViewTransform) {
        transform.convert(.localToSpace(space)) { item in
            applyTransform(item: item)
        }
    }
    
    mutating func convert(from space: CoordinateSpace, transform: ViewTransform) {
        transform.convert(.spaceToLocal(space)) { item in
            applyTransform(item: item)
        }
    }
}

extension CGPoint: ApplyViewTransform, ViewTransformable {
    package mutating func applyTransform(item: ViewTransform.Item) {
        switch item {
            case let .translation(offset):
                self += offset
            case let .affineTransform(matrix, inverse):
                #if canImport(CoreGraphics)
                if inverse {
                    if matrix.isTranslation {
                        self -= CGSize(width: matrix.tx, height: matrix.ty)
                    } else {
                        self = applying(matrix.inverted())
                    }
                } else {
                    self = applying(matrix)
                }
                #else
                preconditionFailure("CGAffineTransform+applying is not available on this platform")
                #endif
            case let .projectionTransform(matrix, inverse):
                self = inverse ? unapplying(matrix) : applying(matrix)
            case .coordinateSpace, .sizedSpace, .scrollGeometry:
                break
        }
    }
    
    package mutating func convert(to space: CoordinateSpace, transform: ViewTransform) {
        self = transform.convert(.localToSpace(space), point: self)
    }
    
    package mutating func convert(from space: CoordinateSpace, transform: ViewTransform) {
        self = transform.convert(.spaceToLocal(space), point: self)
    }
}

extension [CGPoint]: ApplyViewTransform, ViewTransformable {
    package mutating func applyTransform(item: ViewTransform.Item) {
        switch item {
            case let .translation(offset):
                self = map { $0 + offset }
            case let .affineTransform(matrix, inverse):
                #if canImport(CoreGraphics)
                let tranform = inverse ? matrix.inverted() : matrix
                self = map { $0.applying(tranform) }
                #else
                preconditionFailure("CGAffineTransform+applying is not available on this platform")
                #endif
            case let .projectionTransform(matrix, inverse):
                apply(matrix, inverse: inverse)
            case .coordinateSpace, .sizedSpace, .scrollGeometry:
                break
        }
    }
    
    package mutating func apply(_ m: ProjectionTransform, inverse: Bool) {
        self = map { inverse ? $0.unapplying(m) : $0.applying(m) }
    }
    
    package mutating func convert(to space: CoordinateSpace, transform: ViewTransform) {
        transform.convert(.localToSpace(space), points: &self)
    }
    
    package mutating func convert(from space: CoordinateSpace, transform: ViewTransform) {
        transform.convert(.spaceToLocal(space), points: &self)
    }
}

extension CGRect: ViewTransformable {
    package mutating func convert(to space: CoordinateSpace, transform: ViewTransform) {
        guard !isNull else { return }
        guard !isInfinite else { return }
        var points = cornerPoints
        points.convert(to: space, transform: transform)
        self = CGRect(cornerPoints: points)
    }
    
    package mutating func convert(from space: CoordinateSpace, transform: ViewTransform) {
        guard !isNull else { return }
        guard !isInfinite else { return }
        var points = cornerPoints
        points.convert(from: space, transform: transform)
        self = CGRect(cornerPoints: points)
    }
    
    package mutating func whileClippingToScrollViewsConvert(to space: CoordinateSpace, transform: ViewTransform) -> Bool {
        guard !isNull else { return true }
        guard !isInfinite else { return true }
        transform.convert(.localToSpace(space)) { item in
            // TODO
        }
        _openSwiftUIUnimplementedFailure()
    }
}

// TODO: Path + ViewTransformable
//extension Path: ViewTransformable {
//    package mutating func convert(to space: CoordinateSpace, transform: ViewTransform)
//    package mutating func convert(from space: CoordinateSpace, transform: ViewTransform)
//}
