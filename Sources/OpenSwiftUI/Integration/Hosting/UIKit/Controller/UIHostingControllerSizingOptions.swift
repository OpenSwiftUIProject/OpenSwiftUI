//
//  UIHostingControllerSizingOptions.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

#if os(iOS) || os(visionOS)

/// Options for how a hosting controller tracks its content’s size.
@available(macOS, unavailable)
public struct UIHostingControllerSizingOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// The hosting controller tracks its content's ideal size in its
    /// preferred content size.
    ///
    /// Use this option when using a hosting controller with a container view
    /// controller that requires up-to-date knowledge of the hosting
    /// controller's ideal size.
    ///
    /// - Note: This option comes with a performance cost because it
    ///   asks for the ideal size of the content using the
    ///   ``ProposedViewSize/unspecified`` size proposal.
    public static let preferredContentSize: UIHostingControllerSizingOptions = .init(rawValue: 1 << 0)
    
    /// The hosting controller's view automatically invalidate its intrinsic
    /// content size when its ideal size changes.
    ///
    /// Use this option when the hosting controller's view is being laid out
    /// with Auto Layout.
    ///
    /// - Note: This option comes with a performance cost because it
    ///   asks for the ideal size of the content using the
    ///   ``ProposedViewSize/unspecified`` size proposal.
    public static let intrinsicContentSize: UIHostingControllerSizingOptions = .init(rawValue: 1 << 1)
}

#endif
