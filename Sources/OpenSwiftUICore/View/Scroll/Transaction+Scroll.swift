//
//  Transaction+Scroll.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3107437717620AB5FD95CF7D87A21F58 (SwiftUICore?)

// MARK: - Transaction + v4

extension Transaction {
    private struct DisabledPageScrollAnimationKey: TransactionKey {
        static var defaultValue: Bool { false }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public var disablesPageScrollAnimations: Bool {
        get { self[DisabledPageScrollAnimationKey.self] }
        set { self[DisabledPageScrollAnimationKey.self] = newValue }
    }
}

// MARK: - Transaction + v5

@available(OpenSwiftUI_v5_0, *)
extension Transaction {
    private struct ScrollTargetAnchorKey: TransactionKey {
        static var defaultValue: UnitPoint? {
            nil
        }
    }

    /// The preferred alignment of the view within a scroll view's visible
    /// region when scrolling to a view.
    ///
    /// Use this API in conjunction with a
    /// ``ScrollViewProxy/scrollTo(_:anchor)`` or when updating the binding
    /// provided to a ``View/scrollPosition(id:anchor:)``.
    ///
    ///     @Binding var position: Item.ID?
    ///
    ///     var body: some View {
    ///         ScrollView {
    ///             LazyVStack {
    ///                 ForEach(items) { item in
    ///                     ItemView(item)
    ///                 }
    ///             }
    ///             .scrollTargetLayout()
    ///         }
    ///         .scrollPosition(id: $position)
    ///         .safeAreaInset(edge: .bottom) {
    ///             Button("Scroll To Bottom") {
    ///                 withAnimation {
    ///                     withTransaction(\.scrollTargetAnchor, .bottom) {
    ///                         position = items.last?.id
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// When used with the ``View/scrollPosition(id:anchor:)`` modifier,
    /// this value will be preferred over the anchor specified in the
    /// modifier for the current transaction.
    public var scrollTargetAnchor: UnitPoint? {
        get { self[ScrollTargetAnchorKey.self] }
        set { self[ScrollTargetAnchorKey.self] = newValue }
    }

    package var _disablesPageScrollAnimations: Bool {
        get { disablesPageScrollAnimations }
        set { disablesPageScrollAnimations = newValue }
    }

    package var isPageScrollAnimated: Bool {
        animation != nil && !disablesAnimations && !disablesPageScrollAnimations
    }

    private struct ScrollPreservesVelocityKey: TransactionKey {
        static var defaultValue: Bool { false }
    }

    package var scrollPositionUpdatePreservesVelocity: Bool {
        get { self[ScrollPreservesVelocityKey.self] }
        set { self[ScrollPreservesVelocityKey.self] = newValue }
    }
}


// MARK: - ScrollContentOffsetAdjustmentBehavior

/// A type that defines the different kinds of content offset adjusting
/// behaviors a scroll view can have.
@available(OpenSwiftUI_v6_0, *)
public struct ScrollContentOffsetAdjustmentBehavior {

    enum Role {
        case automatic
        case enabled
        case disabled
    }

    var role: Role

    /// The automatic behavior.
    ///
    /// A scroll view may automatically adjust its content offset
    /// based on the current context. The absolute offset may be adjusted
    /// to keep content in relatively the same place. For example,
    /// when scrolled to the bottom, a scroll view may keep the bottom
    /// edge scrolled to the bottom when the overall size of its content
    /// changes.
    public static var automatic: ScrollContentOffsetAdjustmentBehavior {
        .init(role: .automatic)
    }

    /// The disabled behavior.
    ///
    /// A scroll view will not adjust its content offset.
    public static var disabled: ScrollContentOffsetAdjustmentBehavior {
        .init(role: .disabled)
    }
}

@available(*, unavailable)
extension ScrollContentOffsetAdjustmentBehavior: Sendable {}

// MARK: - Transaction + v6

extension Transaction {
    private struct ScrollContentAdjustmentBehaviorKey: TransactionKey {
        static var defaultValue: ScrollContentOffsetAdjustmentBehavior {
            .automatic
        }
    }

    /// The behavior a scroll view will have regarding content offset
    /// adjustments for the current transaction.
    ///
    /// A scroll view may automatically adjust its content offset
    /// based on the current context. The absolute offset may be adjusted
    /// to keep content in relatively the same place. For example,
    /// when scrolled to the bottom, a scroll view may keep the bottom
    /// edge scrolled to the bottom when the overall size of its content
    /// changes.
    ///
    /// Use this property to disable these kinds of adjustments when needed.
    @available(OpenSwiftUI_v6_0, *)
    public var scrollContentOffsetAdjustmentBehavior: ScrollContentOffsetAdjustmentBehavior {
        get { self[ScrollContentAdjustmentBehaviorKey.self] }
        set { self[ScrollContentAdjustmentBehaviorKey.self] = newValue }
    }
}
