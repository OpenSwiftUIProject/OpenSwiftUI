//
//  ViewGraphGeometryObservers.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4717DAAA68693648A460F26E88C7D804 (SwiftUICore)

// MARK: - ViewGraphGeometryObservers

/// A container that manages geometry observers for a view graph.
///
/// `ViewGraphGeometryObservers` tracks size changes for different layout proposals
/// and notifies registered callbacks when sizes change. It uses a measurer conforming
/// to ``ViewGraphGeometryMeasurer`` to compute sizes.
///
/// The observer maintains a state machine for each proposal that tracks:
/// - The current stable size (`.value`)
/// - A pending size transition (`.pending`)
/// - Uninitialized state (`.none` or `.invalid`)
package struct ViewGraphGeometryObservers<Measurer> where Measurer: ViewGraphGeometryMeasurer {
    /// The proposal type used for layout measurements.
    package typealias Proposal = Measurer.Proposal

    /// The size type returned by measurements.
    package typealias Size = Measurer.Size

    /// A callback invoked when a size change is detected.
    ///
    /// - Parameters:
    ///   - oldSize: The previous size value.
    ///   - newSize: The new size value.
    package typealias Callback = (Size, Size) -> Void

    private var store: [Proposal: Observer]

    /// Creates an empty geometry observers container.
    init() {
        store = [:]
    }

    /// Checks if any observer needs an update based on the current view graph state.
    ///
    /// This method measures sizes for all registered proposals and transitions
    /// their storage states accordingly.
    ///
    /// - Parameter graph: The view graph to measure against.
    /// - Returns: `true` if any observer detected a size change, `false` otherwise.
    package mutating func needsUpdate(graph: ViewGraph) -> Bool {
        guard !graph.data.isHiddenForReuse else {
            return false
        }
        var result = false
        let keys = store.keys
        for proposal in keys {
            let size = Measurer.measure(given: proposal, in: graph)
            let changed = store[proposal]!.storage.transition(to: size)
            result = result || changed
        }
        return result
    }

    /// Collects and returns all pending size notifications.
    ///
    /// For each observer with a pending size change, this method transitions
    /// the storage to the new value and collects the size to notify.
    ///
    /// - Returns: A dictionary mapping proposals to their new sizes that need notification.
    package mutating func notifySizes() -> [Proposal: Size] {
        var result: [Proposal: Size] = [:]
        let keys = store.keys
        for proposal in keys {
            if let size = store[proposal]!.sizeToNotifyIfNeeded() {
                result[proposal] = size
            }
        }
        return result
    }

    /// Adds an observer for a specific layout proposal.
    ///
    /// - Parameters:
    ///   - proposal: The layout proposal to observe.
    ///   - exclusive: If `true`, removes all existing observers before adding.
    ///     Defaults to `true`.
    ///   - callback: The callback to invoke when the size changes.
    package mutating func addObserver(
        for proposal: Proposal,
        exclusive: Bool = true,
        callback: @escaping Callback
    ) {
        if exclusive {
            removeAll()
        }
        store[proposal] = Observer(callback: callback)
    }

    /// Resets the observer for a specific proposal to its initial state.
    ///
    /// - Parameter proposal: The proposal whose observer should be reset.
    /// - Returns: `true` if an observer existed and was reset, `false` otherwise.
    @discardableResult
    package mutating func resetObserver(for proposal: Proposal) -> Bool {
        store[proposal]?.reset() ?? false
    }

    /// Stops observing a specific proposal.
    ///
    /// - Parameter proposal: The proposal to stop observing.
    package mutating func stopObserving(proposal: Proposal) {
        store[proposal] = nil
    }

    /// Removes all observers.
    package mutating func removeAll() {
        store.removeAll()
    }

    // MARK: - Observer

    /// An individual geometry observer that tracks size changes for a proposal.
    private struct Observer {
        /// The current storage state tracking size transitions.
        var storage: Storage

        /// The callback to invoke when a size change is detected.
        let callback: Callback

        /// Creates an observer with the specified callback.
        ///
        /// The observer starts in the `.invalid` state.
        ///
        /// - Parameter callback: The callback to invoke on size changes.
        init(callback: @escaping Callback) {
            self.storage = .invalid
            self.callback = callback
        }

        /// Returns the size to notify if there is a pending transition.
        ///
        /// If the storage is in the `.pending` state with a size change,
        /// transitions to `.value` and returns the new size.
        ///
        /// - Returns: The new size to notify, or `nil` if no notification is needed.
        mutating func sizeToNotifyIfNeeded() -> Size? {
            guard case let .pending(size, pending) = storage else {
                return nil
            }
            storage = .value(pending)
            guard pending != size else {
                return nil
            }
            return pending
        }

        /// Resets the observer to its initial `.invalid` state.
        ///
        /// - Returns: Always returns `true`.
        mutating func reset() -> Bool {
            storage = .invalid
            return true
        }

        // MARK: - Storage

        /// The state machine for tracking size transitions.
        ///
        /// The storage tracks the lifecycle of size measurements:
        /// - `value`: A stable, committed size.
        /// - `pending`: A size transition is in progress.
        /// - `none`: Uninitialized state.
        /// - `invalid`: Explicitly invalidated, needs fresh measurement.
        enum Storage {
            /// A stable size value.
            case value(Size)
            /// A pending transition from the first size to the second.
            case pending(Size, pending: Size)
            /// Uninitialized state.
            case none
            /// Invalidated state requiring fresh measurement.
            case invalid

            /// Transitions the storage to reflect a new measured size.
            ///
            /// The state machine logic:
            /// - `.value(x)` where `x == size`: No change, returns `false`.
            /// - `.value(x)` where `x != size`: Transitions to `.pending(x, pending: size)`, returns `true`.
            /// - `.pending(v, _)` where `v == size`: Settles to `.value(size)`, returns `false`.
            /// - `.pending(v, _)` where `v != size`: Updates pending to new size, returns `true`.
            /// - `.none`: Transitions to `.pending(invalidValue, pending: size)`, returns `true`.
            /// - `.invalid`: Transitions to `.value(size)`, returns `false`.
            ///
            /// - Parameter size: The new measured size.
            /// - Returns: `true` if a change was detected that requires notification.
            mutating func transition(to size: Size) -> Bool {
                switch self {
                case let .value(currentSize):
                    guard currentSize != size else {
                        return false
                    }
                    self = .pending(currentSize, pending: size)
                    return true
                case let .pending(value, _):
                    guard size != value else {
                        self = .value(size)
                        return false
                    }
                    self = .pending(value, pending: size)
                    return true
                case .none:
                    self = .pending(Measurer.invalidValue, pending: size)
                    return true
                case .invalid:
                    self = .value(size)
                    return false
                }
            }
        }
    }
}

// MARK: - ViewGraphGeometryMeasurer

/// A protocol that defines how to measure geometry in a view graph.
///
/// Types conforming to `ViewGraphGeometryMeasurer` provide the measurement
/// logic used by ``ViewGraphGeometryObservers`` to track size changes.
package protocol ViewGraphGeometryMeasurer {
    /// The type used to propose layout dimensions.
    associatedtype Proposal: Hashable

    /// The type representing the measured size.
    associatedtype Size: Equatable

    /// Measures the size for a given proposal in a view graph.
    ///
    /// - Parameters:
    ///   - proposal: The layout proposal to measure.
    ///   - graph: The view graph context for measurement.
    /// - Returns: The measured size.
    static func measure(given proposal: Proposal, in graph: ViewGraph) -> Size

    /// Measures the size using a layout computer and insets.
    ///
    /// - Parameters:
    ///   - proposal: The layout proposal to measure.
    ///   - layoutComputer: The layout computer to use for measurement.
    ///   - insets: The edge insets to apply.
    /// - Returns: The measured size.
    static func measure(proposal: Proposal, layoutComputer: LayoutComputer, insets: EdgeInsets) -> Size

    /// A sentinel value representing an invalid or uninitialized size.
    static var invalidValue: Size { get }
}
