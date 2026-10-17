//
//  PreviewLayout.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if !canImport(DeveloperToolsSupport)
public import Foundation

/// A size constraint for a preview.
///
/// Customize the layout of a preview that you define using the
/// ``PreviewProvider`` protocol by providing one of the preview layout values
/// to the ``View/previewLayout(_:)`` view modifier. For example, you can tell
/// the preview to take up only the amount of space that the view requires with
/// ``sizeThatFits``:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             CircleImage()
///                 .previewLayout(.sizeThatFits)
///         }
///     }
///
/// > Note: When you migrate away from preview providers and to preview macros,
///   you specify layout using one of the ``PreviewTrait`` layout
///   values with a macro that takes traits, like
///   ``Preview(_:traits:_:body:)``.
@available(OpenSwiftUI_v1_0, *)
public enum PreviewLayout: Sendable {
    /// Center the preview in a container the size of the device on which the
    /// preview is running.
    case device

    /// Fit the container to the size of the preview when offered the size of
    /// the device that the preview is running on.
    case sizeThatFits

    /// Center the preview in a fixed size container with the given dimensions.
    ///
    /// - Parameters:
    ///   - width: The width of the container.
    ///   - height: The height of the container.
    case fixed(width: CGFloat, height: CGFloat)
}
#endif
