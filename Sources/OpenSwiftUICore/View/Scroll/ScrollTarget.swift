//
//  ScrollTarget.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D49197C3D3C61F0DA0F0CF1D72D0077A (SwiftUICore)

package import OpenAttributeGraphShims
public import OpenCoreGraphicsShims

/// A type defining the target in which a scroll view should try and scroll to.
@available(OpenSwiftUI_v5_0, *)
public struct ScrollTarget {

    /// The rect that a scrollable view should try and have contained.
    public var rect: CGRect

    /// The anchor to which the rect should be aligned within the visible
    /// region of the scrollable view.
    public var anchor: UnitPoint?

    package init(rect: CGRect, anchor: UnitPoint? = nil) {
        self.rect = rect
        self.anchor = anchor
    }
}

@available(OpenSwiftUI_v6_0, *)
extension ScrollTarget: Hashable, Equatable {}

@available(*, unavailable)
extension ScrollTarget: Sendable {}

// MARK: - ScrollTargetConfiguration

package struct ScrollTargetConfiguration {
    package var animation: Animation?
    package var requiresVisibility: Bool
    package var preservesVelocity: Bool

    package init(transaction: Transaction) {
        if transaction.animation != nil, !transaction.disablesAnimations {
            animation = transaction.animation
        } else {
            animation = nil
        }
        requiresVisibility = transaction._scrollToRequiresCompleteVisibility
        preservesVelocity = transaction.scrollPositionUpdatePreservesVelocity
    }
}

// MARK: - ScrollTargetRole

package struct ScrollTargetRole {
    package enum Role {
        case container
        case target
    }

    package var role: ScrollTargetRole.Role

    package static var container: ScrollTargetRole {
        .init(role: .container)
    }

    package static var target: ScrollTargetRole {
        .init(role: .target)
    }
}

extension ScrollTargetRole {
    package typealias TargetCollection = [ScrollTargetRole.Role: [any ScrollableCollection]]

    package struct Key: PreferenceKey {
        package typealias Value = ScrollTargetRole.TargetCollection

        package static let defaultValue: Value = [:]

        package static func reduce(
            value: inout Value,
            nextValue: () -> Value
        ) {
            // TO BE VERIFY
            value.merge(nextValue()) { old, new in new }
        }
    }

    package struct ContentKey: PreferenceKey {
        package typealias Value = ScrollTargetRole.TargetCollection

        package static let defaultValue: Value = [:]

        package static func reduce(
            value: inout Value,
            nextValue: () -> Value
        ) {
            // TO BE VERIFY
            value.merge(nextValue()) { old, new in new }
        }
    }

    package struct SetLayout: Rule {
        @Attribute var role: ScrollTargetRole.Role?
        @Attribute var collection: any ScrollableCollection

        package init(
            role: Attribute<ScrollTargetRole.Role?>,
            collection: Attribute<any ScrollableCollection>
        ) {
            self._role = role
            self._collection = collection
        }

        package var value: (inout ScrollTargetRole.TargetCollection) -> Void {
            { targetCollection in
                guard let role else { return }
                var colelctions = targetCollection[role] ?? []
                colelctions.append(collection)
                targetCollection[role] = colelctions
            }
        }
    }
}

extension PreferencesInputs {
    @inline(__always)
    package var requiresScrollTargetRoleContent: Bool {
        get {
            contains(ScrollTargetRole.ContentKey.self)
        }
        set {
            if newValue {
                add(ScrollTargetRole.ContentKey.self)
            } else {
                remove(ScrollTargetRole.ContentKey.self)
            }
        }
    }
}

extension Transaction {
    private struct IsScrollStateValueUpdateKey: TransactionKey {
        static var defaultValue: Bool { false }
    }

    @inline(__always)
    package var isScrollStateValueUpdate: Bool {
        get { self[IsScrollStateValueUpdateKey.self] }
        set { self[IsScrollStateValueUpdateKey.self] = newValue }
    }
}

extension _GraphInputs {
    private struct ScrollTargetRoleKey: GraphInput {
        static let defaultValue: OptionalAttribute<ScrollTargetRole.Role?> = .init()
    }

    package var scrollTargetRole: OptionalAttribute<ScrollTargetRole.Role?> {
        get { self[ScrollTargetRoleKey.self] }
        set { self[ScrollTargetRoleKey.self] = newValue }
    }

    private struct RemovePreferenceInput: GraphInput {
        static var defaultValue: Bool { false }
    }

    package var scrollTargetRemovePreference: Bool {
        get { self[RemovePreferenceInput.self] }
        set { self[RemovePreferenceInput.self] = newValue }
    }
}

extension _ViewInputs {
    package var scrollTargetRole: OptionalAttribute<ScrollTargetRole.Role?> {
        base.scrollTargetRole
    }

    package var scrollTargetRemovePreference: Bool {
        base.scrollTargetRemovePreference
    }
}

extension Transaction {
    private struct ScrollToRequiresCompleteVisibility: TransactionKey {
        static var defaultValue: Bool { false }
    }

    package var _scrollToRequiresCompleteVisibility: Bool {
        get { self[ScrollToRequiresCompleteVisibility.self] }
        set { self[ScrollToRequiresCompleteVisibility.self] = newValue }
    }

    @_spi(Internal)
    @available(OpenSwiftUI_v4_0, *)
    public var scrollToRequiresCompleteVisibility: Bool {
        get { _scrollToRequiresCompleteVisibility }
        set { _scrollToRequiresCompleteVisibility = newValue }
    }
}
