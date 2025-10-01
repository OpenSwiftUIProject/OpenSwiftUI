//
//  AppearanceActionModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 8817D3B1C81ADA2B53E3500D727F785A (SwiftUI)
//  ID: 3EDE22C3B37C9BBEF12EC9D1A4B340F3 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - _AppearanceActionModifier [WIP]

/// A modifier that triggers actions when its view appears and disappears.
@frozen
public struct _AppearanceActionModifier: ViewModifier, PrimitiveViewModifier {
    public var appear: (() -> Void)?

    public var disappear: (() -> Void)?
  
    @inlinable
    public init(appear: (() -> Void)? = nil, disappear: (() -> Void)? = nil) {
        self.appear = appear
        self.disappear = disappear
    }
    
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let effect = AppearanceEffect(modifier: modifier.value, phase: inputs.viewPhase)
        let attribute = Attribute(effect)
        attribute.flags = [.transactional, .removable]
        return body(_Graph(), inputs)
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let modifier = modifier.value
        let attribute: Attribute<Self>
        if isLinkedOnOrAfter(.v3) {
            let callbacks = MergedCallbacks(
                modifier: modifier,
                phase: inputs.base.phase,
                box: nil
            )
            attribute = Attribute(callbacks)
        } else {
            attribute = modifier
        }
        var outputs = body(_Graph(), inputs)
        outputs.multiModifier(_GraphValue(attribute), inputs: inputs)
        return outputs
    }
}

@available(*, unavailable)
extension _AppearanceActionModifier: Sendable {}

// MARK: - View Extension

extension View {
    /// Adds an action to perform before this view appears.
    ///
    /// The exact moment that OpenSwiftUI calls this method
    /// depends on the specific view type that you apply it to, but
    /// the `action` closure completes before the first
    /// rendered frame appears.
    ///
    /// - Parameter action: The action to perform. If `action` is `nil`, the
    ///   call has no effect.
    ///
    /// - Returns: A view that triggers `action` before it appears.
    @inlinable
    nonisolated public func onAppear(perform action: (() -> Void)? = nil) -> some View {
        modifier(_AppearanceActionModifier(appear: action, disappear: nil))
    }
    
    /// Adds an action to perform after this view disappears.
    ///
    /// The exact moment that OpenSwiftUI calls this method
    /// depends on the specific view type that you apply it to, but
    /// the `action` closure doesn't execute until the view
    /// disappears from the interface.
    ///
    /// - Parameter action: The action to perform. If `action` is `nil`, the
    ///   call has no effect.
    ///
    /// - Returns: A view that triggers `action` after it disappears.
    @inlinable
    nonisolated public func onDisappear(perform action: (() -> Void)? = nil) -> some View {
        modifier(_AppearanceActionModifier(appear: nil, disappear: action))
    }
}

// MARK: - AppearanceEffect

package struct AppearanceEffect: StatefulRule, RemovableAttribute {
    @Attribute var modifier: _AppearanceActionModifier
    @Attribute var phase: _GraphInputs.Phase
    var lastValue: _AppearanceActionModifier?
    var isVisible: Bool
    var resetSeed: UInt32
    var node: AnyOptionalAttribute

    package init(modifier: Attribute<_AppearanceActionModifier>, phase: Attribute<ViewPhase>) {
        self._modifier = modifier
        self._phase = phase
        self.lastValue = nil
        self.isVisible = false
        self.resetSeed = 0
        self.node = AnyOptionalAttribute()
    }

    mutating func appeared() {
        guard !isVisible else { return }
        if let lastValue, let appear = lastValue.appear {
            Update.enqueueAction(appear)
        }
        isVisible = true
        let host = GraphHost.currentHost
        if !host.removedState.isEmpty, isLinkedOnOrAfter(.v6) {
            let weak = AnyWeakAttribute(AnyAttribute.current!)
            Update.enqueueAction {
                guard let attribute = weak.attribute else { return }
                Self.willRemove(attribute: attribute)
            }
        }
    }

    mutating func disappeared() {
        guard isVisible else { return }
        if let lastValue, let disappear = lastValue.disappear {
            Update.enqueueAction(disappear)
        }
        isVisible = false
    }

    package typealias Value = Void

    package mutating func updateValue() {
        if node.attribute == nil {
            node.attribute = .current
        }
        let latestResetSeed = phase.resetSeed
        if resetSeed != latestResetSeed {
            resetSeed = latestResetSeed
            disappeared()
        }
        lastValue = modifier
        appeared()
    }

    package static func willRemove(attribute: AnyAttribute) {
        let appearancePointer = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: AppearanceEffect.self)
        guard appearancePointer.pointee.lastValue != nil else {
            return
        }
        appearancePointer.pointee.disappeared()
    }

    package static func didReinsert(attribute: AnyAttribute) {
        let appearancePointer = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: AppearanceEffect.self)
        guard let nodeAttribute = appearancePointer.pointee.node.attribute else {
            return
        }
        nodeAttribute.invalidateValue()
        let context = nodeAttribute.graph.graphHost()
        context.graphInvalidation(from: nil)
    }
}

extension _AppearanceActionModifier {
    // MARK: - MergedBox

    private class MergedBox {
        let resetSeed: UInt32
        var count: Int32
        var lastCount: Int32
        var base: _AppearanceActionModifier
        var pendingUpdate: Bool

        init(resetSeed: UInt32, count: Int32 = 0, lastCount: Int32 = 0, base: _AppearanceActionModifier = .init(), pendingUpdate: Bool = false) {
            self.resetSeed = resetSeed
            self.count = count
            self.lastCount = lastCount
            self.base = base
            self.pendingUpdate = pendingUpdate
        }

        func appear() {
            defer { count += 1 }
            guard count == 0 else { return }
            guard !pendingUpdate else {
                count = 0
                return
            }
            pendingUpdate = true
            update()
        }

        func update() {
            Update.enqueueAction { [self] in
                pendingUpdate = false
                let count = count
                let lastCount = lastCount
                self.lastCount = count
                if lastCount <= 0, count >= 0, let appear = base.appear {
                    appear()
                } else if lastCount > 0, count <= 0, let disappear = base.disappear {
                    disappear()
                }
            }
        }
    }

    // MARK: - MergedCallbacks

    private struct MergedCallbacks: StatefulRule {
        @Attribute var modifier: _AppearanceActionModifier
        @Attribute var phase: _GraphInputs.Phase
        var box: MergedBox?

        typealias Value = _AppearanceActionModifier

        mutating func updateValue() {
            let newBox: MergedBox
            if let box, box.resetSeed == phase.resetSeed {
                newBox = box
            } else {
                newBox = MergedBox(resetSeed: phase.resetSeed)
                box = newBox
            }
            newBox.base = modifier
            let box = box!
            value = _AppearanceActionModifier(
                appear: {
                    newBox.appear()
                },
                disappear: {
                    box.count -= 1
                    guard box.count == 0, !box.pendingUpdate else {
                        return
                    }
                    box.update()
                }
            )
        }
    }
}
