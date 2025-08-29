//
//  ViewInputs.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: C38EF38637B6130AEFD462CBD5EAC727 (SwiftUICore)

#if !canImport(Darwin)
package import Foundation
#endif
package import OpenAttributeGraphShims

// MARK: - ViewInputs [6.0.87]

package typealias ViewPhase = _GraphInputs.Phase

package protocol ViewInput: GraphInput {}

/// The input (aka inherited) attributes supplied to each view. Most
/// view types will only actually wire a small number of these into
/// their node. Doesn't include the view itself, which is passed
/// separately.
public struct _ViewInputs {
    package var base: _GraphInputs
    
    package var preferences: PreferencesInputs
    
    package var customInputs: PropertyList {
        get { base.customInputs }
        set { base.customInputs = newValue }
    }
    
    package subscript<T>(input: T.Type) -> T.Value where T: ViewInput {
        get { base[input] }
        set { base[input] = newValue }
    }
    
    package subscript<T>(input: T.Type) -> T.Value where T: ViewInput, T.Value: GraphReusable {
        get { base[input] }
        set { base[input] = newValue }
    }
    
    package var time: Attribute<Time> {
        get { base.time }
        set { base.time = newValue }
    }
    
    package var environment: Attribute<EnvironmentValues> {
        get { base.environment }
        set { base.environment = newValue }
    }
    
    package var viewPhase: Attribute<ViewPhase> {
        get { base.phase }
        set { base.phase = newValue }
    }
    
    package var transaction: Attribute<Transaction> {
        get { base.transaction }
        set { base.transaction = newValue }
    }
    
    package var transform: Attribute<ViewTransform> {
        didSet {
            base.changedDebugProperties.formUnion(.transform)
        }
    }
    
    package var position: Attribute<ViewOrigin> {
        didSet {
            base.changedDebugProperties.formUnion(.position)
        }
    }
    
    package var containerPosition: Attribute<ViewOrigin>
    
    package var size: Attribute<ViewSize> {
        didSet {
            base.changedDebugProperties.formUnion(.size)
        }
    }
    
    package var safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    
    package var scrollableContainerSize: OptionalAttribute<ViewSize>
    
    // MARK: - base.options
    
    package var requestsLayoutComputer: Bool {
        get { base.options.contains(.viewRequestsLayoutComputer) }
        set { base.options.setValue(newValue, for: .viewRequestsLayoutComputer) }
    }
    
    package var needsGeometry: Bool {
        get { base.options.contains(.viewNeedsGeometry) }
        set { base.options.setValue(newValue, for: .viewNeedsGeometry) }
    }
    
    package var needsDisplayListAccessibility: Bool {
        get { base.options.contains(.viewDisplayListAccessibility) }
        set { base.options.setValue(newValue, for: .viewDisplayListAccessibility) }
    }
    
    package var needsAccessibilityGeometry: Bool {
        get { base.options.contains(.viewNeedsGeometryAccessibility) }
        set { base.options.setValue(newValue, for: .viewNeedsGeometryAccessibility) }
    }
    
    package var needsAccessibilityViewResponders: Bool {
        get { base.options.contains(.viewNeedsRespondersAccessibility) }
        set { base.options.setValue(newValue, for: .viewNeedsRespondersAccessibility) }
    }
    
    package var stackOrientation: Axis? {
        get {
            if base.options.contains(.viewStackOrientationIsDefined) {
                base.options.contains(.viewStackOrientationIsHorizontal) ? .horizontal : .vertical
            } else {
                nil
            }
        }
        set {
            if let newValue {
                base.options.formUnion(.viewStackOrientationIsDefined)
                base.options.setValue(newValue == .horizontal, for: .viewStackOrientationIsHorizontal)
            } else {
                base.options.subtract([.viewStackOrientationIsDefined, .viewStackOrientationIsHorizontal])
            }
        }
    }
    
    package var supportsVFD: Bool {
        base.options.contains(.supportsVariableFrameDuration)
    }
    
    package var changedDebugProperties: _ViewDebug.Properties {
        get { base.changedDebugProperties }
        set { base.changedDebugProperties = newValue }
    }
    
    package init(
        _ base: _GraphInputs,
        position: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        transform: Attribute<ViewTransform>,
        containerPosition: Attribute<ViewOrigin>,
        hostPreferenceKeys: Attribute<PreferenceKeys>
    ) {
        self.base = base
        self.preferences = PreferencesInputs(hostKeys: hostPreferenceKeys)
        self.transform = transform
        self.position = position
        self.containerPosition = containerPosition
        self.size = size
        self.safeAreaInsets = OptionalAttribute()
        self.scrollableContainerSize = OptionalAttribute()
    }
    
    package static func invalidInputs(_ base: _GraphInputs) -> _ViewInputs {
        _ViewInputs(
            base,
            position: Attribute(identifier: AnyAttribute.nil),
            size: Attribute(identifier: AnyAttribute.nil),
            transform: Attribute(identifier: AnyAttribute.nil),
            containerPosition: Attribute(identifier: AnyAttribute.nil),
            hostPreferenceKeys: Attribute(identifier: AnyAttribute.nil)
        )
    }
    
    package func mapEnvironment<T>(id: CachedEnvironment.ID, _ body: @escaping (EnvironmentValues) -> T) -> Attribute<T> {
        base.mapEnvironment(id: id, body)
    }
    
    package func animatedPosition() -> Attribute<ViewOrigin> {
        base.cachedEnvironment.wrappedValue.animatedPosition(for: self)
    }
    
    package func animatedSize() -> Attribute<ViewSize> {
        base.cachedEnvironment.wrappedValue.animatedSize(for: self)
    }
    
    package func animatedCGSize() -> Attribute<CGSize> {
        base.cachedEnvironment.wrappedValue.animatedCGSize(for: self)
    }
    
    package func intern<T>(_ value: T, id: GraphHost.ConstantID) -> Attribute<T> {
        base.intern(value, id: id)
    }
    
    package mutating func copyCaches() {
        base.copyCaches()
    }
    
    package mutating func resetCaches() {
        base.resetCaches()
    }
    
    package mutating func append<T, U>(_ newValue: U, to _: T.Type) where T: ViewInput, T.Value == Stack<U> {
        base.append(newValue, to: T.self)
    }
    
    package mutating func append<T, U>(_ newValue: U, to _: T.Type) where T: ViewInput, U: GraphReusable, T.Value == Stack<U> {
        base.append(newValue, to: T.self)
    }
    
    package mutating func popLast<T, U>(_ key: T.Type) -> U? where T: ViewInput, T.Value == Stack<U> {
        base.popLast(key)
    }
}

@available(*, unavailable)
extension _ViewInputs: Sendable {}

// MARK: - DynamicStackOrientation [6.0.87]

package struct DynamicStackOrientation: ViewInput {
    package static let defaultValue: OptionalAttribute<Axis?> = .init()
}

extension _ViewInputs {
    @inline(__always)
    var dynamicStackOrientation: OptionalAttribute<Axis?> {
        get { self[DynamicStackOrientation.self] }
        set { self[DynamicStackOrientation.self] = newValue }
    }
}

// MARK: - ViewInputs without Geometry Dependencies [6.4.41]

extension _ViewInputs {
    package var withoutGeometryDependencies: _ViewInputs {
        let viewGraph = ViewGraph.current
        var inputs = self
        inputs.position = viewGraph.$zeroPoint
        inputs.transform = viewGraph.intern(ViewTransform(), id: .defaultValue)
        inputs.containerPosition = viewGraph.$zeroPoint
        inputs.size = viewGraph.intern(ViewSize.zero, id: .defaultValue)
        inputs.requestsLayoutComputer = false
        inputs.needsGeometry = false
        inputs.preferences.requiresDisplayList = false
        inputs.preferences.requiresViewResponders = false
        return inputs
    }

    package init(withoutGeometry base: _GraphInputs) {
        let base = base
        let viewGraph = ViewGraph.current
        let position = viewGraph.$zeroPoint
        let size = viewGraph.intern(ViewSize.zero, id: .defaultValue)
        let transform = viewGraph.intern(ViewTransform(), id: .defaultValue)
        let containerPosition = viewGraph.$zeroPoint
        let hostKeys = Attribute(value: PreferenceKeys())

        self.base = base
        self.preferences = PreferencesInputs(hostKeys: hostKeys)
        self.transform = transform
        self.position = position
        self.containerPosition = containerPosition
        self.size = size
        self.safeAreaInsets = .init()
        self.scrollableContainerSize = .init()
    }
}

extension _ViewListInputs {
    package var withoutGeometryDependencies: _ViewInputs {
        let inputs = _ViewInputs(withoutGeometry: base)
        return inputs.withoutGeometryDependencies
    }
}

// MARK: ResetDeltaModifier [6.4.41]

private struct ResetDeltaModifier: MultiViewModifier, PrimitiveViewModifier {
    var delta: UInt32

    nonisolated static func _makeView(
        modifier: _GraphValue<ResetDeltaModifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let phase = ChildPhase(base: inputs.base.phase, delta: modifier.value.unsafeOffset(at: 0, as: UInt32.self))
        inputs.viewPhase = Attribute(phase)
        return body(_Graph(), inputs)
    }

    struct ChildPhase: Rule {
        @Attribute var base: _GraphInputs.Phase
        @Attribute var delta: UInt32

        var value: _GraphInputs.Phase {
            var phase = base
            phase.resetSeed += delta
            return phase
        }
    }
}

extension View {
    package func reset(delta: UInt32) -> some View {
        modifier(ResetDeltaModifier(delta: delta))
    }
}

// MARK: Resolve Shape Style [6.4.41]

extension _ViewInputs {
    package func resolvedShapeStyles(
        role: ShapeRole,
        mode: Attribute<_ShapeStyle_ResolverMode>? = nil
    ) -> Attribute<_ShapeStyle_Pack> {
        base.cachedEnvironment.wrappedValue.resolvedShapeStyles(
            for: self,
            role: role,
            mode: mode
        )
    }
}
