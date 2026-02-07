//
//  CachedEnvironment.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C424ABD9FC88B2DFD0B7B2319F2E7987 (SwiftUI)
//  ID: B62A4B04AF9F1325924A089D63071424 (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims

// MARK: - CachedEnvironment

package struct CachedEnvironment {
    package private(set) var environment: Attribute<EnvironmentValues>

    package struct ID: Equatable {
        package var base: UniqueID

        package init() {
            self.base = .init()
        }
    }

    private struct MapItem {
        var key: CachedEnvironment.ID
        var value: AnyAttribute
    }

    private var mapItems: [MapItem]

    private var animatedFrame: AnimatedFrame?

    private var resolvedShapeStyles: [ResolvedShapeStyles: Attribute<ShapeStyle.Pack>]

    struct PlatformCache {}

    private var platformCache: PlatformCache

    @inline(__always)
    init(_ environment: Attribute<EnvironmentValues>) {
        self.environment = environment
        self.mapItems = []
        self.animatedFrame = nil
        self.resolvedShapeStyles = [:]
        self.platformCache = PlatformCache()
    }

    package mutating func attribute<T>(id: CachedEnvironment.ID, _ body: @escaping (EnvironmentValues) -> T) -> Attribute<T> {
        guard let item = mapItems.first(where: { $0.key == id }) else {
            let map = Map(environment, body)
            let attribute = Attribute(map)
            mapItems.append(MapItem(key: id, value: attribute.identifier))
            return attribute
        }
        return item.value.unsafeCast(to: T.self)
    }

    mutating func resolvedShapeStyles(
        for inputs: _ViewInputs,
        role: ShapeRole,
        mode: Attribute<ShapeStyle.ResolverMode>?
    ) -> Attribute<ShapeStyle.Pack> {
        guard inputs.preferences.requiresDisplayList else {
            return ViewGraph.current.intern(.defaultValue, id: .defaultValue)
        }
        let resolved = ResolvedShapeStyles(
            environment: environment,
            time: inputs.time,
            transaction: inputs.transaction,
            viewPhase: inputs.viewPhase,
            mode: .init(mode),
            role: role,
            animationsDisabled: inputs.base.animationsDisabled
        )
        guard let styles = resolvedShapeStyles[resolved] else {
            let styles = resolved.makeStyles()
            if mode == nil {
                resolvedShapeStyles[resolved] = styles
            }
            return styles
        }
        return styles
    }
}

extension CachedEnvironment {
    private mutating func withAnimatedFrame<T>(for inputs: _ViewInputs, body: (inout AnimatedFrame) -> T) -> T {
        let transaction = inputs.geometryTransaction()
        let pixelLength = attribute(id: .pixelLength) { $0.pixelLength }
        guard var animatedFrame,
           animatedFrame.position == inputs.position,
           animatedFrame.size == inputs.size,
           animatedFrame.pixelLength == pixelLength,
           animatedFrame.time == inputs.time,
           animatedFrame.transaction == transaction,
           animatedFrame.viewPhase == inputs.viewPhase else {
            animatedFrame = AnimatedFrame(
                inputs: inputs,
                pixelLength: pixelLength,
                environment: environment
            )
            return body(&animatedFrame!)
        }
        return body(&animatedFrame)
    }

    package mutating func animatedPosition(for inputs: _ViewInputs) -> Attribute<ViewOrigin> {
        guard inputs.needsGeometry else {
            return inputs.position
        }
        return withAnimatedFrame(for: inputs) { $0.animatedPosition() }
    }

    package mutating func animatedSize(for inputs: _ViewInputs) -> Attribute<ViewSize> {
        guard inputs.needsGeometry else {
            return inputs.size
        }
        return withAnimatedFrame(for: inputs) { $0.animatedSize() }
    }

    package mutating func animatedCGSize(for inputs: _ViewInputs) -> Attribute<CGSize> {
        guard inputs.needsGeometry else {
            return inputs.size.cgSize
        }
        return withAnimatedFrame(for: inputs) { $0.animatedCGSize() }
    }
}

// MARK: - ResolvedShapeStyles

private struct ResolvedShapeStyles: Hashable {
    let environment: Attribute<EnvironmentValues>
    let time: Attribute<Time>
    let transaction: Attribute<Transaction>
    let viewPhase: Attribute<_GraphInputs.Phase>
    let mode: OptionalAttribute<_ShapeStyle_ResolverMode>
    let role: ShapeRole
    let animationsDisabled: Bool

    func makeStyles() -> Attribute<ShapeStyle.Pack> {
        let styles = Attribute(
            ShapeStyleResolver<AnyShapeStyle>(
                style: .init(),
                mode: mode,
                environment: environment,
                role: role,
                animationsDisabled: animationsDisabled,
                helper: .init(phase: viewPhase, time: time, transaction: transaction)
            )
        )
        styles.flags = .transactional
        return styles
    }
}

// MARK: - CachedEnvironment.AnimatedFrame

extension CachedEnvironment.AnimatedFrame {
    package init(
        inputs: _ViewInputs,
        pixelLength: Attribute<CGFloat>,
        environment: Attribute<EnvironmentValues>
    ) {
        let frameAttribute: Attribute<ViewFrame>
        if inputs.supportsVFD {
            let attribute = AnimatableFrameAttributeVFD(
                position: inputs.position,
                size: inputs.size,
                pixelLength: pixelLength,
                environment: environment,
                phase: inputs.viewPhase,
                time: inputs.time,
                transaction: inputs.transaction,
                animationsDisabled: inputs.base.animationsDisabled
            )
            frameAttribute = Attribute(attribute)
        } else {
            let attribute = AnimatableFrameAttribute(
                position: inputs.position,
                size: inputs.size,
                pixelLength: pixelLength,
                environment: environment,
                phase: inputs.viewPhase,
                time: inputs.time,
                transaction: inputs.transaction,
                animationsDisabled: inputs.base.animationsDisabled
            )
            frameAttribute = Attribute(attribute)
        }
        frameAttribute.flags = .transactional
        self.init(
            inputs: inputs.base,
            position: inputs.position,
            size: inputs.size,
            pixelLength: pixelLength,
            animatedFrame: frameAttribute,
            environment: environment
        )
    }
}

extension CachedEnvironment {
    package struct AnimatedFrame {
        package let position: Attribute<ViewOrigin>
        package let size: Attribute<ViewSize>
        package let pixelLength: Attribute<CGFloat>
        package let time: Attribute<Time>
        package let transaction: Attribute<Transaction>
        package let viewPhase: Attribute<_GraphInputs.Phase>
        package let animatedFrame: Attribute<ViewFrame>
        private var _animatedPosition: Attribute<ViewOrigin>?
        private var _animatedSize: Attribute<ViewSize>?
        private var _animatedCGSize: Attribute<CGSize>?

        package init(
            inputs: _GraphInputs,
            position: Attribute<ViewOrigin>,
            size: Attribute<ViewSize>,
            pixelLength: Attribute<CGFloat>,
            animatedFrame: Attribute<ViewFrame>,
            environment: Attribute<EnvironmentValues>
        ) {
            self.position = position
            self.size = size
            self.pixelLength = pixelLength
            self.time = inputs.time
            self.transaction = inputs.transaction
            self.viewPhase = inputs.phase
            self.animatedFrame = animatedFrame
        }

        package mutating func animatedPosition() -> Attribute<ViewOrigin> {
            if let _animatedPosition {
                return _animatedPosition
            } else {
                let animatedPosition = animatedFrame[keyPath: \.origin]
                _animatedPosition = animatedPosition
                return animatedPosition
            }
        }

        package mutating func animatedSize() -> Attribute<ViewSize> {
            if let _animatedSize {
                return _animatedSize
            } else {
                let animatedSize = animatedFrame[keyPath: \.size]
                _animatedSize = animatedSize
                return animatedSize
            }
        }

        package mutating func animatedCGSize() -> Attribute<CGSize> {
            if let _animatedCGSize {
                return _animatedCGSize
            } else {
                let animatedCGSize = animatedFrame[keyPath: \.size.cgSize]
                _animatedCGSize = animatedCGSize
                return animatedCGSize
            }
        }
    }
}
