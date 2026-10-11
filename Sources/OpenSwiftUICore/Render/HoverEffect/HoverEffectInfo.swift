//
//  HoverEffectInfo.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - HoverEffectPhaseInfo

package enum HoverEffectPhaseInfo: Hashable {
    case inactive
    case active
}

// MARK: - HoverEffectGroupInfo

package struct HoverEffectGroupInfo: Hashable {
    package var id: Identifier
    package var behavior: Behavior
    package var scope: Scope

    package init(id: Identifier, behavior: Behavior, scope: Scope) {
        self.id = id
        self.behavior = behavior
        self.scope = scope
    }

    package func isEquivalent(to other: HoverEffectGroupInfo) -> Bool {
        guard id == other.id, scope == other.scope else {
            return false
        }
        // An existing group can cover a weaker behavior, but not the reverse.
        return switch other.behavior {
        case .activatesGroup: true
        case .followsGroup: behavior != .activatesGroup
        case .ignoresGroup: behavior == .ignoresGroup
        }
    }

    package enum Identifier: Hashable {
        case namespace(Namespace.ID)
        case named(name: String, namespace: Namespace.ID)
        case custom(String)
        case implicit(_DisplayList_Identity)
        case view(Namespace.ID)
    }

    package enum Behavior: Hashable {
        case activatesGroup
        case followsGroup
        case ignoresGroup
    }

    package enum Scope: Hashable {
        case local
        case global
    }
}

// MARK: - HoverEffectTransitionInfo

package struct HoverEffectTransitionInfo: Equatable {
    package var phase: HoverEffectPhaseInfo
    package var animation: Animation

    package init(animation: Animation, to phase: HoverEffectPhaseInfo) {
        self.phase = phase
        self.animation = animation
    }
}

// MARK: - HoverEffectDelayInfo

package struct HoverEffectDelayInfo: Equatable {
    package var duration: Double
    package var phase: HoverEffectPhaseInfo

    package init(duration: Double, phase: HoverEffectPhaseInfo) {
        self.duration = duration
        self.phase = phase
    }
}

// MARK: - HoverEffectAccessibilityOptions

package struct HoverEffectAccessibilityOptions: Equatable {
    package var accessibilityID: Namespace.ID
    package var attachmentBehavior: AttachmentBehavior

    package init(accessibilityID: Namespace.ID, attachmentBehavior: AttachmentBehavior) {
        self.accessibilityID = accessibilityID
        self.attachmentBehavior = attachmentBehavior
    }

    package enum AttachmentBehavior: Hashable {
        case automatic
        case always
    }
}
