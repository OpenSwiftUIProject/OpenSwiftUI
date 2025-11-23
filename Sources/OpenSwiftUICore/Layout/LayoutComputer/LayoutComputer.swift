//
//  LayoutComputer.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 91FCB5522C30220AE13689E45789FEF2 (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims

package struct LayoutComputer: Equatable {
    fileprivate var box: AnyLayoutEngineBox

    fileprivate var seed: Int = 0

    package init<E>(_ engine: E) where E: LayoutEngine {
        if LayoutTrace.isEnabled {
            box = TracingLayoutEngineBox(engine)
        } else {
            box = LayoutEngineBox(engine)
        }
    }

    package static func == (lhs: LayoutComputer, rhs: LayoutComputer) -> Bool {
        lhs.box === rhs.box && lhs.seed == rhs.seed
    }

    package func layoutPriority() -> Double {
        Update.assertIsLocked()
        return box.layoutPriority()
    }

    package func ignoresAutomaticPadding() -> Bool {
        Update.assertIsLocked()
        return box.ignoresAutomaticPadding()
    }

    package func requiresSpacingProjection() -> Bool {
        Update.assertIsLocked()
        return box.requiresSpacingProjection()
    }

    package func spacing() -> Spacing {
        Update.assertIsLocked()
        return box.spacing()
    }

    package func lengthThatFits(_ proposal: _ProposedSize, in direction: Axis) -> CGFloat {
        Update.assertIsLocked()
        return box.lengthThatFits(proposal, in: direction)
    }

    package func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        Update.assertIsLocked()
        return box.sizeThatFits(proposedSize)
    }

    package func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry] {
        Update.assertIsLocked()
        return box.childGeometries(at: parentSize, origin: origin)
    }

    package func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat? {
        Update.assertIsLocked()
        return box.explicitAlignment(k, at: viewSize)
    }
}

// MARK: - AnyLayoutEngineBox

private class AnyLayoutEngineBox {
    func mutateEngine<E, R>(as type: E.Type, do body: (inout E) -> R) -> R where E: LayoutEngine { _openSwiftUIBaseClassAbstractMethod() }

    func layoutPriority() -> Double { _openSwiftUIBaseClassAbstractMethod() }

    func ignoresAutomaticPadding() -> Bool { _openSwiftUIBaseClassAbstractMethod() }

    func requiresSpacingProjection() -> Bool { _openSwiftUIBaseClassAbstractMethod() }

    func spacing() -> Spacing { _openSwiftUIBaseClassAbstractMethod() }

    func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize { _openSwiftUIBaseClassAbstractMethod() }

    func lengthThatFits(_ proposal: _ProposedSize, in axis: Axis) -> CGFloat { _openSwiftUIBaseClassAbstractMethod() }

    func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry] { _openSwiftUIBaseClassAbstractMethod() }

    func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat? { _openSwiftUIBaseClassAbstractMethod() }

    var debugContentDescription: String? { _openSwiftUIBaseClassAbstractMethod() }
}

// MARK: - LayoutEngineBox

private class LayoutEngineBox<Engine>: AnyLayoutEngineBox where Engine: LayoutEngine {
    var engine: Engine

    init(_ engine: Engine) {
        self.engine = engine
    }

    override func mutateEngine<E, R>(as type: E.Type, do body: (inout E) -> R) -> R where E: LayoutEngine {
        precondition(Engine.self == E.self, "Mismatched engine type")
        return withUnsafePointer(to: &engine) { ptr in
            body(&UnsafeMutableRawPointer(mutating: UnsafeRawPointer(ptr)).assumingMemoryBound(to: E.self).pointee)
        }
    }

    override func layoutPriority() -> Double {
        engine.layoutPriority()
    }

    override func ignoresAutomaticPadding() -> Bool {
        engine.ignoresAutomaticPadding()
    }

    override func requiresSpacingProjection() -> Bool {
        engine.requiresSpacingProjection()
    }

    override func spacing() -> Spacing {
        engine.spacing()
    }

    override func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        engine.sizeThatFits(proposedSize)
    }

    override func lengthThatFits(_ proposal: _ProposedSize, in axis: Axis) -> CGFloat {
        engine.lengthThatFits(proposal, in: axis)
    }

    override func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry] {
        engine.childGeometries(at: parentSize, origin: origin)
    }

    override func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat? {
        engine.explicitAlignment(k, at: viewSize)
    }
}

// MARK: - TracingLayoutEngineBox

private class TracingLayoutEngineBox<Engine>: LayoutEngineBox<Engine> where Engine: LayoutEngine {
    var attribute: AnyAttribute?

    override init(_ engine: Engine) {
        attribute = .current
        super.init(engine)
        if let debugContentDescription = engine.debugContentDescription {
            LayoutTrace.recorder?.traceContentDescription(attribute, debugContentDescription)
        }
    }

    override func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        LayoutTrace.traceSizeThatFits(attribute, proposal: proposedSize) {
            engine.sizeThatFits(proposedSize)
        }
    }

    override func lengthThatFits(_ proposal: _ProposedSize, in axis: Axis) -> CGFloat {
        LayoutTrace.traceLengthThatFits(attribute, proposal: proposal, in: axis) {
            engine.lengthThatFits(proposal, in: axis)
        }
    }

    override func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry] {
        LayoutTrace.traceChildGeometries(attribute, at: parentSize, origin: origin) {
            engine.childGeometries(at: parentSize, origin: origin)
        }
    }
}

// MARK: - LayoutComputer + Defaultable

extension LayoutComputer: Defaultable {
    package struct DefaultEngine: LayoutEngine {
        package func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            proposedSize.fixingUnspecifiedDimensions()
        }

        package func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry] {
            []
        }
    }

    package static let defaultValue = LayoutComputer(DefaultEngine())
}

// MARK: - LayoutEngine

package protocol LayoutEngine {
    func layoutPriority() -> Double

    func ignoresAutomaticPadding() -> Bool

    func requiresSpacingProjection() -> Bool

    mutating func spacing() -> Spacing

    mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize

    mutating func lengthThatFits(_ proposal: _ProposedSize, in axis: Axis) -> CGFloat

    mutating func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry]

    mutating func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat?

    var debugContentDescription: String? { get }
}

// MARK: - LayoutEngine + Default implementation

extension LayoutEngine {
    package func layoutPriority() -> Double { .zero }

    package func ignoresAutomaticPadding() -> Bool { false }

    package func requiresSpacingProjection() -> Bool { false }

    package mutating func lengthThatFits(_ proposal: _ProposedSize, in axis: Axis) -> CGFloat {
        sizeThatFits(proposal)[axis]
    }

    package func childGeometries(at parentSize: ViewSize, origin: CGPoint) -> [ViewGeometry] {
        preconditionFailure("implement or don't call me!")
    }

    package func spacing() -> Spacing { Spacing() }

    package func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat? { nil }

    package var debugContentDescription: String? { nil }
}

// MARK: - LayoutComputer + Mutate

extension LayoutComputer {
    package func withMutableEngine<E, R>(type _: E.Type, do body: (inout E) -> R) -> R where E: LayoutEngine {
        Update.assertIsLocked()
        return box.mutateEngine(as: E.self, do: body)
    }
}

extension StatefulRule where Value == LayoutComputer {
    package mutating func update<E>(to engine: E) where E: LayoutEngine {
        update { mutatingEngine in
            mutatingEngine = engine
        } create: {
            engine
        }
    }

    package mutating func updateIfNotEqual<E>(to engine: E) where E: Equatable, E: LayoutEngine {
        if hasValue {
            let oldEngine = value.box as! LayoutEngineBox<E>
            if oldEngine.engine != engine {
                oldEngine.engine = engine
                value.seed &+= 1
            }
        } else {
            value = LayoutComputer(engine)
        }
    }

    package mutating func update<E>(modify: (inout E) -> Void, create: () -> E) where E: LayoutEngine {
        if hasValue {
            value.withMutableEngine(type: E.self, do: modify)
            value.seed &+= 1
        } else {
            value = LayoutComputer(create())
        }
    }
}
