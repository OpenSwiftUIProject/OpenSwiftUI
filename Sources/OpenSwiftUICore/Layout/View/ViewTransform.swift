//
//  ViewTransform.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: CE19A3CEA6B9730579C42CE4C3071E74 (SwiftUI)
//  ID: 1CC2FE016A82CF91549A64E942CE8ED4 (SwiftUICore)

package import Foundation

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
    }
    
    package enum Item: Equatable {
        case translation(CGSize)
        case affineTransform(CGAffineTransform, inverse: Bool)
        case projectionTransform(ProjectionTransform, inverse: Bool)
        case coordinateSpace(CoordinateSpace.Name)
        case sizedSpace(CoordinateSpace.Name, size: CGSize)
        case scrollGeometry(ViewTransform.ScrollGeometryItem)
    }
    
    package struct ScrollGeometryItem: ViewTransformElement {
        var base: ScrollGeometry
        var isClipped: Bool
        
        func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
            body(.scrollGeometry(self), &stop)
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
        // FIXME
        return lhsHead.isEqual(to: rhsHead)
    }
    
    package mutating func appendTranslation(_ size: CGSize) {
        pendingTranslation += size
    }
    
    public var description: String {
        preconditionFailure("TODO")
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
                appendTranslation(
                    CGSize(
                        width: inverse ? -matrix.tx : matrix.tx,
                        height: inverse ? -matrix.ty : matrix.ty
                    )
                )
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
    
    init(next: AnyElement? = nil, depth: Int) {
        self.next = next
        self.depth = depth
    }
    
    func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {}
    func isEqual(to other: AnyElement) -> Bool { false }
    var description: String? { nil }
}

private class Element<Value>: AnyElement where Value: ViewTransformElement {
    let translation: CGSize
    let element: Value
    
    init(translation: CGSize, element: Value) {
        self.translation = translation
        self.element = element
        preconditionFailure("TODO")
    }
    
    override func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        preconditionFailure("TODO")
    }
    
    override func isEqual(to other: AnyElement) -> Bool {
        guard let otherElement = other as? Element<Value> else { return false }
        return translation == otherElement.translation && element == otherElement.element
    }
    
    override var description: String? {
        preconditionFailure("TODO")
    }
}

private class BufferedElement: AnyElement {
    let translation: CGSize
    var elements: ViewTransform.UnsafeBuffer
    
    init(translation: CGSize, elements: ViewTransform.UnsafeBuffer) {
        self.translation = translation
        self.elements = elements
        preconditionFailure("TODO")
    }
    
    override func forEach(inverted: Bool, stop: inout Bool, _ body: (ViewTransform.Item, inout Bool) -> ()) {
        preconditionFailure("TODO")
    }
    
    override func isEqual(to other: AnyElement) -> Bool {
        guard let otherElement = other as? BufferedElement else { return false }
        return translation == otherElement.translation && elements == otherElement.elements
    }
    
    override var description: String? {
        preconditionFailure("TODO")
    }
}

// MARK: - ViewTransformable

package protocol ViewTransformable {
    mutating func convert(to space: CoordinateSpace, transform: ViewTransform)
    mutating func convert(from space: CoordinateSpace, transform: ViewTransform)
}
