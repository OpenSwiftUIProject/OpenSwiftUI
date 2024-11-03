//
//  ViewInputs.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenGraphShims

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
    
    package subscript<T>(input: T.Type) -> T.Value where T : ViewInput {
        get { base[input] }
        set { base[input] = newValue }
    }
    
    package subscript<T>(input: T.Type) -> T.Value where T : ViewInput, T.Value : GraphReusable {
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
                switch newValue {
                case .horizontal:
                    base.options.formUnion(.viewStackOrientationIsHorizontal)
                case .vertical:
                    base.options.subtract(.viewStackOrientationIsHorizontal)
                }
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
            position: Attribute(identifier: .nil),
            size: Attribute(identifier: .nil),
            transform: Attribute(identifier: .nil),
            containerPosition: Attribute(identifier: .nil),
            hostPreferenceKeys: Attribute(identifier: .nil)
        )
    }
    
    package func mapEnvironment<T>(_ keyPath: KeyPath<EnvironmentValues, T>) -> Attribute<T> {
        base.mapEnvironment(keyPath)
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


// FIXME: TO BE REMOVED

// @available(*, deprecated, message: "TO BE REMOVED")
extension _ViewInputs {
    mutating func append<Input: ViewInput, Value>(_ value: Value, to type: Input.Type) where Input.Value == [Value] {
        var values = base[type]
        values.append(value)
        base[type] = values
    }
    
    mutating func popLast<Input: ViewInput, Value>(_ type: Input.Type) -> Value? where Input.Value == [Value]  {
        var values = base[type]
        guard let value = values.popLast() else {
            return nil
        }
        base[type] = values
        return value
    }
    
    // MARK: - base
    
    @inline(__always)
    mutating func withMutateGraphInputs<R>(_ body: (inout _GraphInputs) -> R) -> R {
        body(&base)
    }
    
    // MARK: - base.customInputs
    
    @inline(__always)
    func withCustomInputs<R>(_ body: (PropertyList) -> R) -> R {
        body(base.customInputs)
    }
    
    @inline(__always)
    mutating func withMutableCustomInputs<R>(_ body: (inout PropertyList) -> R) -> R {
        body(&base.customInputs)
    }
    
    // MARK: - base.cachedEnvironment
    
    @inline(__always)
    func withCachedEnviroment<R>(_ body: (CachedEnvironment) -> R) -> R {
        body(base.cachedEnvironment.wrappedValue)
    }
    
    @inline(__always)
    func withMutableCachedEnviroment<R>(_ body: (inout CachedEnvironment) -> R) -> R {
        body(&base.cachedEnvironment.wrappedValue)
    }
    
    @inline(__always)
    func detechedEnvironmentInputs() -> Self {
        var newInputs = self
        newInputs.base = self.base.detechedEnvironmentInputs()
        return newInputs
    }
}
