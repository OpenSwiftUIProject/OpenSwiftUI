//
//  NSViewRepresentable.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by Animation
//  ID: 38FE679A85C91B802D25DB73BF37B09F (SwiftUI)

#if os(macOS)

public import AppKit
public import OpenSwiftUICore
import OpenAttributeGraphShims

// MARK: - NSViewRepresentable

/// A wrapper that you use to integrate an AppKit view into your SwiftUI view
/// hierarchy.
///
/// Use an `NSViewRepresentable` instance to create and manage an
/// [NSView](https://developer.apple.com/documentation/appkit/nsview) object in your OpenSwiftUI
/// interface. Adopt this protocol in one of your app's custom instances, and
/// use its methods to create, update, and tear down your view. The creation and
/// update processes parallel the behavior of OpenSwiftUI views, and you use them to
/// configure your view with your app's current state information. Use the
/// teardown process to remove your view cleanly from your OpenSwiftUI. For example,
/// you might use the teardown process to notify other objects that the view is
/// disappearing.
///
/// To add your view into your OpenSwiftUI interface, create your
/// ``NSViewRepresentable`` instance and add it to your OpenSwiftUI interface. The
/// system calls the methods of your representable instance at appropriate times
/// to create and update the view. The following example shows the inclusion of
/// a custom `MyRepresentedCustomView` struct in the view hierarchy.
///
///     struct ContentView: View {
///        var body: some View {
///           VStack {
///              Text("Global Sales")
///              MyRepresentedCustomView()
///           }
///        }
///     }
///
/// The system doesn't automatically communicate changes occurring within your
/// view controller to other parts of your OpenSwiftUI interface. When you want your
/// view controller to coordinate with other OpenSwiftUI views, you must provide a
/// ``NSViewControllerRepresentable/Coordinator`` object to facilitate those
/// interactions. For example, you use a coordinator to forward target-action
/// and delegate messages from your view controller to any OpenSwiftUI views.
///
/// - Warning: OpenSwiftUI fully controls the layout of the AppKit view using the view's
/// [frame](https://developer.apple.com/documentation/appkit/nsview/1483713-frame) and
/// [bounds](https://developer.apple.com/documentation/appkit/nsview/1483817-bounds)
/// properties. Don't directly set these layout-related properties on the view
/// managed by an `NSViewRepresentable` instance from your own
/// code because that conflicts with OpenSwiftUI and results in undefined behavior.
@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@preconcurrency
@MainActor
public protocol NSViewRepresentable: View where Body == Never {
    /// The type of view to present.
    associatedtype NSViewType: NSView

    /// Creates the view object and configures its initial state.
    ///
    /// You must implement this method and use it to create your view object.
    /// Configure the view using your app's current data and contents of the
    /// `context` parameter. The system calls this method only once, when it
    /// creates your view for the first time. For all subsequent updates, the
    /// system calls the ``NSViewRepresentable/updateNSView(_:context:)``
    /// method.
    ///
    /// - Parameter context: A context structure containing information about
    ///   the current state of the system.
    ///
    /// - Returns: Your AppKit view configured with the provided information.
    func makeNSView(context: Context) -> NSViewType

    /// Updates the state of the specified view with new information from
    /// OpenSwiftUI.
    ///
    /// When the state of your app changes, OpenSwiftUI updates the portions of your
    /// interface affected by those changes. OpenSwiftUI calls this method for any
    /// changes affecting the corresponding AppKit view. Use this method to
    /// update the configuration of your view to match the new state information
    /// provided in the `context` parameter.
    ///
    /// - Parameters:
    ///   - nsView: Your custom view object.
    ///   - context: A context structure containing information about the current
    ///     state of the system.
    func updateNSView(_ nsView: NSViewType, context: Context)

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    func _resetNSView(_ nsView: NSViewType, coordinator: Coordinator, destroy: () -> Void)


    /// Cleans up the presented AppKit view (and coordinator) in anticipation of
    /// their removal.
    ///
    /// Use this method to perform additional clean-up work related to your
    /// custom view. For example, you might use this method to remove observers
    /// or update other parts of your OpenSwiftUI interface.
    ///
    /// - Parameters:
    ///   - nsView: Your custom view object.
    ///   - coordinator: The custom coordinator you use to communicate changes
    ///     back to SwiftUI. If you do not use a custom coordinator instance, the
    ///     system provides a default instance.
    static func dismantleNSView(_ nsView: NSViewType, coordinator: Coordinator)

    /// A type to coordinate with the view.
    associatedtype Coordinator = Void

    /// Creates the custom instance that you use to communicate changes from
    /// your view to other parts of your OpenSwiftUI interface.
    ///
    /// Implement this method if changes to your view might affect other parts
    /// of your app. In your implementation, create a custom Swift instance that
    /// can communicate with other parts of your interface. For example, you
    /// might provide an instance that binds its variables to OpenSwiftUI
    /// properties, causing the two to remain synchronized. If your view doesn't
    /// interact with other parts of your app, you don't have to provide a
    /// coordinator.
    ///
    /// SwiftUI calls this method before calling the
    /// ``NSViewRepresentable/makeNSView(context:)`` method. The system provides
    /// your coordinator instance either directly or as part of a context
    /// structure when calling the other methods of your representable instance.
    func makeCoordinator() -> Coordinator

    /// Returns the tree of identified views within the platform view.
    func _identifiedViewTree(in nsView: NSViewType) -> _IdentifiedViewTree

    /// Given a proposed size, returns the preferred size of the composite view.
    ///
    /// This method may be called more than once with different proposed sizes
    /// during the same layout pass. SwiftUI views choose their own size, so one
    /// of the values returned from this function will always be used as the
    /// actual size of the composite view.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the view.
    ///   - nsView: Your custom view object.
    ///   - context: A context structure containing information about the
    ///     current state of the system.
    ///
    /// - Returns: The composite size of the represented view controller.
    ///   Returning a value of `nil` indicates that the system should use the
    ///   default sizing algorithm.
    @available(OpenSwiftUI_v4_0, *)
    @MainActor
    @preconcurrency
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: NSViewType,
        context: Context
    ) -> CGSize?

    /// Overrides the default size-that-fits.
    func _overrideSizeThatFits(
        _ size: inout CGSize,
        in proposedSize: _ProposedSize,
        nsView: NSViewType
    )

    /// Custom layoutTraits hook.
    func _overrideLayoutTraits(
        _ layoutTraits: inout _LayoutTraits,
        for nsView: NSViewType
    )

    /// Modify inherited view inputs that would be inherited by any contained
    /// host views.
    ///
    /// This specifically allows those inputs to be modified at the bridging
    /// point between representable and inner host, which is distinct from the
    /// inputs provided to the view representable view itself, as well as from
    /// the inputs constructed by a child host (though is used as a set of
    /// partial inputs for the latter).
    @available(OpenSwiftUI_v2_3, *)
    static func _modifyBridgedViewInputs(_ inputs: inout _ViewInputs)

    @available(OpenSwiftUI_v4_0, *)
    static var _invalidatesSizeOnConstraintChanges: Bool { get }

    /// Provides options for the specified platform view, which can be used to
    /// drive the bridging implementation for the representable.
    @available(OpenSwiftUI_v4_0, *)
    static func _layoutOptions(_ provider: NSViewType) -> LayoutOptions

    typealias Context = NSViewRepresentableContext<Self>

    @available(OpenSwiftUI_v4_0, *)
    typealias LayoutOptions = _PlatformViewRepresentableLayoutOptions
}

// MARK: - NSViewRepresentable + Extension

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSViewRepresentable where Coordinator == () {
    public func makeCoordinator() -> Coordinator {
        _openSwiftUIEmptyStub()
    }
}

@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSViewRepresentable {
    @available(OpenSwiftUI_v3_0, *)
    public func _resetNSView(
        _ nsView: NSViewType,
        coordinator: Coordinator,
        destroy: () -> Void
    ) {
        destroy()
    }

    public static func dismantleNSView(
        _ nsView: NSViewType,
        coordinator: Coordinator
    ) {
        _openSwiftUIEmptyStub()
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        typealias Adapter = PlatformViewRepresentableAdaptor<Self>
        precondition(isLinkedOnOrAfter(.v4) ? Metadata(Self.self).isValueType : true, "NSViewRepresentables must be value types: \(Self.self)")
        return Adapter._makeView(view: view.unsafeBitCast(to: Adapter.self), inputs: inputs)
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        .unaryViewList(view: view, inputs: inputs)
    }

    public func _identifiedViewTree(
        in nsView: NSViewType
    ) -> _IdentifiedViewTree {
        .empty
    }

    @available(OpenSwiftUI_v4_0, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: NSViewType,
        context: Context
    ) -> CGSize? {
        nil
    }

    public func _overrideSizeThatFits(
        _ size: inout CGSize,
        in proposedSize: _ProposedSize,
        nsView: NSViewType
    ) {
        _openSwiftUIEmptyStub()
    }


    public func _overrideLayoutTraits(
        _ layoutTraits: inout _LayoutTraits,
        for nsView: NSViewType
    ) {
        _openSwiftUIEmptyStub()
    }

    @available(OpenSwiftUI_v2_3, *)
    public static func _modifyBridgedViewInputs(
        _ inputs: inout _ViewInputs
    ) {
        _openSwiftUIEmptyStub()
    }

    @available(OpenSwiftUI_v4_0, *)
    public static var _invalidatesSizeOnConstraintChanges: Bool {
        true
    }

    @available(OpenSwiftUI_v4_0, *)
    public static func _layoutOptions(
        _ provider: NSViewType
    ) -> LayoutOptions {
        .init(rawValue: 1)
    }

    public var body: Never {
        bodyError()
    }
}

// MARK: - PlatformViewRepresentableAdaptor

private struct PlatformViewRepresentableAdaptor<Base>: PlatformViewRepresentable where Base: NSViewRepresentable {
    var base: Base

    typealias PlatformViewProvider = Base.NSViewType

    typealias Coordinator = Base.Coordinator
    
    static var dynamicProperties: DynamicPropertyCache.Fields {
        DynamicPropertyCache.fields(of: Base.self)
    }

    func makeViewProvider(context: Context) -> PlatformViewProvider {
        base.makeNSView(context: .init(context))
    }

    func updateViewProvider(_ provider: PlatformViewProvider, context: Context) {
        base.updateNSView(provider, context: .init(context))
    }

    func resetViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator, destroy: () -> Void) {
        base._resetNSView(provider, coordinator: coordinator, destroy: destroy)
    }

    static func dismantleViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator) {
        Base.dismantleNSView(provider, coordinator: coordinator)
    }

    func makeCoordinator() -> Coordinator {
        base.makeCoordinator()
    }

    func _identifiedViewTree(in provider: PlatformViewProvider) -> _IdentifiedViewTree {
        base._identifiedViewTree(in: provider)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, provider: PlatformViewProvider, context: Context) -> CGSize? {
        base.sizeThatFits(proposal, nsView: provider, context: .init(context))
    }

    func overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, platformView: PlatformViewProvider) {
        base._overrideSizeThatFits(&size, in: proposedSize, nsView: platformView)
    }

    func overrideLayoutTraits(_ traits: inout _LayoutTraits, for provider: PlatformViewProvider) {
        base._overrideLayoutTraits(&traits, for: provider)
    }

    static func modifyBridgedViewInputs(_ inputs: inout _ViewInputs) {
        Base._modifyBridgedViewInputs(&inputs)
    }

    static func shouldEagerlyUpdateSafeArea(_ provider: Base.NSViewType) -> Bool {
        false
    }

    static func layoutOptions(_ provider: PlatformViewProvider) -> LayoutOptions {
        Base._layoutOptions(provider)
    }
}

// MARK: - NSViewRepresentableContext

/// Contextual information about the state of the system that you use to create
/// and update your AppKit view.
///
/// An ``NSViewRepresentableContext`` structure contains details about the
/// current state of the system. When creating and updating your view, the
/// system creates one of these structures and passes it to the appropriate
/// method of your custom ``NSViewRepresentable`` instance. Use the information
/// in this structure to configure your view. For example, use the provided
/// environment values to configure the appearance of your view. Don't create
/// this structure yourself.
@available(OpenSwiftUI_v1_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
@preconcurrency
@MainActor
public struct NSViewRepresentableContext<View> where View: NSViewRepresentable {
    var values: RepresentableContextValues

    /// An instance you use to communicate your AppKit view's behavior and state
    /// out to OpenSwiftUI objects.
    ///
    /// The coordinator is a custom instance you define. When updating your
    /// view, communicate changes to OpenSwiftUI by updating the properties of your
    /// coordinator, or by calling relevant methods to make those changes. The
    /// implementation of those properties and methods are responsible for
    /// updating the appropriate SwiftUI values. For example, you might define a
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
    /// ``NSViewRepresentable/makeCoordinator()`` method of your
    /// ``NSViewRepresentable`` object.
    public let coordinator: View.Coordinator

    /// The current transaction.
    public var transaction: Transaction {
        values.transaction
    }

    /// Environment data that describes the current state of the system.
    ///
    /// Use the environment values to configure the state of your view when
    /// creating or updating it.
    public var environment: EnvironmentValues {
        switch values.environmentStorage {
        case let .eager(environmentValues):
            environmentValues
        case let .lazy(attribute, anyRuleContext):
            Update.ensure { anyRuleContext[attribute] }
        }
    }

    init<R>(_ context: PlatformViewRepresentableContext<R>) where R: PlatformViewRepresentable, R.Coordinator == View.Coordinator {
        values = context.values
        coordinator = context.coordinator
    }
}

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension NSViewRepresentableContext {
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
    ///     struct MyRepresentable: NSViewRepresentable {
    ///         @Binding var isCollapsed: Bool
    ///
    ///         func updateNSView(_ nsView: NSViewType, context: Context) {
    ///             if isCollapsed && !nsView.isCollapsed {
    ///                 context.animate {
    ///                     nsView.collapseSubview()
    ///                     nsView.layoutSubtreeIfNeeded()
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
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
