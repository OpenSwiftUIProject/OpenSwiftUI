//
//  ViewSize.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

package struct ViewSize: Equatable {
    package var value: CGSize
    var _proposal: CGSize
    
    @inline(__always)
    init(value: CGSize, proposal: CGSize) {
        self.value = value
        self._proposal = proposal
    }
    
    @inlinable
    package init(_ size: CGSize, proposal: _ProposedSize) {
        self.value = size
        self._proposal = CGSize(width: proposal.width ?? .nan, height: proposal.height ?? .nan)
    }
    
    @inlinable
    package static func fixed(_ size: CGSize) -> ViewSize {
        self.init(value: size, proposal: size)
    }
    
    @inlinable
    package var width: CGFloat {
        get { value.width }
        set { value.width = newValue }
    }
    
    @inlinable
    package var height: CGFloat {
        get { value.height }
        set { value.height = newValue }
    }
    
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
    
    package mutating func didSetAnimatableData(_ value: CGSize) {
        _proposal = value
    }
    
    package static var zero: ViewSize { .fixed(.zero) }
    package static var invalidValue: ViewSize { .fixed(.invalidValue) }
}

extension ViewSize {
    package subscript(d: Axis) -> CGFloat {
        get { d == .horizontal ? width : height }
        set { if d == .horizontal { width = newValue } else { height = newValue } }
    }
    
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
    package var animatableData: CGSize.AnimatableData {
        get { value.animatableData }
        set { value.animatableData = newValue }
    }
}

package import OpenGraphShims

extension Attribute where Value == ViewSize {
    package var cgSize: Attribute<CGSize> {
        self[keyPath: \.value]
    }
}
