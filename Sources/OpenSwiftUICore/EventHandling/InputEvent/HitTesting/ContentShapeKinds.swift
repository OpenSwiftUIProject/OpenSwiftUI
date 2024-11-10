//
//  ContentShapeKinds.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

import Foundation

/// A kind for the content shape of a view.
///
/// The kind is used by the system to influence various effects, hit-testing,
/// and more.
public struct ContentShapeKinds: OptionSet, Sendable {

    /// The corresponding value of the raw type.
    ///
    /// A new instance initialized with `rawValue` will be equivalent to this
    /// instance. For example:
    ///
    ///     enum PaperSize: String {
    ///         case A4, A5, Letter, Legal
    ///     }
    ///
    ///     let selectedSize = PaperSize.Letter
    ///     print(selectedSize.rawValue)
    ///     // Prints "Letter"
    ///
    ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
    ///     // Prints "true"
    public var rawValue: Int

    /// Creates a content shape kind.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The kind for hit-testing and accessibility.
    ///
    /// Setting a content shape with this kind causes the view to hit-test
    /// using the specified shape.
    public static let interaction: ContentShapeKinds = ContentShapeKinds(rawValue: 1 << 0)

    /// The kind for drag and drop previews.
    ///
    /// When using this kind, only the preview shape is affected. To control the
    /// shape used to hit-test and start the drag preview, use the `interaction`
    /// kind.
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public static let dragPreview: ContentShapeKinds = ContentShapeKinds(rawValue: 1 << 1)

    /// The kind for context menu previews.
    ///
    /// When using this kind, only the preview shape will be affected. To
    /// control the shape used to hit-test and start the context menu
    /// presentation, use the `.interaction` kind.
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public static let contextMenuPreview: ContentShapeKinds = ContentShapeKinds(rawValue: 1 << 2)

    /// The kind for hover effects.
    ///
    /// When using this kind, only the preview shape is affected. To control
    /// the shape used to hit-test and start the effect, use the `interaction`
    /// kind.
    ///
    /// This kind does not affect the `onHover` modifier.
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public static let hoverEffect: ContentShapeKinds = ContentShapeKinds(rawValue: 1 << 3)

    /// The kind for accessibility visuals and sorting.
    ///
    /// Setting a content shape with this kind causes the accessibility frame
    /// and path of the view's underlying accessibility element to match the
    /// shape without adjusting the hit-testing shape, updating the visual focus
    /// ring that assistive apps, such as VoiceOver, draw, as well as how the
    /// element is sorted. Updating the accessibility shape is only required if
    /// the shape or size used to hit-test significantly diverges from the visual
    /// shape of the view.
    ///
    /// To control the shape for accessibility and hit-testing, use the `interaction` kind.
    public static let accessibility: ContentShapeKinds = ContentShapeKinds(rawValue: 1 << 4)
}
