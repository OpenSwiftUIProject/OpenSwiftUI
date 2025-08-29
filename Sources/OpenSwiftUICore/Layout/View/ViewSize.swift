//
//  ViewSize.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation
package import OpenAttributeGraphShims

/// A structure that represents the size of a view and its associated size proposal.
///
/// `ViewSize` encapsulates both the actual size of a view and the proposal that led to that size,
/// allowing the layout system to track relationships between proposed and actual sizes.
package struct ViewSize: Equatable {
    /// The actual size of the view.
    package var value: CGSize

    /// The proposed size that led to this view size.
    ///
    /// Uses NaN values to represent nil dimensions in the proposal.
    private(set) var _proposal: CGSize

    /// Creates a new view size with the specified value and proposal.
    ///
    /// - Parameters:
    ///   - value: The actual size of the view.
    ///   - proposal: The proposed size that led to this view size.
    @inline(__always)
    init(value: CGSize, proposal: CGSize) {
        self.value = value
        self._proposal = proposal
    }
    
    /// Creates a new view size from a size and proposed size.
    ///
    /// This initializer converts the optional dimensions in `_ProposedSize` to CGSize
    /// using NaN values to represent nil dimensions.
    ///
    /// - Parameters:
    ///   - size: The actual size of the view.
    ///   - proposal: The proposed size with optional dimensions.
    @inlinable
    package init(_ size: CGSize, proposal: _ProposedSize) {
        self.value = size
        self._proposal = CGSize(width: proposal.width ?? .nan, height: proposal.height ?? .nan)
    }
    
    /// Creates a fixed size view where both the actual and proposed sizes are identical.
    ///
    /// - Parameter size: The size to use for both the actual and proposed size.
    /// - Returns: A new `ViewSize` with identical actual and proposed dimensions.
    @inlinable
    package static func fixed(_ size: CGSize) -> ViewSize {
        self.init(value: size, proposal: size)
    }
    
    /// The width component of the view's size.
    @inlinable
    package var width: CGFloat {
        get { value.width }
        set { value.width = newValue }
    }
    
    /// The height component of the view's size.
    @inlinable
    package var height: CGFloat {
        get { value.height }
        set { value.height = newValue }
    }
    
    /// The proposed size that led to this view size.
    ///
    /// This property provides access to the proposal as a `_ProposedSize` instance,
    /// converting NaN values in the internal representation to nil values as appropriate.
    @inlinable
    package var proposal: _ProposedSize {
        get {
            _ProposedSize(
                width: _proposal.width.isNaN ? nil : _proposal.width,
                height: _proposal.height.isNaN ? nil : _proposal.height
            )
        }
        set {
            _proposal = CGSize(width: newValue.width ?? .nan, height: newValue.height ?? .nan)
        }
    }
    
    /// Updates the proposal based on animatable data.
    ///
    /// This method is called during animations to update the view's proposal.
    ///
    /// - Parameter value: The new proposed size value.
    package mutating func didSetAnimatableData(_ value: CGSize) {
        _proposal = value
    }

    package static func == (lhs: ViewSize, rhs: ViewSize) -> Bool {
        lhs.value == rhs.value && lhs._proposal == rhs._proposal
    }

    /// A view size with zero dimensions.
    package static var zero: ViewSize { .fixed(.zero) }
    
    /// A view size representing an invalid value.
    package static var invalidValue: ViewSize { .fixed(.invalidValue) }
}

extension ViewSize {
    /// Accesses the width or height of the view size based on the specified axis.
    ///
    /// - Parameter d: The axis to access (horizontal for width, vertical for height).
    /// - Returns: The size component corresponding to the specified axis.
    package subscript(d: Axis) -> CGFloat {
        get { d == .horizontal ? width : height }
        set { if d == .horizontal { width = newValue } else { height = newValue } }
    }
    
    /// Creates a new view size by applying edge insets to the current size.
    ///
    /// This method reduces the view's dimensions by the specified insets,
    /// ensuring the resulting size is never negative.
    ///
    /// - Parameter insets: The edge insets to apply.
    /// - Returns: A new view size that has been inset by the specified amounts.
    package func inset(by insets: EdgeInsets) -> ViewSize {
        let newWidth = max(value.width - (insets.leading + insets.trailing), 0)
        let newHeight = max(value.height - (insets.top + insets.bottom), 0)
        return ViewSize(
            value: CGSize(width: newWidth, height: newHeight),
            proposal: CGSize(
                width: newWidth.isNaN ? 0 : newWidth,
                height: newHeight.isNaN ? 0 : newHeight
            )
        )
    }
}

extension ViewSize: Animatable {
    /// The animatable data for the view size.
    ///
    /// This property allows the size to be animated smoothly between values.
    package var animatableData: CGSize.AnimatableData {
        get { value.animatableData }
        set { value.animatableData = newValue }
    }
}

extension Attribute where Value == ViewSize {
    /// Converts a `ViewSize` attribute to a `CGSize` attribute by extracting the value.
    ///
    /// This property enables working with the concrete size value while maintaining
    /// attribute semantics.
    package var cgSize: Attribute<CGSize> {
        self[keyPath: \.value]
    }
}
