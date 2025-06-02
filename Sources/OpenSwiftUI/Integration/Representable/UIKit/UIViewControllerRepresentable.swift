//
//  UIViewControllerRepresentable.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: F0196C17270D74A1F1A35F1926215FB3 (SwiftUI)

#if os(iOS)

public import UIKit
public import OpenSwiftUICore
import OpenGraphShims

// MARK: - UIViewControllerRepresentable

/// A view that represents a UIKit view controller.
///
/// Use a ``UIViewControllerRepresentable`` instance to create and manage a
/// [UIViewController](https://developer.apple.com/documentation/UIKit/UIViewController) object in your
/// OpenSwiftUI interface. Adopt this protocol in one of your app's custom
/// instances, and use its methods to create, update, and tear down your view
/// controller. The creation and update processes parallel the behavior of
/// OpenSwiftUI views, and you use them to configure your view controller with your
/// app's current state information. Use the teardown process to remove your
/// view controller cleanly from your OpenSwiftUI. For example, you might use the
/// teardown process to notify other objects that the view controller is
/// disappearing.
///
/// To add your view controller into your OpenSwiftUI interface, create your
/// ``UIViewControllerRepresentable`` instance and add it to your OpenSwiftUI
/// interface. The system calls the methods of your custom instance at
/// appropriate times.
///
/// The system doesn't automatically communicate changes occurring within your
/// view controller to other parts of your OpenSwiftUI interface. When you want your
/// view controller to coordinate with other OpenSwiftUI views, you must provide a
/// ``UIViewControllerRepresentable/Coordinator`` instance to facilitate those
/// interactions. For example, you use a coordinator to forward target-action
/// and delegate messages from your view controller to any OpenSwiftUI views.
///
/// - Warning: OpenSwiftUI fully controls the layout of the UIKit view controller's
/// view using the view's
/// [center](https://developer.apple.com/documentation/UIKit/UIView/1622627-center),
/// [bounds](https://developer.apple.com/documentation/UIKit/UIView/1622580-bounds),
/// [frame](https://developer.apple.com/documentation/UIKit/UIView/1622621-frame), and
/// [transform](https://developer.apple.com/documentation/UIKit/UIView/1622459-transform)
/// properties. Don't directly set these layout-related properties on the view
/// managed by a `UIViewControllerRepresentable` instance from your own
/// code because that conflicts with OpenSwiftUI and results in undefined behavior.
@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor
@preconcurrency
public protocol UIViewControllerRepresentable: View where Body == Never {
    /// The type of view controller to present.
    associatedtype UIViewControllerType: UIViewController

    /// Creates the view controller object and configures its initial state.
    ///
    /// You must implement this method and use it to create your view controller
    /// object. Create the view controller using your app's current data and
    /// contents of the `context` parameter. The system calls this method only
    /// once, when it creates your view controller for the first time. For all
    /// subsequent updates, the system calls the
    /// ``UIViewControllerRepresentable/updateUIViewController(_:context:)``
    /// method.
    ///
    /// - Parameter context: A context structure containing information about
    ///   the current state of the system.
    ///
    /// - Returns: Your UIKit view controller configured with the provided
    ///   information.
    func makeUIViewController(context: Context) -> UIViewControllerType

    /// Updates the state of the specified view controller with new information
    /// from OpenSwiftUI.
    ///
    /// When the state of your app changes, OpenSwiftUI updates the portions of your
    /// interface affected by those changes. OpenSwiftUI calls this method for any
    /// changes affecting the corresponding UIKit view controller. Use this
    /// method to update the configuration of your view controller to match the
    /// new state information provided in the `context` parameter.
    ///
    /// - Parameters:
    ///   - uiViewController: Your custom view controller object.
    ///   - context: A context structure containing information about the current
    ///     state of the system.
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context)

    @_spi(Private)
    func _resetUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator, destroy: () -> Void)

    /// Cleans up the presented view controller (and coordinator) in
    /// anticipation of their removal.
    ///
    /// Use this method to perform additional clean-up work related to your
    /// custom view controller. For example, you might use this method to remove
    /// observers or update other parts of your OpenSwiftUI interface.
    ///
    /// - Parameters:
    ///   - uiViewController: Your custom view controller object.
    ///   - coordinator: The custom coordinator instance you use to communicate
    ///     changes back to OpenSwiftUI. If you do not use a custom coordinator, the
    ///     system provides a default instance.
    static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator)

    /// A type to coordinate with the view controller.
    associatedtype Coordinator = Void

    /// Creates the custom instance that you use to communicate changes from
    /// your view controller to other parts of your OpenSwiftUI interface.
    ///
    /// Implement this method if changes to your view controller might affect
    /// other parts of your app. In your implementation, create a custom Swift
    /// instance that can communicate with other parts of your interface. For
    /// example, you might provide an instance that binds its variables to
    /// OpenSwiftUI properties, causing the two to remain synchronized. If your view
    /// controller doesn't interact with other parts of your app, providing a
    /// coordinator is unnecessary.
    ///
    /// OpenSwiftUI calls this method before calling the
    /// ``UIViewControllerRepresentable/makeUIViewController(context:)`` method.
    /// The system provides your coordinator either directly or as part of a
    /// context structure when calling the other methods of your representable
    /// instance.
    func makeCoordinator() -> Coordinator

    /// Given a proposed size, returns the preferred size of the composite view.
    ///
    /// This method may be called more than once with different proposed sizes
    /// during the same layout pass. OpenSwiftUI views choose their own size, so one
    /// of the values returned from this function will always be used as the
    /// actual size of the composite view.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the view controller.
    ///   - uiViewController: Your custom view controller object.
    ///   - context: A context structure containing information about the
    ///     current state of the system.
    ///
    /// - Returns: The composite size of the represented view controller.
    ///   Returning a value of `nil` indicates that the system should use the
    ///   default sizing algorithm.
    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: UIViewControllerType, context: Context) -> CGSize?

    /// Returns the tree of identified views within the platform view.
    func _identifiedViewTree(in uiViewController: UIViewControllerType) -> _IdentifiedViewTree

    /// Provides options for the specified platform view, which can be used to
    /// drive the bridging implementation for the representable.
    static func _layoutOptions(_ provider: UIViewControllerType) -> LayoutOptions

    typealias Context = UIViewControllerRepresentableContext<Self>

    typealias LayoutOptions = _PlatformViewRepresentableLayoutOptions
}

// MARK: - UIViewControllerRepresentable + Extension

@available(macOS, unavailable)
extension UIViewControllerRepresentable where Coordinator == () {
    public func makeCoordinator() -> Coordinator {
        return
    }
}

@available(macOS, unavailable)
extension UIViewControllerRepresentable {
    public func _resetUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator, destroy: () -> Void) {
        destroy()
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: UIViewControllerType, context: Context) -> CGSize? { nil }

    public static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {}

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        preconditionFailure("TODO")
    }

    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        .unaryViewList(view: view, inputs: inputs)
    }

    public func _identifiedViewTree(in uiViewController: UIViewControllerType) -> _IdentifiedViewTree { .empty }

    // FIXME
    public static func _layoutOptions(_ provider: UIViewControllerType) -> LayoutOptions { .init(rawValue: 1) }

    /// Declares the content and behavior of this view.
    public var body: Never {
        bodyError()
    }
}

// MARK: - UnsupportedDisplayList

private struct UnsupportedDisplayList: Rule {
    var identity: DisplayList.Identity
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var containerPosition: ViewOrigin

    var value: DisplayList {
        let version = DisplayList.Version(forUpdate: ())
        let seed = DisplayList.Seed(version)
        let position = position
        let containerPosition = containerPosition
        let size = size.value
        preconditionFailure("TODO: EmptyViewFactory")
    }
}

/// Contextual information about the state of the system that you use to create
/// and update your UIKit view controller.
///
/// A ``UIViewControllerRepresentableContext`` structure contains details about
/// the current state of the system. When creating and updating your view
/// controller, the system creates one of these structures and passes it to the
/// appropriate method of your custom ``UIViewControllerRepresentable``
/// instance. Use the information in this structure to configure your view
/// controller. For example, use the provided environment values to configure
/// the appearance of your view controller and views. Don't create this
/// structure yourself.
@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor
@preconcurrency
public struct UIViewControllerRepresentableContext<Representable> where Representable: UIViewControllerRepresentable {
    /// The view's associated coordinator.
    public let coordinator: Representable.Coordinator

    /// The current transaction.
    public private(set) var transaction: Transaction

    /// Environment values that describe the current state of the system.
    ///
    /// Use the environment values to configure the state of your UIKit view
    /// controller when creating or updating it.
    public private(set) var environment: EnvironmentValues

    var preferenceBridge: PreferenceBridge?

    init<R>(_ context: PlatformViewRepresentableContext<R>) where R: PlatformViewRepresentable, R.Coordinator == Representable.Coordinator {
        coordinator = context.coordinator
        transaction = context.values.transaction
        environment = context.environment
        preferenceBridge = context.values.preferenceBridge
    }

    /// Animates changes using the animation in the current transaction.
    ///
    /// This combines [animate(with:changes:completion:)](https://developer.apple.com/documentation/uikit/uiview/4429628-animate)
    /// with the current transaction's animation. When you start an OpenSwiftUI
    /// animation using ``OpenSwiftUICore/withAnimation(_:_:)`` and have a mutated
    /// OpenSwiftUI state that causes the representable object to update, use
    /// this method to animate changes in the representable object using the
    /// same `Animation` timing.
    ///
    ///     struct ContentView: View {
    ///         @State private var isCollapsed = false
    ///         var body: some View {
    ///             ZStack {
    ///                 MyDetailView(isCollapsed: isCollapsed)
    ///                 MyRepresentable(isCollapsed: $isCollapsed)
    ///                 Button("Collapse Content") {
    ///                     withAnimation(.bouncy) {
    ///                         isCollapsed = true
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    ///     struct MyRepresentable: UIViewControllerRepresentable {
    ///         @Binding var isCollapsed: Bool
    ///
    ///         func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    ///             if isCollapsed && !uiViewController.view.isCollapsed {
    ///                 context.animate {
    ///                     uiViewController.collapseSubview()
    ///                     uiView.layout()
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - changes: A closure that changes animatable properties.
    ///   - completion: A closure to execute after the animation completes.
    public func animate(changes: () -> Void, completion: (() -> Void)? = nil) {
        guard let animation = transaction.animation, !transaction.disablesAnimations else {
            changes()
            completion?()
            return
        }
        // TODO
        // UIKitAnimationBridge.withAnimation
    }
}

#endif
