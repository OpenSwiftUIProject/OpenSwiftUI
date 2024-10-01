//
//  AppearanceActionModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by _makeViewList
//  ID: 8817D3B1C81ADA2B53E3500D727F785A

// MARK: - AppearanceActionModifier

internal import OpenGraphShims

/// A modifier that triggers actions when its view appears and disappears.
@frozen
public struct _AppearanceActionModifier: PrimitiveViewModifier {
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
        let effect = AppearanceEffect(modifier: modifier.value, phase: inputs.phase)
        let attribute = Attribute(effect)
        attribute.flags = [.active, .removable]
        return body(_Graph(), inputs)
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        fatalError("TODO")
    }
}

// MARK: - AppearanceEffect

private struct AppearanceEffect {
    @Attribute
    var modifier: _AppearanceActionModifier
    @Attribute
    var phase: _GraphInputs.Phase
    var lastValue: _AppearanceActionModifier?
    var isVisible: Bool = false
    var resetSeed: UInt32 = 0
    var node: AnyOptionalAttribute = AnyOptionalAttribute()

    mutating func appeared() {
        guard !isVisible else { return }
        defer { isVisible = true }
        guard let lastValue,
              let appear = lastValue.appear
        else { return }
        Update.enqueueAction(appear)
    }
    
    mutating func disappeared() {
        guard isVisible else { return }
        defer { isVisible = false }
        guard let lastValue,
              let disappear = lastValue.disappear
        else { return }
        Update.enqueueAction(disappear)
    }
}

// MARK: AppearanceEffect + StatefulRule

extension AppearanceEffect: StatefulRule {
    typealias Value = Void
    
    mutating func updateValue() {
        #if canImport(Darwin)
        if node.attribute == nil {
            node.attribute = .current
        }
        
//        if phase.seed != resetSeed {
//            resetSeed = phase.seed
//            disappeared()
//        }
        lastValue = modifier
        appeared()
        #else
        fatalError("See #39")
        #endif
    }
}

#if canImport(Darwin) // See #39

// MARK: AppearanceEffect + RemovableAttribute

extension AppearanceEffect: RemovableAttribute {
    static func willRemove(attribute: AnyAttribute) {
        let appearancePointer = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: AppearanceEffect.self)
        guard appearancePointer.pointee.lastValue != nil else {
            return
        }
        appearancePointer.pointee.disappeared()
    }
    
    static func didReinsert(attribute: AnyAttribute) {
        let appearancePointer = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: AppearanceEffect.self)
        guard let nodeAttribute = appearancePointer.pointee.node.attribute else {
            return
        }
        nodeAttribute.invalidateValue()
        nodeAttribute.graph.graphHost().graphInvalidation(from: nil)
    }
}
#endif

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
    public func onAppear(perform action: (() -> Void)? = nil) -> some View {
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
    public func onDisappear(perform action: (() -> Void)? = nil) -> some View {
        modifier(_AppearanceActionModifier(appear: nil, disappear: action))
    }
}
