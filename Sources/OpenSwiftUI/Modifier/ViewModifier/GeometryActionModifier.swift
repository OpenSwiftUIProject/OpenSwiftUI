//
//  GeometryActionModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C54F0E3D6B140990A91B914A8FD7209B (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - GeometryActionModifier

@available(OpenSwiftUI_v4_0, *)
@frozen
@preconcurrency
public struct _GeometryActionModifier<Value>: UnaryViewModifier, PrimitiveViewModifier where Value: Equatable, Value: Sendable {
    @preconcurrency public var value: @Sendable (GeometryProxy) -> Value

    public var action: (Value) -> Void

    @preconcurrency
    @inlinable
    public init(
        value: @escaping @Sendable (GeometryProxy) -> Value,
        action: @escaping (Value) -> Void
    ) {
        self.value = value
        self.action = action
    }

    // @_silgen_name("$s7SwiftUI23_GeometryActionModifierV5valueyxAA0C5ProxyVYbcvi")
    @_silgen_name("$s11OpenSwiftUI23_GeometryActionModifierV5valueyxAA0D5ProxyVYbcvi")
    @usableFromInline
    internal mutating func valueInitAccessorABIShim(value: @escaping @Sendable (GeometryProxy) -> Value) {
        self.value = value
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let binder = Attribute(GeometryActionBinder<Self>(
            provider: modifier.value,
            position: inputs.position,
            size: inputs.size,
            transform: inputs.transform,
            environment: inputs.environment,
            safeAreaInsets: inputs.safeAreaInsets,
            phase: inputs.viewPhase
        ))
        binder.flags = .transactional
        return body(_Graph(), inputs)
    }
}

@available(*, unavailable)
extension _GeometryActionModifier: Sendable {}

@available(OpenSwiftUI_v4_0, *)
extension _GeometryActionModifier: GeometryActionProvider {
    func value(geometry: GeometryProxy) -> Value {
        value(geometry)
    }

    func action(oldValue _: Value, newValue: Value) {
        action(newValue)
    }
}

// MARK: - GeometryActionModifier2

@available(OpenSwiftUI_v6_0, *)
@frozen
@preconcurrency
public struct _GeometryActionModifier2<Value>: ViewModifier, UnaryViewModifier, PrimitiveViewModifier where Value: Equatable, Value: Sendable {
    private var _value: @Sendable (GeometryProxy) -> Value

    public var value: @Sendable (GeometryProxy) -> Value {
        @usableFromInline
        @storageRestrictions(initializes: _value)
        init(initialValue) {
            _value = initialValue
        }

        @_silgen_name("$s11OpenSwiftUI24_GeometryActionModifier2V5valueyxAA0D5ProxyVcvg")
        get { _value }

        @_silgen_name("$s11OpenSwiftUI24_GeometryActionModifier2V5valueyxAA0D5ProxyVcvs")
        set { _value = newValue }

        @_silgen_name("$s11OpenSwiftUI24_GeometryActionModifier2V5valueyxAA0D5ProxyVcvM")
        _modify {
            var value: @Sendable (GeometryProxy) -> Value = _value
            defer { _value = value }
            yield &value
        }
    }

    public var action: (Value, Value) -> Void

    @inlinable
    public init(
        value: @escaping @Sendable (GeometryProxy) -> Value,
        action: @escaping (Value, Value) -> Void
    ) {
        self.action = action
        self.value = value
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let binder = Attribute(GeometryActionBinder<Self>(
            provider: modifier.value,
            position: inputs.position,
            size: inputs.size,
            transform: inputs.transform,
            environment: inputs.environment,
            safeAreaInsets: inputs.safeAreaInsets,
            phase: inputs.viewPhase
        ))
        binder.flags = .transactional
        return body(_Graph(), inputs)
    }
}

@available(*, unavailable)
extension _GeometryActionModifier2: Sendable {}

@available(OpenSwiftUI_v6_0, *)
extension _GeometryActionModifier2: GeometryActionProvider {
    func value(geometry: GeometryProxy) -> Value {
        value(geometry)
    }

    func action(oldValue: Value, newValue: Value) {
        action(oldValue, newValue)
    }
}

// MARK: - GeometryActionProvider

private protocol GeometryActionProvider {
    associatedtype Value: Equatable

    func value(geometry: GeometryProxy) -> Value

    func action(oldValue: Value, newValue: Value)
}

// MARK: - GeometryActionBinder

private struct GeometryActionBinder<Provider>: StatefulRule, AsyncAttribute where Provider: GeometryActionProvider {
    @Attribute var provider: Provider
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var safeAreaInsets: SafeAreaInsets?
    @Attribute var phase: _GraphInputs.Phase
    var cycleDetector: ValueCycleDetector<Provider.Value>
    var legacyCycleDetector: UpdateCycleDetector?
    var lastResetSeed: UInt32
    var proxySeed: UInt32
    var lastValue: Provider.Value?

    init(
        provider: Attribute<Provider>,
        position: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        transform: Attribute<ViewTransform>,
        environment: Attribute<EnvironmentValues>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>,
        phase: Attribute<_GraphInputs.Phase>,
        cycleDetector: ValueCycleDetector<Provider.Value> = .init(),
        legacyCycleDetector: UpdateCycleDetector? = .init(if: !isLinkedOnOrAfter(.v6), then: .init()),
        lastResetSeed: UInt32 = 0,
        proxySeed: UInt32 = 0,
        lastValue: Provider.Value? = nil
    ) {
        self._provider = provider
        self._position = position
        self._size = size
        self._transform = transform
        self._environment = environment
        self._safeAreaInsets = safeAreaInsets
        self._phase = phase
        self.cycleDetector = cycleDetector
        self.legacyCycleDetector = legacyCycleDetector
        self.lastResetSeed = lastResetSeed
        self.proxySeed = proxySeed
        self.lastValue = lastValue
    }

    typealias Value = Void

    mutating func updateValue() {
        if phase.resetSeed != lastResetSeed {
            reset(seed: phase.resetSeed)
        }
        proxySeed &+= 1
        let proxy = GeometryProxy(
            owner: attribute.identifier,
            size: $size,
            environment: $environment,
            transform: $transform,
            position: $position,
            safeAreaInsets: $safeAreaInsets,
            seed: proxySeed
        )
        let provider = provider
        let newValue = withObservation {
            proxy.asCurrent {
                provider.value(geometry: proxy)
            }
        }
        let oldValue = lastValue ?? newValue
        guard lastValue != newValue, dispatch(value: newValue) else {
            return
        }
        Update.enqueueAction(reason: nil) {
            provider.action(oldValue: oldValue, newValue: newValue)
        }
    }

    mutating func reset(seed _: UInt32) {
        lastResetSeed = phase.resetSeed
        legacyCycleDetector?.reset()
        cycleDetector.reset()
        lastValue = nil
    }

    mutating func dispatch(value: Provider.Value) -> Bool {
        defer { lastValue = value }
        if legacyCycleDetector != nil {
            return legacyCycleDetector!.dispatch(
                label: "Geometry action",
            )
        } else {
            return cycleDetector.dispatch(
                value: value,
                label: "Geometry action",
            )
        }
    }
}


// MARK: - View + onGeometryChange

extension View {
    /// Adds an action to be performed when a value, created from a
    /// geometry proxy, changes.
    ///
    /// The geometry of a view can change frequently, especially if
    /// the view is contained within a ``ScrollView`` and that scroll view
    /// is scrolling.
    ///
    /// You should avoid updating large parts of your app whenever
    /// the scroll geometry changes. To aid in this, you provide two
    /// closures to this modifier:
    ///   * transform: This converts a value of ``GeometryProxy`` to
    ///     your own data type.
    ///   * action: This provides the data type you created in `of`
    ///     and is called whenever the data type changes.
    ///
    /// For example, you can use this modifier to know how much of a view
    /// is visible on screen. In the following example,
    /// the data type you convert to is a ``Bool`` and the action is called
    /// whenever the ``Bool`` changes.
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack {
    ///              ForEach(videos) { video in
    ///                  VideoView(video)
    ///              }
    ///          }
    ///      }
    ///
    ///     struct VideoView: View {
    ///         var video: VideoModel
    ///
    ///         var body: some View {
    ///             VideoPlayer(video)
    ///                 .onGeometryChange(for: Bool.self) { proxy in
    ///                     let frame = proxy.frame(in: .scrollView)
    ///                     let bounds = proxy.bounds(of: .scrollView) ?? .zero
    ///                     let intersection = frame.intersection(
    ///                         CGRect(origin: .zero, size: bounds.size))
    ///                     let visibleHeight = intersection.size.height
    ///                     return (visibleHeight / frame.size.height) > 0.75
    ///                 } action: { isVisible in
    ///                     video.updateAutoplayingState(
    ///                         isVisible: isVisible)
    ///                 }
    ///         }
    ///     }
    ///
    /// For easily responding to geometry changes of a scroll view, see the
    /// ``View/onScrollGeometryChange(for:of:action:)`` modifier.
    ///
    /// - Parameters:
    ///   - type: The type of value transformed from a ``GeometryProxy``.
    ///   - transform: A closure that transforms a ``GeometryProxy``
    ///     to your type.
    ///   - action: A closure to run when the transformed data changes.
    ///   - newValue: The new value that failed the comparison check.
    @available(OpenSwiftUI_v4_0, *)
    @_alwaysEmitIntoClient
    @preconcurrency
    nonisolated public func onGeometryChange<T>(
        for type: T.Type,
        of transform: @escaping @Sendable (GeometryProxy) -> T,
        action: @escaping (_ newValue: T) -> Void
    ) -> some View where T: Equatable, T: Sendable {
        modifier(_GeometryActionModifier<T>(value: transform, action: action))
    }
}

extension View {
    /// Adds an action to be performed when a value, created from a
    /// geometry proxy, changes.
    ///
    /// The geometry of a view can change frequently, especially if
    /// the view is contained within a ``ScrollView`` and that scroll view
    /// is scrolling.
    ///
    /// You should avoid updating large parts of your app whenever
    /// the scroll geometry changes. To aid in this, you provide two
    /// closures to this modifier:
    ///   * transform: This converts a value of ``GeometryProxy`` to your
    ///     own data type.
    ///   * action: This provides the data type you created in `of`
    ///     and is called whenever the data type changes.
    ///
    /// For example, you can use this modifier to know how much of a view
    /// is visible on screen. In the following example,
    /// the data type you convert to is a ``Bool`` and the action is called
    /// whenever the ``Bool`` changes.
    ///
    ///     ScrollView(.horizontal) {
    ///         LazyHStack {
    ///              ForEach(videos) { video in
    ///                  VideoView(video)
    ///              }
    ///          }
    ///      }
    ///
    ///     struct VideoView: View {
    ///         var video: VideoModel
    ///
    ///         var body: some View {
    ///             VideoPlayer(video)
    ///                 .onGeometryChange(for: Bool.self) { proxy in
    ///                     let frame = proxy.frame(in: .scrollView)
    ///                     let bounds = proxy.bounds(of: .scrollView) ?? .zero
    ///                     let intersection = frame.intersection(
    ///                         CGRect(origin: .zero, size: bounds.size))
    ///                     let visibleHeight = intersection.size.height
    ///                     return (visibleHeight / frame.size.height) > 0.75
    ///                  } action: { isVisible in
    ///                     video.updateAutoplayingState(
    ///                         isVisible: isVisible)
    ///                 }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - type: The type of value transformed from a geometry proxy.
    ///   - transform: A closure that transforms a ``GeometryProxy``
    ///     to your type.
    ///   - action: A closure to run when the transformed data changes.
    ///   - oldValue: The old value that failed the comparison check.
    ///   - newValue: The new value that failed the comparison check.
    @available(OpenSwiftUI_v6_0, *)
    @preconcurrency
    nonisolated public func onGeometryChange<T>(
        for type: T.Type,
        of transform: @escaping @Sendable (GeometryProxy) -> T,
        action: @escaping (_ oldValue: T, _ newValue: T) -> Void
    ) -> some View where T: Equatable, T: Sendable {
        modifier(_GeometryActionModifier2<T>(value: transform, action: action))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension View {
    @preconcurrency
    @inlinable
    nonisolated public func onGeometryChange<T>(
        of value: @escaping @Sendable (GeometryProxy) -> T,
        do action: @escaping (T) -> Void
    ) -> some View where T: Equatable, T: Sendable {
        modifier(_GeometryActionModifier(value: value, action: action))
    }
}
