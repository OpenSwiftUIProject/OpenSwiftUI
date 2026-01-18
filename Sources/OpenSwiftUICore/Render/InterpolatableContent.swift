//
//  InterpolatableContent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7377A3587909D054D379011E12826F37 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - InterpolatableContent

package protocol InterpolatableContent {
    static var defaultTransition: ContentTransition { get }

    func requiresTransition(to other: Self) -> Bool

    var appliesTransitionsForSizeChanges: Bool { get }

    var addsDrawingGroup: Bool { get }

    func modifyTransition(state: inout ContentTransition.State, to other: Self)

    func defaultAnimation(to other: Self) -> Animation?
}

extension InterpolatableContent where Self: Equatable {
    package func requiresTransition(to other: Self) -> Bool {
        self != other
    }

    package var appliesTransitionsForSizeChanges: Bool {
        false
    }

    package var addsDrawingGroup: Bool {
        false
    }
}

extension InterpolatableContent {
    package static var defaultTransition: ContentTransition {
        .identity
    }

    package func modifyTransition(state: inout ContentTransition.State, to other: Self) {
        _openSwiftUIEmptyStub()
    }

    package func defaultAnimation(to other: Self) -> Animation? {
        nil
    }
}

// MARK: - _ViewOutputs + applyInterpolatorGroup

extension _ViewOutputs {
    package mutating func applyInterpolatorGroup<T>(
        _ group: DisplayList.InterpolatorGroup,
        content: Attribute<T>,
        inputs: _ViewInputs,
        animatesSize: Bool,
        defersRender: Bool
    ) where T: InterpolatableContent {
        guard let list = preferences.displayList else {
            return
        }
        let interpolatedDisplayList = Attribute(
            InterpolatedDisplayList(
                group: group,
                content: content,
                position: inputs.position,
                animatedPosition: inputs.animatedPosition(),
                containerPosition: inputs.containerPosition,
                size: inputs.size.cgSize,
                phase: inputs.viewPhase,
                time: inputs.time,
                transaction: inputs.transaction,
                environment: inputs.environment,
                pixelLength: inputs.pixelLength,
                list: .init(list),
                animatesSize: animatesSize,
                defersRender: defersRender,
                supportsVFD: inputs.supportsVFD,
                lastContent: nil,
                lastSize: .zero,
                resetSeed: .zero,
                contentVersion: .init()
            )
        )
        interpolatedDisplayList.flags = .transactional
        displayList = interpolatedDisplayList
    }
}

// MARK: - InterpolatedDisplayList

private struct InterpolatedDisplayList<Content>: StatefulRule, AsyncAttribute where Content: InterpolatableContent {
    let group: DisplayList.InterpolatorGroup
    @Attribute var content: Content
    @Attribute var position: CGPoint
    @Attribute var animatedPosition: CGPoint
    @Attribute var containerPosition: CGPoint
    @Attribute var size: CGSize
    @Attribute var phase: _GraphInputs.Phase
    @Attribute var time: Time
    @Attribute var transaction: Transaction
    @Attribute var environment: EnvironmentValues
    @Attribute var pixelLength: CGFloat
    @OptionalAttribute var list: DisplayList?
    let animatesSize: Bool
    let defersRender: Bool
    let supportsVFD: Bool
    var lastContent: Content?
    var lastSize: CGSize
    var resetSeed: UInt32
    var contentVersion: DisplayList.Version

    init(
        group: DisplayList.InterpolatorGroup,
        content: Attribute<Content>,
        position: Attribute<CGPoint>,
        animatedPosition: Attribute<CGPoint>,
        containerPosition: Attribute<CGPoint>,
        size: Attribute<CGSize>,
        phase: Attribute<_GraphInputs.Phase>,
        time: Attribute<Time>,
        transaction: Attribute<Transaction>,
        environment: Attribute<EnvironmentValues>,
        pixelLength: Attribute<CGFloat>,
        list: OptionalAttribute<DisplayList>,
        animatesSize: Bool,
        defersRender: Bool,
        supportsVFD: Bool,
        lastContent: Content?,
        lastSize: CGSize,
        resetSeed: UInt32,
        contentVersion: DisplayList.Version
    ) {
        self.group = group
        self._content = content
        self._position = position
        self._animatedPosition = animatedPosition
        self._containerPosition = containerPosition
        self._size = size
        self._phase = phase
        self._time = time
        self._transaction = transaction
        self._environment = environment
        self._pixelLength = pixelLength
        self._list = list
        self.animatesSize = animatesSize
        self.defersRender = defersRender
        self.supportsVFD = supportsVFD
        self.lastContent = lastContent
        self.lastSize = lastSize
        self.resetSeed = resetSeed
        self.contentVersion = contentVersion
    }

    typealias Value = DisplayList

    func updateValue() {
        
    }
}
