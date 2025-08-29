//
//  NSViewControllerRepresentable.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by Animation
//  ID: 4556D1CD30E6B037F91D6BB837A359A1 (SwiftUI)

#if os(macOS)

public import AppKit
public import OpenSwiftUICore
import OpenAttributeGraphShims

// MARK: - NSViewControllerRepresentable

/// A wrapper that you use to integrate an AppKit view controller into your
/// OpenSwiftUI interface.
///
/// Use an ``NSViewControllerRepresentable`` instance to create and manage an
/// [NSViewController](https://developer.apple.com/documentation/appkit/nsviewcontroller) object in your
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
/// `NSViewControllerRepresentable` instance and add it to your OpenSwiftUI
/// interface. The system calls the methods of your custom instance at
/// appropriate times.
///
/// The system doesn't automatically communicate changes occurring within your
/// view controller to other parts of your OpenSwiftUI interface. When you want your
/// view controller to coordinate with other OpenSwiftUI views, you must provide a
/// ``NSViewControllerRepresentable/Coordinator`` instance to facilitate those
/// interactions. For example, you use a coordinator to forward target-action
/// and delegate messages from your view controller to any OpenSwiftUI views.
///
/// - Warning: OpenSwiftUI fully controls the layout of the AppKit view
/// controller's view using the view's
/// [frame](https://developer.apple.com/documentation/appkit/nsview/1483713-frame) and
/// [bounds](https://developer.apple.com/documentation/appkit/nsview/1483817-bounds)
/// properties. Don't directly set these layout-related properties on the view
/// managed by an `NSViewControllerRepresentable` instance from your own
/// code because that conflicts with OpenSwiftUI and results in undefined behavior.
@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@MainActor
@preconcurrency
public protocol NSViewControllerRepresentable: View where Body == Never {
    /// The type of view controller to present.
    associatedtype NSViewControllerType: NSViewController

    /// Creates the view controller object and configures its initial state.
    ///
    /// You must implement this method and use it to create your view controller
    /// object. Create the view controller using your app's current data and
    /// contents of the `context` parameter. The system calls this method only
    /// once, when it creates your view controller for the first time. For all
    /// subsequent updates, the system calls the
    /// ``NSViewControllerRepresentable/updateNSViewController(_:context:)``
    /// method.
    ///
    /// - Parameter context: A context structure containing information about
    ///   the current state of the system.
    ///
    /// - Returns: Your AppKit view controller configured with the provided
    ///   information.
    func makeNSViewController(context: Context) -> NSViewControllerType

    /// Updates the state of the specified view controller with new information
    /// from OpenSwiftUI.
    ///
    /// When the state of your app changes, OpenSwiftUI updates the portions of your
    /// interface affected by those changes. OpenSwiftUI calls this method for any
    /// changes affecting the corresponding AppKit view controller. Use this
    /// method to update the configuration of your view controller to match the
    /// new state information provided in the `context` parameter.
    ///
    /// - Parameters:
    ///   - nsViewController: Your custom view controller object.
    ///   - context: A context structure containing information about the current
    ///     state of the system.
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context)

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    func _resetNSViewController(_ nsViewController: NSViewControllerType, coordinator: Coordinator, destroy: () -> Void)

    /// Cleans up the presented view controller (and coordinator) in
    /// anticipation of its removal.
    ///
    /// Use this method to perform additional clean-up work related to your
    /// custom view controller. For example, you might use this method to remove
    /// observers or update other parts of your OpenSwiftUI interface.
    ///
    /// - Parameters:
    ///   - nsViewController: Your custom view controller object.
    ///   - coordinator: The custom coordinator instance you use to communicate
    ///     changes back to OpenSwiftUI. If you do not use a custom coordinator, the
    ///     system provides a default instance.
    static func dismantleNSViewController(_ nsViewController: NSViewControllerType, coordinator: Coordinator)

    /// A type to coordinate with the view controller.
    associatedtype Coordinator = Void

    /// Creates the custom object that you use to communicate changes from your
    /// view controller to other parts of your OpenSwiftUI interface.
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
    /// ``NSViewControllerRepresentable/makeNSViewController(context:)`` method.
    /// The system provides your coordinator instance either directly or as part
    /// of a context structure when calling the other methods of your
    /// representable instance.
    func makeCoordinator() -> Coordinator

    func _identifiedViewTree(in nsViewController: NSViewControllerType) -> _IdentifiedViewTree

    /// Given a proposed size, returns the preferred size of the composite view.
    ///
    /// This method may be called more than once with different proposed sizes
    /// during the same layout pass. OpenSwiftUI views choose their own size, so one
    /// of the values returned from this function will always be used as the
    /// actual size of the composite view.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the view controller.
    ///   - nsViewController: Your custom view controller object.
    ///   - context: A context structure containing information about the
    ///     current state of the system.
    ///
    /// - Returns: The composite size of the represented view controller.
    ///   Returning a value of `nil` indicates that the system should use the
    ///   default sizing algorithm.
    @available(OpenSwiftUI_v4_0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, nsViewController: NSViewControllerType, context: Context) -> CGSize?

    @available(OpenSwiftUI_v4_0, *)
    static var _invalidatesSizeOnConstraintChanges: Bool { get }

    @available(OpenSwiftUI_v4_0, *)
    static func _layoutOptions(_ provider: NSViewControllerType) -> LayoutOptions

    typealias Context = NSViewControllerRepresentableContext<Self>

    @available(OpenSwiftUI_v4_0, *)
    typealias LayoutOptions = _PlatformViewRepresentableLayoutOptions
}

// MARK: - NSViewControllerRepresentable + Extension

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSViewControllerRepresentable where Coordinator == () {
    /// Creates an object to coordinate with the AppKit view controller.
    ///
    /// `Coordinator` can be accessed via `Context`.
    public func makeCoordinator() -> Coordinator {
        _openSwiftUIEmptyStub()
    }
}

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSViewControllerRepresentable {
    @available(OpenSwiftUI_v3_0, *)
    public func _resetNSViewController(
        _ nsViewController: NSViewControllerType,
        coordinator: Coordinator,
        destroy: () -> Void
    ) {
        destroy()
    }

    /// Cleans up the presented `NSViewController` (and coordinator) in
    /// anticipation of their removal.
    public static func dismantleNSViewController(
        _ nsViewController: NSViewControllerType,
        coordinator: Coordinator
    ) {
        _openSwiftUIEmptyStub()
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        typealias Adapter = PlatformViewRepresentableAdaptor<Self>
        precondition(isLinkedOnOrAfter(.v4) ? Metadata(Self.self).isValueType : true, "NSViewControllerRepresentables must be value types: \(Self.self)")
        let outputs = Adapter._makeView(view: view.unsafeBitCast(to: Adapter.self), inputs: inputs)
        return outputs
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        .unaryViewList(view: view, inputs: inputs)
    }

    public func _identifiedViewTree(
        in nsViewController: NSViewControllerType
    ) -> _IdentifiedViewTree {
        .empty
    }

    /// Given a proposed size, returns the preferred size of the composite view.
    ///
    /// This method may be called more than once with different proposed sizes
    /// during the same layout pass. OpenSwiftUI views choose their own size, so one
    /// of the values returned from this function will always be used as the
    /// actual size of the composite view.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the view controller.
    ///   - nsViewController: Your custom view controller object.
    ///   - context: A context structure containing information about the
    ///     current state of the system.
    ///
    /// - Returns: The composite size of the represented view controller.
    ///   Returning a value of `nil` indicates that the system should use the
    ///   default sizing algorithm.
    @available(OpenSwiftUI_v4_0, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsViewController: NSViewControllerType,
        context: Context
    ) -> CGSize? {
        nil
    }

    @available(OpenSwiftUI_v4_0, *)
    public static var _invalidatesSizeOnConstraintChanges: Bool {
        true
    }

    @available(OpenSwiftUI_v4_0, *)
    public static func _layoutOptions(_ provider: NSViewControllerType) -> LayoutOptions {
        .init(rawValue: 1)
    }

    /// Declares the content and behavior of this view.
    public var body: Never {
        bodyError()
    }
}

// MARK: - PlatformViewRepresentableAdaptor

private struct PlatformViewRepresentableAdaptor<Base>: PlatformViewRepresentable where Base: NSViewControllerRepresentable {
    var base: Base

    typealias PlatformViewProvider = Base.NSViewControllerType

    typealias Coordinator = Base.Coordinator

    static var dynamicProperties: DynamicPropertyCache.Fields {
        DynamicPropertyCache.fields(of: Base.self)
    }

    func makeViewProvider(context: Context) -> PlatformViewProvider {
        base.makeNSViewController(context: .init(context))
    }

    func updateViewProvider(_ provider: PlatformViewProvider, context: Context) {
        base.updateNSViewController(provider, context: .init(context))
    }

    func resetViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator, destroy: () -> Void) {
        base._resetNSViewController(provider, coordinator: coordinator, destroy: destroy)
    }

    static func dismantleViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator) {
        Base.dismantleNSViewController(provider, coordinator: coordinator)
    }

    func makeCoordinator() -> Coordinator {
        base.makeCoordinator()
    }

    func _identifiedViewTree(in provider: PlatformViewProvider) -> _IdentifiedViewTree {
        base._identifiedViewTree(in: provider)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, provider: PlatformViewProvider, context: Context) -> CGSize? {
        base.sizeThatFits(proposal, nsViewController: provider, context: .init(context))
    }

    func overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, platformView: PlatformViewProvider) {
        _openSwiftUIEmptyStub()
    }

    func overrideLayoutTraits(_ traits: inout _LayoutTraits, for provider: PlatformViewProvider) {
        _openSwiftUIEmptyStub()
    }

    static func modifyBridgedViewInputs(_ inputs: inout _ViewInputs) {
        _openSwiftUIEmptyStub()
    }

    static func shouldEagerlyUpdateSafeArea(_ provider: PlatformViewProvider) -> Bool {
        false
    }

    static func layoutOptions(_ provider: PlatformViewProvider) -> LayoutOptions {
        Base._layoutOptions(provider)
    }
}

/// Contextual information about the state of the system that you use to create
/// and update your AppKit view controller.
///
/// An ``NSViewControllerRepresentableContext`` structure contains details about
/// the current state of the system. When creating and updating your view
/// controller, the system creates one of these structures and passes it to the
/// appropriate method of your custom ``NSViewControllerRepresentable``
/// instance. Use the information in this structure to configure your view
/// controller. For example, use the provided environment values to configure
/// the appearance of your view controller and views. Don't create this
/// structure yourself.
@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct NSViewControllerRepresentableContext<ViewController> where ViewController: NSViewControllerRepresentable {
    var values: RepresentableContextValues

    /// An object you use to communicate your AppKit view controller's behavior
    /// and state out to OpenSwiftUI objects.
    ///
    /// The coordinator is a custom object you define. When updating your view
    /// controller, communicate changes to OpenSwiftUI by updating the properties of
    /// your coordinator, or by calling relevant methods to make those changes.
    /// The implementation of those properties and methods are responsible for
    /// updating the appropriate OpenSwiftUI values. For example, you might define a
    /// property in your coordinator that binds to a OpenSwiftUI value, as shown in
    /// the following code example. Changing the property updates the value of
    /// the corresponding OpenSwiftUI variable.
    ///
    ///     class Coordinator: NSObject {
    ///        @Binding var rating: Int
    ///        init(rating: Binding<Int>) {
    ///           $rating = rating
    ///        }
    ///     }
    ///
    /// To create and configure your custom coordinator, implement the
    /// ``NSViewControllerRepresentable/makeCoordinator()`` method of your
    /// ``NSViewControllerRepresentable`` object.
    public let coordinator: ViewController.Coordinator

    /// The current transaction.
    public var transaction: Transaction {
        values.transaction
    }

    /// Environment data that describes the current state of the system.
    ///
    /// Use the environment values to configure the state of your view
    /// controller when creating or updating it.
    public var environment: EnvironmentValues {
        switch values.environmentStorage {
        case let .eager(environmentValues):
            environmentValues
        case let .lazy(attribute, anyRuleContext):
            Update.ensure { anyRuleContext[attribute] }
        }
    }

    init<R>(_ context: PlatformViewRepresentableContext<R>) where R: PlatformViewRepresentable, R.Coordinator == ViewController.Coordinator {
        values = context.values
        coordinator = context.coordinator
    }
}

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSViewControllerRepresentableContext {
    /// Animates changes using the animation in the current transaction.
    ///
    /// This combines
    /// [animate(with:changes:completion:)](https://developer.apple.com/documentation/appkit/nsanimationcontext/4433144-animate)
    /// with the current transaction's animation. When you start a OpenSwiftUI
    /// animation using ``OpenSwiftUI/withAnimation(_:_:)`` and have a mutated
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
    ///     struct MyRepresentable: NSViewControllerRepresentable {
    ///         @Binding var isCollapsed: Bool
    ///
    ///         func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    ///             if isCollapsed && !nsViewController.view.isCollapsed {
    ///                 context.animate {
    ///                     nsViewController.view.collapseSubview()
    ///                     nsViewController.view.layoutSubtreeIfNeeded()
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - changes: A closure that changes animatable properties.
    ///   - completion: A closure to execute after the animation completes.
    public func animate(changes: () -> Void, completion: (() -> Void)? = nil) {
        if let animation = transaction.animation,
           !transaction.disablesAnimations
        {
            // TODO: OpenSwiftUI + AppKit shims
//            NSAnimationContext.animate(animation, changes: changes,
//                completion: completion)
        } else {
            changes()
            completion?()
        }
    }
}

#endif
