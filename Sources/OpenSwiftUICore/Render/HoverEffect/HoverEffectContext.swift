//
//  HoverEffectContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct HoverEffectContext: Equatable {
    package let source: Source
    package let implicitAccessibilityID: Namespace.ID
    package let isModifyingImageView: Bool
    package let shouldApplySystemEffectAsBackground: Bool?
    package private(set) var state: State

    package init(
        source: Source,
        implicitAccessibilityID: Namespace.ID,
        isModifyingImageView: Bool,
        shouldApplySystemEffectAsBackground: Bool?,
        inheritedState: State
    ) {
        self.source = source
        self.implicitAccessibilityID = implicitAccessibilityID
        self.isModifyingImageView = isModifyingImageView
        self.shouldApplySystemEffectAsBackground = shouldApplySystemEffectAsBackground
        state = inheritedState
    }

    package mutating func applyImplicitContextIfNeeded(source: Source) {
        #if os(visionOS)
        if let groupID = self.source.groupID {
            state.applyImplicitContextIfNeeded(implicitGroupID: groupID, source: source)
        }
        #else
        _openSwiftUIEmptyStub()
        #endif
    }

    package var isEnabled: Bool {
        !state.leafContext.isDisabled
    }

    package mutating func appendDisabled(_ disabled: Bool) {
        state.appendDisabled(disabled)
    }

    #if os(visionOS)
    package var effectiveAccessibilityID: Namespace.ID {
        state.leafContext.accessibilityOptions?.accessibilityID ?? implicitAccessibilityID
    }

    package var hasAccessibilityID: Bool {
        state.hasAccessibilityID
    }

    package var firstActiveGroupID: HoverEffectGroupInfo.Identifier? {
        state.groups.first { $0.info.behavior == .activatesGroup }?.info.id ?? source.groupID
    }

    package mutating func appendGroup(_ info: HoverEffectGroupInfo, source: Source) {
        state.appendGroup(info, source: source)
    }

    package mutating func appendAnimation(_ animation: Animation, to phase: HoverEffectPhaseInfo) {
        state.leafContext.animations[phase] = animation
    }

    package mutating func appendAccessibilityID(_ accessibilityID: Namespace.ID) {
        state.appendAccessibilityID(accessibilityID)
    }

    package mutating func appendDefaultAnimationsIfNeeded() {
        if state.leafContext.animations[.inactive] == nil {
            state.leafContext.animations[.inactive] = .default
        }
        if state.leafContext.animations[.active] == nil {
            state.leafContext.animations[.active] = .default
        }
    }
    #endif

    package static func == (lhs: HoverEffectContext, rhs: HoverEffectContext) -> Bool {
        // Accessibility fallbacks and rendering flags do not affect this comparison.
        guard lhs.source == rhs.source else {
            return false
        }
        #if os(visionOS)
        return lhs.state.matches(rhs.state)
        #else
        return lhs.state.leafContext == rhs.state.leafContext
        #endif
    }

    // MARK: - Source

    package enum Source: Equatable {
        case effect(_DisplayList_Identity)
        case view(Namespace.ID)
        case none

        #if os(visionOS)
        package var groupID: HoverEffectGroupInfo.Identifier? {
            switch self {
            case let .effect(identity): .implicit(identity)
            case let .view(namespace): .view(namespace)
            case .none: nil
            }
        }
        #endif
    }

    // MARK: - Value

    package enum Value: Equatable {
        #if os(visionOS)
        case matchGroup(HoverEffectGroupInfo)
        case transition(HoverEffectTransitionInfo)
        case delay(HoverEffectDelayInfo)
        case overridePhase(HoverEffectPhaseInfo)
        case blendFactor(Double)
        case accessibilityOptions(HoverEffectAccessibilityOptions)
        case allowedTouchTypes(Set<TouchType>)
        #endif
        case disabled(Bool)
        case identity
    }

    // MARK: - Properties

    package struct Properties: Equatable {
        package fileprivate(set) var isDisabled: Bool
        #if os(visionOS)
        package fileprivate(set) var accessibilityOptions: HoverEffectAccessibilityOptions?
        package fileprivate(set) var allowedTouchTypes: Set<TouchType>?
        package fileprivate(set) var animations: [HoverEffectPhaseInfo: Animation]
        package fileprivate(set) var delays: [HoverEffectPhaseInfo: Double]
        package fileprivate(set) var overridePhase: HoverEffectPhaseInfo?
        package fileprivate(set) var blendFactor: Double
        #endif

        package init() {
            isDisabled = false
            #if os(visionOS)
            accessibilityOptions = nil
            allowedTouchTypes = nil
            animations = [:]
            delays = [:]
            overridePhase = nil
            blendFactor = 1
            #endif
        }
    }

    // MARK: - State

    package struct State {
        #if os(visionOS)
        package private(set) var groups: [Group]
        #endif
        package fileprivate(set) var leafContext: Properties

        package init() {
            #if os(visionOS)
            groups = []
            #endif
            leafContext = Properties()
        }

        package mutating func appendDisabled(_ disabled: Bool) {
            if disabled && !leafContext.isDisabled {
                leafContext.isDisabled = true
            }
        }

        #if os(visionOS)
        package var hasMatchGroup: Bool {
            !groups.isEmpty
        }

        package var hasAccessibilityID: Bool {
            leafContext.accessibilityOptions != nil
        }

        package mutating func appendAccessibilityID(_ accessibilityID: Namespace.ID) {
            leafContext.accessibilityOptions = HoverEffectAccessibilityOptions(
                accessibilityID: accessibilityID,
                attachmentBehavior: .automatic
            )
        }

        package mutating func applyImplicitContextIfNeeded(
            implicitGroupID: HoverEffectGroupInfo.Identifier,
            source: Source
        ) {
            guard !hasMatchGroup else {
                return
            }
            appendGroup(
                HoverEffectGroupInfo(id: implicitGroupID, behavior: .activatesGroup, scope: .local),
                source: source
            )
        }

        package mutating func appendValue(_ value: Value, source: Source) {
            switch value {
            case let .matchGroup(info):
                appendGroup(info, source: source)
            case let .transition(info):
                leafContext.animations[info.phase] = info.animation
            case let .delay(info):
                leafContext.delays[info.phase] = info.duration
            case let .overridePhase(phase):
                leafContext.overridePhase = phase
            case let .blendFactor(factor):
                leafContext.blendFactor *= factor
            case let .accessibilityOptions(options):
                leafContext.accessibilityOptions = options
            case let .allowedTouchTypes(types):
                if let current = leafContext.allowedTouchTypes {
                    leafContext.allowedTouchTypes = types.intersection(current)
                } else {
                    leafContext.allowedTouchTypes = types
                }
            case let .disabled(disabled):
                appendDisabled(disabled)
            case .identity:
                break
            }
        }

        package mutating func appendGroup(_ info: HoverEffectGroupInfo?, source: Source) {
            guard let info else {
                return
            }
            let group = Group(
                source: source,
                info: info,
                isDisabled: leafContext.isDisabled,
                allowedTouchTypes: leafContext.allowedTouchTypes,
                accessibilityOptions: leafContext.accessibilityOptions
            )
            guard !groups.contains(where: {
                info.isEquivalent(to: $0.info)
                    && group.accessibilityOptions == $0.accessibilityOptions
            }) else {
                return
            }
            groups.append(group)
        }

        package func hasEquivalentGroup(_ info: HoverEffectGroupInfo, namespace: Namespace.ID) -> Bool {
            let accessibilityOptions = leafContext.accessibilityOptions ?? HoverEffectAccessibilityOptions(
                accessibilityID: namespace,
                attachmentBehavior: .automatic
            )
            return groups.contains {
                info.isEquivalent(to: $0.info) && accessibilityOptions == $0.accessibilityOptions
            }
        }

        package func matches(_ other: State) -> Bool {
            guard leafContext == other.leafContext,
                  groups.count == other.groups.count else {
                return false
            }
            // Compare group state without the source that supplied each group.
            for (lhs, rhs) in zip(groups, other.groups) {
                guard lhs.info == rhs.info,
                      lhs.isDisabled == rhs.isDisabled,
                      lhs.allowedTouchTypes == rhs.allowedTouchTypes,
                      lhs.accessibilityOptions == rhs.accessibilityOptions else {
                    return false
                }
            }
            return true
        }
        #endif
    }

    // MARK: - Group

    #if os(visionOS)
    package struct Group {
        package var source: Source
        package var info: HoverEffectGroupInfo
        package var isDisabled: Bool
        package var allowedTouchTypes: Set<TouchType>?
        package var accessibilityOptions: HoverEffectAccessibilityOptions?
    }
    #endif
}
