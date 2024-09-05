//
//  LayoutComputer.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

import Foundation

// TODO:
struct LayoutComputer: Equatable {
    static func == (lhs: LayoutComputer, rhs: LayoutComputer) -> Bool {
        lhs.seed == rhs.seed /*&& lhs.delegate == rhs.delegate*/
    }
    
    var seed: Int
    var delegate: Delegate
}

extension LayoutComputer: Defaultable {
    static var defaultValue: LayoutComputer {
        LayoutComputer(seed: 0, delegate: LayoutComputer.defaultDelegate)
    }
}

// MARK: LayoutComputer + Delegate

extension LayoutComputer {
    class Delegate: LayoutComputerDelegate {
        func layoutPriority() -> Double { .zero }
        func ignoresAutomaticPadding() -> Bool { false }
        func requiresSpacingProjection() -> Bool { false }
        func spacing() -> Spacing { fatalError() }
        func lengthThatFits(_ size: _ProposedSize, in axis: Axis) -> CGFloat {
            let result = sizeThatFits(size)
            return switch axis {
            case .horizontal: result.width
            case .vertical: result.height
            }
        }

        func sizeThatFits(_: _ProposedSize) -> CGSize { fatalError() }
        func childGeometries(at _: ViewSize, origin _: CGPoint) -> [ViewGeometry] { fatalError() }
        func explicitAlignment(_: AlignmentKey, at _: ViewSize) -> CGFloat? { nil }
    }
}

protocol LayoutComputerDelegate: LayoutComputer.Delegate {}

// MARK: LayoutComputer + DefaultDelegate

extension LayoutComputer {
    static let defaultDelegate = DefaultDelegate()

    class DefaultDelegate: Delegate {
        override func layoutPriority() -> Double {
            .zero
        }

        override func ignoresAutomaticPadding() -> Bool {
            false
        }

        override func spacing() -> Spacing {
            Spacing(minima: [
                .init(category: .edgeBelowText, edge: .top) : .zero,
                .init(category: .edgeAboveText, edge: .bottom) : .zero,
            ])
        }

        override func sizeThatFits(_ size: _ProposedSize) -> CGSize {
            CGSize(width: size.width ?? 10, height: size.height ?? 10)
        }

        override func childGeometries(at _: ViewSize, origin _: CGPoint) -> [ViewGeometry] {
            []
        }
    }
}

// MARK: LayoutComputer + EngineDelegate

extension LayoutComputer {
    class EngineDelegate<Engine: LayoutEngineProtocol>: Delegate {
        var engine: Engine

        init(engine: Engine) {
            self.engine = engine
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

        override func sizeThatFits(_ size: _ProposedSize) -> CGSize {
            engine.sizeThatFits(size)
        }

        override func childGeometries(at size: ViewSize, origin: CGPoint) -> [ViewGeometry] {
            engine.childGeometries(at: size, origin: origin)
        }

        override func explicitAlignment(_ key: AlignmentKey, at size: ViewSize) -> CGFloat? {
            engine.explicitAlignment(key, at: size)
        }
    }
}

protocol LayoutEngineProtocol {
    func layoutPriority() -> Double
    func ignoresAutomaticPadding() -> Bool
    func requiresSpacingProjection() -> Bool
    func spacing() -> Spacing
    func sizeThatFits(_: _ProposedSize) -> CGSize
    func childGeometries(at _: ViewSize, origin _: CGPoint) -> [ViewGeometry]
    func explicitAlignment(_: AlignmentKey, at _: ViewSize) -> CGFloat?
}
