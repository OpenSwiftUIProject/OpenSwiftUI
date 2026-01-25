//
//  CustomViewCountCache.swift
//  OpenSwiftUICore
//
//  Audited for 7.2.5
//  Status: Complete
//  ID: EB1EEB38755A34D46BFF2AE8785813E0 (SwiftUICore)

#if OPENSWIFTUI_SUPPORT_2025_API
import OpenAttributeGraphShims

/// A cache for tracking custom view counts during view list enumeration.
///
/// This cache stores count information for custom views, allowing efficient
/// lookups during view list traversal without recomputing counts.
package struct CustomViewCountCache {

    /// Pointer to the head of a linked list of count entries
    private var counts: UnsafeMutablePointer<Count>

    /// Optional modifier options that affect how counts are computed
    private var modifierOptions: ModifierOptions?

    /// Updates the modifier options based on new inputs and a previous ID.
    ///
    /// This method synchronizes the cache's options with the current view list
    /// inputs, ensuring that count computations remain consistent.
    ///
    /// - Parameters:
    ///   - inputs: The current view list count inputs
    ///   - previousID: The unique ID from the previous update
    private mutating func updateOptions(inputs: _ViewListCountInputs, previousID: UniqueID) {
        if let modifierOptions {
            if modifierOptions.inputID == previousID {
                self.modifierOptions = .init(
                    options: modifierOptions.options,
                    baseOptions: modifierOptions.baseOptions,
                    inputID: inputs.customInputs.id
                )
            }
        } else {
            self.modifierOptions = .init(
                options: inputs.options,
                baseOptions: inputs.baseOptions,
                inputID: inputs.customInputs.id
            )
        }
    }

    // MARK: - CustomViewCountCache.ModifierOptions

    /// Options that affect modifier behavior during count computation.
    private struct ModifierOptions {
        /// View list-specific options
        let options: _ViewListInputs.Options

        /// Base graph input options
        let baseOptions: _GraphInputs.Options

        /// Unique identifier for this set of inputs
        var inputID: UniqueID

        init(options: _ViewListInputs.Options, baseOptions: _GraphInputs.Options, inputID: UniqueID) {
            self.options = options
            self.baseOptions = baseOptions
            self.inputID = inputID
        }
    }

    // MARK: - CustomViewCountCache.Count

    /// A node in the linked list of cached counts for custom views.
    private struct Count {
        /// The type identifier for the cached view
        var id: ObjectIdentifier

        /// The cached count value.
        ///
        /// This is a double-optional:
        /// - `nil`: Not yet computed
        /// - `.some(nil)`: Explicitly has no static count (dynamic)
        /// - `.some(.some(n))`: Has a static count of n
        var count: Int??

        /// Pointer to the next count node in the linked list, or nil if this is the last node
        let next: UnsafeMutablePointer<Count>?

        init(id: ObjectIdentifier, count: Int?? = nil, next: UnsafeMutablePointer<Count>? = nil) {
            self.id = id
            self.count = count
            self.next = next
        }
    }
}

@available(*, unavailable)
extension CustomViewCountCache: Sendable {}
#endif
