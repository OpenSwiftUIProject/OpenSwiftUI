//
//  MatchedGeometryEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F035CBEF00D3D777B3359545F684D774 (SwiftUICore)

import Foundation
import OpenAttributeGraphShims

// MARK: - MatchedGeometryProperties

/// A set of view properties that may be synchronized between views
/// using the `View.matchedGeometryEffect()` function.
@available(OpenSwiftUI_v2_0, *)
@frozen
public struct MatchedGeometryProperties: OptionSet {
    public let rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// The view's position, in window coordinates.
    public static let position: MatchedGeometryProperties = .init(rawValue: 1 << 0)

    /// The view's size, in local coordinates.
    public static let size: MatchedGeometryProperties = .init(rawValue: 1 << 1)

    /// Both the `position` and `size` properties.
    public static let frame: MatchedGeometryProperties = [.position, .size]

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public static let clipRect: MatchedGeometryProperties = .init(rawValue: 1 << 2)
}

// MARK: - View + matchedGeometryEffect

@available(OpenSwiftUI_v2_0, *)
extension View {

    /// Defines a group of views with synchronized geometry using an
    /// identifier and namespace that you provide.
    ///
    /// This method sets the geometry of each view in the group from the
    /// inserted view with `isSource = true` (known as the "source" view),
    /// updating the values marked by `properties`.
    ///
    /// If inserting a view in the same transaction that another view
    /// with the same key is removed, the system will interpolate their
    /// frame rectangles in window space to make it appear that there
    /// is a single view moving from its old position to its new
    /// position. The usual transition mechanisms define how each of
    /// the two views is rendered during the transition (e.g. fade
    /// in/out, scale, etc), the `matchedGeometryEffect()` modifier
    /// only arranges for the geometry of the views to be linked, not
    /// their rendering.
    ///
    /// If the number of currently-inserted views in the group with
    /// `isSource = true` is not exactly one results are undefined, due
    /// to it not being clear which is the source view.
    ///
    /// - Parameters:
    ///   - id: The identifier, often derived from the identifier of
    ///     the data being displayed by the view.
    ///   - namespace: The namespace in which defines the `id`. New
    ///     namespaces are created by adding an `@Namespace` variable
    ///     to a ``View`` type and reading its value in the view's body
    ///     method.
    ///   - properties: The properties to copy from the source view.
    ///   - anchor: The relative location in the view used to produce
    ///     its shared position value.
    ///   - isSource: True if the view should be used as the source of
    ///     geometry for other views in the group.
    ///
    /// - Returns: A new view that defines an entry in the global
    ///   database of views synchronizing their geometry.
    ///
    @inlinable
    nonisolated public func matchedGeometryEffect<ID>(
        id: ID,
        in namespace: Namespace.ID,
        properties: MatchedGeometryProperties = .frame,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some View where ID: Hashable {
        modifier(
            _MatchedGeometryEffect(
                id: id,
                namespace: namespace,
                properties: properties,
                anchor: anchor,
                isSource: isSource
            )
        )
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func matchedGeometryEffect<ID, S>(
        id: ID,
        in namespace: Namespace.ID,
        clipShape: S,
        properties: MatchedGeometryProperties = .frame,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some View where ID: Hashable, S: Shape {
        modifier(
            MatchedGeometryEffect2(
                base: _MatchedGeometryEffect(
                    id: id,
                    namespace: namespace,
                    properties: properties,
                    anchor: anchor,
                    isSource: isSource
                ),
                clipShape: clipShape
            )
        )
    }
}

// MARK: - _ViewInputs + MatchedGeometryScope

extension _ViewInputs {
    package mutating func makeRootMatchedGeometryScope() {
        if self[MatchedGeometryScope.self] == nil {
            self[MatchedGeometryScope.self] = MatchedGeometryScope(inputs: self)
        }
    }
}

// MARK: - _MatchedGeometryEffect

@available(OpenSwiftUI_v2_0, *)
@frozen
public struct _MatchedGeometryEffect<ID>: MultiViewModifier, PrimitiveViewModifier where ID: Hashable {
    public var id: ID
    public var namespace: Namespace.ID
    public var args: (properties: MatchedGeometryProperties, anchor: UnitPoint, isSource: Bool)

    @inlinable
    public init(
        id: ID,
        namespace: Namespace.ID,
        properties: MatchedGeometryProperties,
        anchor: UnitPoint,
        isSource: Bool
    ) {
        (self.id, self.namespace) = (id, namespace)
        args = (properties: properties, anchor: anchor, isSource: isSource)
    }

    var qualifiedID: Pair<ID, Namespace.ID> {
        .init(id, namespace)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(
            modifier: modifier,
            inputs: inputs,
            clipShape: OptionalAttribute<Rectangle>(),
            body: body
        )
    }

    nonisolated fileprivate static func makeView<S: Shape>(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        clipShape: OptionalAttribute<S>,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let requiresDisplayList = inputs.preferences.requiresDisplayList
        let args = modifier[offset: { .of(&$0.args) }].value
        let matchedSharedFrame: Attribute<MatchedSharedFrame<ID>.Value>?
        if requiresDisplayList || inputs.needsGeometry,
           let scope = inputs[MatchedGeometryScope.self] {
            let attribute = Attribute(
                MatchedSharedFrame(
                    modifier: modifier.value,
                    args: args,
                    transaction: inputs.transaction,
                    phase: inputs.viewPhase,
                    size: inputs.size,
                    position: inputs.position,
                    transform: inputs.transform,
                    scope: scope,
                    frameIndex: nil,
                    selfAttribute: .nil,
                    resetSeed: .zero,
                    isRemoved: false
                )
            )
            attribute.flags = .removable
            matchedSharedFrame = attribute
        } else {
            matchedSharedFrame = nil
        }
        var newInputs = inputs
        let viewFrame: Attribute<ViewFrame>?
        if inputs.needsGeometry, let matchedSharedFrame {
            let frame = Attribute(
                MatchedFrame(
                    sharedFrame: matchedSharedFrame,
                    args: args,
                    size: inputs.size,
                    position: inputs.position,
                    transform: inputs.transform,
                    childLayoutComputer: .init()
                )
            )
            newInputs.position = frame.origin
            newInputs.containerPosition = inputs.animatedPosition()
            newInputs.size = frame.size
            newInputs.requestsLayoutComputer = true
            viewFrame = frame
        } else {
            viewFrame = nil
        }
        var outputs = body(_Graph(), newInputs)
        if let viewFrame {
            viewFrame.mutateBody(as: MatchedFrame.self, invalidating: true) { viewFrame in
                viewFrame.$childLayoutComputer = outputs.layoutComputer
            }
        }
        if requiresDisplayList, let matchedSharedFrame, let displayList = outputs.displayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(
                MatchedDisplayList(
                    identity: identity,
                    sharedFrame: matchedSharedFrame,
                    args: args,
                    content: displayList,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedSize(),
                    transform: inputs.transform,
                    containerPosition: inputs.containerPosition,
                    clipShape: clipShape,
                    options: inputs.displayListOptions
                )
            )
        }
        return outputs
    }
}

@available(*, unavailable)
extension _MatchedGeometryEffect: Sendable {}

// MARK: - MatchedGeometryScope

private final class MatchedGeometryScope: ViewInput {
    let subgraph: Subgraph
    let inputs: _ViewInputs
    var frames: [MatchedGeometryScope.Frame]
    var keyedFrames: [AnyHashable: Int]

    static var defaultValue: MatchedGeometryScope? {
        nil
    }

    struct Frame {
        @Attribute var frame: SharedFrame.Value
        var key: AnyHashable
        var views: [MatchedGeometryScope.Frame.View]
        var viewsSeed: UInt32
        var logged: Bool

        struct View {
            var attribute: AnyAttribute
            @Attribute var args: (properties: MatchedGeometryProperties, anchor: UnitPoint, isSource: Bool)
            @Attribute var transaction: Transaction
            @Attribute var phase: _GraphInputs.Phase
            @Attribute var size: ViewSize
            @Attribute var position: CGPoint
            @Attribute var transform: ViewTransform
        }
    }

    struct EmptyKey: Hashable {}

    init(inputs: _ViewInputs) {
        subgraph = Subgraph.current!
        self.inputs = inputs
        frames = []
        keyedFrames = [:]
    }

    func frame<ID>(
        index: inout Int?,
        for id: ID,
        view: MatchedGeometryScope.Frame.View
    ) -> SharedFrame.Value where ID: Hashable {
        let key = AnyHashable(id)
        if let currentIndex = index {
            if frames[currentIndex].key == key {
                return frames[currentIndex].frame
            } else {
                releaseFrame(index: currentIndex, owner: view.attribute)
            }
        }
        let frameIndex: Int
        let needsUpdate: Bool
        if let keyedFrameIndex = keyedFrames[key] {
            frameIndex = keyedFrameIndex
            needsUpdate = true
        } else if let emptyIndex = frames.firstIndex(where: { $0.views.isEmpty }) {
            frames[emptyIndex].key = key
            frames[emptyIndex].logged = false
            frames[emptyIndex].$frame.mutateBody(as: SharedFrame.self, invalidating: true) { sharedFrame in
                sharedFrame.reset()
            }
            frameIndex = emptyIndex
            needsUpdate = true
        } else {
            let newIndex = frames.count
            subgraph.apply {
                let sharedFrame = Attribute(SharedFrame(
                    time: inputs.time,
                    environment: inputs.environment,
                    scope: self,
                    frameIndex: newIndex,
                    listeners: [],
                    animatorState: nil,
                    resetSeed: .zero,
                    lastSourceAttribute: .init()
                ))
                sharedFrame.flags = .transactional
                let frame = Frame(
                    frame: sharedFrame,
                    key: key,
                    views: [],
                    viewsSeed: .zero,
                    logged: false
                )
                frames.append(frame)
            }
            frameIndex = newIndex
            needsUpdate = false
        }
        keyedFrames[key] = frameIndex
        frames[frameIndex].views.insert(view, at: 0)
        frames[frameIndex].viewsSeed.unsafeIncrement()
        if needsUpdate {
            let weakFrame = WeakAttribute(frames[frameIndex].$frame)
            GraphHost.currentHost.continueTransaction {
                guard let frame = weakFrame.attribute else {
                    return
                }
                frame.invalidateValue()
            }
        }
        index = frameIndex
        return frames[frameIndex].frame
    }

    func releaseFrame(index: Int, owner: AnyAttribute) {
        guard let viewIndex = frames[index].views.firstIndex(where: { $0.attribute == owner }) else {
            return
        }
        frames[index].views.remove(at: viewIndex)
        if frames[index].views.isEmpty {
            keyedFrames.removeValue(forKey: frames[index].key)
            frames[index].key = AnyHashable(EmptyKey())
        } else {
            frames[index].viewsSeed.unsafeIncrement()
        }
    }

    func sourceViewIndex(frameIndex: Int) -> Int? {
        var counter = 0
        repeat {
            let viewsSeed = frames[frameIndex].viewsSeed
            let views = frames[frameIndex].views
            let index = views.firstIndex { view in
                !view.phase.isBeingRemoved && view.args.isSource
            }
            if frames[frameIndex].viewsSeed == viewsSeed {
                return index
            }
            counter &+= 1
        } while counter != 8
        return nil
    }
}

// MARK: - MatchedGeometryEffect2

private struct MatchedGeometryEffect2<ID, S>: MultiViewModifier, PrimitiveViewModifier where ID: Hashable, S: Shape {
    var base: _MatchedGeometryEffect<ID>
    var clipShape: S

    init(base: _MatchedGeometryEffect<ID>, clipShape: S) {
        self.base = base
        self.clipShape = clipShape
    }

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _MatchedGeometryEffect<ID>.makeView(
            modifier: modifier[offset: { .of(&$0.base) }],
            inputs: inputs,
            clipShape: OptionalAttribute(modifier[offset: { .of(&$0.clipShape) }].value),
            body: body
        )
    }
}

// MARK: - MatchedSharedFrame

private struct MatchedSharedFrame<ID>: StatefulRule, AsyncAttribute, RemovableAttribute, ObservedAttribute where ID: Hashable {
    @Attribute var modifier: _MatchedGeometryEffect<ID>
    @Attribute var args: (properties: MatchedGeometryProperties, anchor: UnitPoint, isSource: Bool)
    @Attribute var transaction: Transaction
    @Attribute var phase: _GraphInputs.Phase
    @Attribute var size: ViewSize
    @Attribute var position: CGPoint
    @Attribute var transform: ViewTransform
    let scope: MatchedGeometryScope
    var frameIndex: Int?
    var selfAttribute: AnyAttribute
    var resetSeed: UInt32
    var isRemoved: Bool

    typealias Value = SharedFrame.Value

    mutating func updateValue() {
        if selfAttribute == .nil {
            selfAttribute = .current!
        }
        if resetSeed != phase.resetSeed {
            resetSeed = phase.resetSeed
            destroy()
        }
        value = if isRemoved {
            (nil, AnyOptionalAttribute(selfAttribute))
        } else {
            scope.frame(
                index: &frameIndex,
                for: modifier.qualifiedID,
                view: .init(
                    attribute: selfAttribute,
                    args: $args,
                    transaction: $transaction,
                    phase: $phase,
                    size: $size,
                    position: $position,
                    transform: $transform,
                )
            )
        }
    }

    static func willRemove(attribute: AnyAttribute) {
        let matchedSharedFramePointer = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: MatchedSharedFrame.self)
        matchedSharedFramePointer.pointee.destroy()
        attribute.mutateBody(as: MatchedSharedFrame.self, invalidating: true) { matchedSharedFrame in
            matchedSharedFrame.isRemoved = true
        }
    }

    static func didReinsert(attribute: AnyAttribute) {
        attribute.mutateBody(as: MatchedSharedFrame.self, invalidating: true) { matchedSharedFrame in
            matchedSharedFrame.isRemoved = false
        }
    }

    mutating func destroy() {
        guard let frameIndex else { return }
        scope.releaseFrame(index: frameIndex, owner: selfAttribute)
        self.frameIndex = nil
    }
}

// MARK: - MatchedDisplayList

private struct MatchedDisplayList<S>: Rule, AsyncAttribute where S: Shape {
    let identity: DisplayList.Identity
    @Attribute var sharedFrame: SharedFrame.Value
    @Attribute var args: (properties: MatchedGeometryProperties, anchor: UnitPoint, isSource: Bool)
    @Attribute var content: DisplayList
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var containerPosition: CGPoint
    @OptionalAttribute var clipShape: S?
    let options: DisplayList.Options

    var value: DisplayList {
        let effect: DisplayList.Effect
        if args.properties.contains(.clipRect) {
            let (sharedFrame, sourceAttribute) = sharedFrame
            if $sharedFrame.identifier != sourceAttribute.identifier, let sharedFrame {
                var rect = CGRect(
                    position: sharedFrame.origin,
                    size: sharedFrame.size.value,
                    anchor: args.anchor
                )
                rect.convert(from: .global, transform: transform.withPosition(position))
                let path = if let clipShape {
                    clipShape.path(in: rect)
                } else {
                    Path(rect)
                }
                effect = .clip(path, FillStyle())
            } else {
                effect = .identity
            }
        } else {
            effect = .identity
        }
        var item = DisplayList.Item(
            .effect(effect, content),
            frame: CGRect(
                origin: CGPoint(position - containerPosition),
                size: size.value
            ),
            identity: identity,
            version: DisplayList.Version(forUpdate: ())
        )
        item.canonicalize(options: options)
        return DisplayList(item)
    }
}

// MARK: - MatchedFrame

private struct MatchedFrame: Rule, AsyncAttribute {
    @Attribute var sharedFrame: SharedFrame.Value
    @Attribute var args: (properties: MatchedGeometryProperties, anchor: UnitPoint, isSource: Bool)
    @Attribute var size: ViewSize
    @Attribute var position: CGPoint
    @Attribute var transform: ViewTransform
    @OptionalAttribute var childLayoutComputer: LayoutComputer?

    var value: ViewFrame {
        let (sharedFrame, sourceAttribute) = sharedFrame
        guard $sharedFrame.identifier != sourceAttribute.identifier, let sharedFrame else {
            return ViewFrame(origin: position, size: size)
        }
        var matchedSize = sharedFrame.size
        if !args.properties.contains(.size) || args.properties.contains(.clipRect) {
            matchedSize = size
        } else if let childLayoutComputer {
            let proposal = _ProposedSize(sharedFrame.size.value)
            matchedSize = ViewSize(
                childLayoutComputer.sizeThatFits(proposal),
                proposal: proposal
            )
        }
        guard args.properties.contains(.position) else {
            return ViewFrame(origin: position, size: matchedSize)
        }
        var sharedPosition = sharedFrame.origin
        sharedPosition.convert(from: .global, transform: transform.withPosition(position))

        let origin = .init(position) + sharedPosition - CGSize(args.anchor.in(matchedSize.value))
        return ViewFrame(origin: origin, size: matchedSize)
    }
}

// MARK: - SharedFrame

private struct SharedFrame: StatefulRule, AsyncAttribute, ObservedAttribute {
    @Attribute var time: Time
    @Attribute var environment: EnvironmentValues
    let scope: MatchedGeometryScope
    let frameIndex: Int
    var listeners: [AnimationListener]
    var animatorState: AnimatorState<AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>>?
    var resetSeed: UInt32
    var lastSourceAttribute: AnyWeakAttribute

    mutating func destroy() {
        removeListeners()
    }

    mutating func removeListeners() {
        guard !listeners.isEmpty else {
            return
        }
        listeners.forEach { $0.animationWasRemoved() }
        listeners.removeAll()
    }

    mutating func reset() {
        removeListeners()
        animatorState = nil
        resetSeed = .zero
        lastSourceAttribute = .init()
    }

    typealias Value = (ViewFrame?, AnyOptionalAttribute)

    mutating func updateValue() {
        guard scope.frames[frameIndex].views.contains(where: { $0.args.isSource }) else {
            reset()
            value = (nil, AnyOptionalAttribute())
            return
        }
        var animationTime = -Time.infinity
        if animatorState != nil {
            let (time, timeChanged) = $time.changedValue()
            if timeChanged {
                animationTime = time
            }
        }
        let previousSourceAttribute = lastSourceAttribute.attribute
        if let previousSourceAttribute,
           let lastSourceView = scope.frames[frameIndex].views.first(where: { $0.attribute == previousSourceAttribute }),
           resetSeed != lastSourceView.phase.resetSeed
        {
            reset()
        }
        var needUpdates = false
        if scope.frames[frameIndex].views.count >= 2, let sourceIndex = scope.sourceViewIndex(frameIndex: frameIndex) {
            if !scope.frames[frameIndex].logged {
                needUpdates = (sourceIndex + 1) < scope.frames[frameIndex].views.count
            }
            if sourceIndex != 0 {
                let sourceView = scope.frames[frameIndex].views.remove(at: sourceIndex)
                scope.frames[frameIndex].views.insert(sourceView, at: 0)
                scope.frames[frameIndex].viewsSeed.unsafeIncrement()
            }
        }
        guard let currentView = scope.frames[frameIndex].views.first else {
            reset()
            value = (nil, AnyOptionalAttribute())
            return
        }
        if scope.frames[frameIndex].views.count > 1, previousSourceAttribute != currentView.attribute {
            let transaction = Graph.withoutUpdate { currentView.transaction }
            let animation = if transaction.disablesAnimations {
                transaction.animationIgnoringTransitionPhase
            } else {
                transaction.animation
            }
            if let animation {
                let previousView = scope.frames[frameIndex].views[1]

                let previousSize = previousView.size
                var previousOrigin = previousView.args.anchor.in(previousSize.value)
                previousOrigin.convert(to: .global, transform: previousView.transform.withPosition(previousView.position))
                let previousViewFrame = ViewFrame(origin: previousOrigin, size: previousSize)

                let currentSize = currentView.size
                var currentOrigin = currentView.args.anchor.in(currentSize.value)
                currentOrigin.convert(to: .global, transform: currentView.transform.withPosition(currentView.position))
                let currentViewFrame = ViewFrame(origin: currentOrigin, size: currentSize)

                let positionDelta = currentViewFrame.origin - previousViewFrame.origin
                let sizeDelta = currentViewFrame.size.value - previousViewFrame.size.value
                if positionDelta != .zero || sizeDelta != .zero {
                    animationTime = time
                    let interval = AnimatablePair(
                        AnimatablePair(positionDelta.width, positionDelta.height),
                        AnimatablePair(sizeDelta.width, sizeDelta.height)
                    )
                    if let animatorState {
                        animatorState.combine(
                            newAnimation: animation,
                            newInterval: interval,
                            at: animationTime,
                            in: transaction,
                            environment: $environment
                        )
                    } else {
                        animatorState = AnimatorState(
                            animation: animation,
                            interval: interval,
                            at: animationTime,
                            in: transaction
                        )
                    }
                    if let listener = transaction.animationListener {
                        listeners.append(listener)
                        listener.animationWasAdded()
                    }
                }
            }
        }

        if needUpdates {
            Graph.withoutUpdate {
                let views = scope.frames[frameIndex].views
                guard views.count >= 2 else { return }
                guard views.dropFirst().contains(where: { $0.phase.isInserted && $0.args.isSource }) else { return }
                Log.externalWarning(
                    "Multiple inserted views in matched geometry group \(scope.frames[frameIndex].key) have `isSource: true`, results are undefined."
                )
                scope.frames[frameIndex].logged = true
            }
        }

        lastSourceAttribute = .init(currentView.attribute)
        resetSeed = currentView.phase.resetSeed

        let currentSize = currentView.size
        var currentOrigin = currentView.args.anchor.in(currentSize.value)
        currentOrigin.convert(to: .global, transform: currentView.transform.withPosition(currentView.position))

        var viewFrame = ViewFrame(origin: currentOrigin, size: currentSize)
        var sourceAttribute = AnyOptionalAttribute(currentView.attribute)
        if let animatorState {
            var animatableData = viewFrame.animatableData
            let isAnimationOver = animatorState.update(
                &animatableData,
                at: animationTime,
                environment: $environment
            )
            viewFrame.animatableData = animatableData
            if isAnimationOver {
                self.animatorState = nil
                removeListeners()
            } else {
                animatorState.nextUpdate()
            }
            sourceAttribute = AnyOptionalAttribute()
        }
        value = (viewFrame, sourceAttribute)
    }
}
