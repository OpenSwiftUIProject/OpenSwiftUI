//
//  UIViewRepresentable.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

#if os(iOS)

public import UIKit
public import OpenSwiftUICore
import OpenGraphShims

/// A wrapper for a UIKit view that you use to integrate that view into your
/// OpenSwiftUI view hierarchy.
///
/// Use a ``UIViewRepresentable`` instance to create and manage a
/// [UIView](https://developer.apple.com/documentation/UIKit/UIView) object in your OpenSwiftUI
/// interface. Adopt this protocol in one of your app's custom instances, and
/// use its methods to create, update, and tear down your view. The creation and
/// update processes parallel the behavior of OpenSwiftUI views, and you use them to
/// configure your view with your app's current state information. Use the
/// teardown process to remove your view cleanly from your Open For example,
/// you might use the teardown process to notify other objects that the view is
/// disappearing.
///
/// To add your view into your OpenSwiftUI interface, create your
/// ``UIViewRepresentable`` instance and add it to your OpenSwiftUI interface. The
/// system calls the methods of your representable instance at appropriate times
/// to create and update the view. The following example shows the inclusion of
/// a custom `MyRepresentedCustomView` structure in the view hierarchy.
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
/// view to other parts of your OpenSwiftUI interface. When you want your view to
/// coordinate with other OpenSwiftUI views, you must provide a
/// ``UIViewRepresentable/Coordinator`` instance to facilitate those
/// interactions. For example, you use a coordinator to forward target-action
/// and delegate messages from your view to any OpenSwiftUI views.
///
/// - Warning: OpenSwiftUI fully controls the layout of the UIKit view's
/// [center](https://developer.apple.com/documentation/UIKit/UIView/1622627-center),
/// [bounds](https://developer.apple.com/documentation/UIKit/UIView/1622580-bounds),
/// [frame](https://developer.apple.com/documentation/UIKit/UIView/1622621-frame), and
/// [transform](https://developer.apple.com/documentation/UIKit/UIView/1622459-transform)
/// properties. Don't directly set these layout-related properties on the view
/// managed by a `UIViewRepresentable` instance from your own
/// code because that conflicts with OpenSwiftUI and results in undefined behavior.
@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor
@preconcurrency
public protocol UIViewRepresentable: View where Body == Never {
    /// The type of view to present.
    associatedtype UIViewType: UIView
    
    /// Creates the view object and configures its initial state.
    ///
    /// You must implement this method and use it to create your view object.
    /// Configure the view using your app's current data and contents of the
    /// `context` parameter. The system calls this method only once, when it
    /// creates your view for the first time. For all subsequent updates, the
    /// system calls the ``UIViewRepresentable/updateUIView(_:context:)``
    /// method.
    ///
    /// - Parameter context: A context structure containing information about
    ///   the current state of the system.
    ///
    /// - Returns: Your UIKit view configured with the provided information.
    func makeUIView(context: Context) -> UIViewType

    /// Updates the state of the specified view with new information from
    /// Open
    ///
    /// When the state of your app changes, OpenSwiftUI updates the portions of your
    /// interface affected by those changes. OpenSwiftUI calls this method for any
    /// changes affecting the corresponding UIKit view. Use this method to
    /// update the configuration of your view to match the new state information
    /// provided in the `context` parameter.
    ///
    /// - Parameters:
    ///   - uiView: Your custom view object.
    ///   - context: A context structure containing information about the current
    ///     state of the system.
    func updateUIView(_ uiView: UIViewType, context: Context)
    
    @_spi(Private)
    func _resetUIView(_ uiView: UIViewType, coordinator: Coordinator, destroy: () -> Void)

    /// Cleans up the presented UIKit view (and coordinator) in anticipation of
    /// their removal.
    ///
    /// Use this method to perform additional clean-up work related to your
    /// custom view. For example, you might use this method to remove observers
    /// or update other parts of your OpenSwiftUI interface.
    ///
    /// - Parameters:
    ///   - uiView: Your custom view object.
    ///   - coordinator: The custom coordinator instance you use to communicate
    ///     changes back to Open If you do not use a custom coordinator, the
    ///     system provides a default instance.
    @MainActor
    static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator)
    
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
    /// interact with other parts of your app, providing a coordinator is
    /// unnecessary.
    ///
    /// SwiftUI calls this method before calling the
    /// ``UIViewRepresentable/makeUIView(context:)`` method. The system provides
    /// your coordinator either directly or as part of a context structure when
    /// calling the other methods of your representable instance.
    func makeCoordinator() -> Coordinator
    
    func _identifiedViewTree(in uiView: UIViewType) -> _IdentifiedViewTree
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIViewType, context: Context) -> CGSize?

    func _overrideSizeThatFits(_ size: inout CGSize, in: _ProposedSize, uiView: UIViewType)

    func _overrideLayoutTraits(_ layoutTraits: inout _LayoutTraits, for uiView: UIViewType)

    static func _modifyBridgedViewInputs(_ inputs: inout _ViewInputs)

    static func _layoutOptions(_ provider: UIViewType) -> LayoutOptions

    typealias Context = UIViewRepresentableContext<Self>

    typealias LayoutOptions = _PlatformViewRepresentableLayoutOptions
}

@available(macOS, unavailable)
extension UIViewRepresentable where Coordinator == () {

    /// Creates the custom instance that you use to communicate changes from
    /// your view to other parts of your SwiftUI interface.
    ///
    /// Implement this method if changes to your view might affect other parts
    /// of your app. In your implementation, create a custom Swift instance that
    /// can communicate with other parts of your interface. For example, you
    /// might provide an instance that binds its variables to SwiftUI
    /// properties, causing the two to remain synchronized. If your view doesn't
    /// interact with other parts of your app, providing a coordinator is
    /// unnecessary.
    ///
    /// SwiftUI calls this method before calling the
    /// ``UIViewRepresentable/makeUIView(context:)`` method. The system provides
    /// your coordinator either directly or as part of a context structure when
    /// calling the other methods of your representable instance.
    public func makeCoordinator() -> Coordinator {
        return
    }
}

@available(macOS, unavailable)
extension UIViewRepresentable {
    public func _resetUIView(_ uiView: UIViewType, coordinator: Coordinator, destroy: () -> Void) {
        destroy()
    }

    public static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {}

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        precondition(isLinkedOnOrAfter(.v4) ? Metadata(Self.self).isValueType : true, "")

        preconditionFailure("TODO")
    }

    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }

    public func _identifiedViewTree(in uiView: UIViewType) -> _IdentifiedViewTree { .empty }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIViewType, context: Context) -> CGSize? { nil }

    public func _overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, uiView: UIViewType) {}

    public func _overrideLayoutTraits(_ layoutTraits: inout _LayoutTraits, for uiView: UIViewType) {}

    public static func _modifyBridgedViewInputs(_ inputs: inout _ViewInputs) {}

    public static func _layoutOptions(_ provider: UIViewType) -> LayoutOptions { .init(rawValue: 1) }

    public var body: Never {
        bodyError()
    }
}

// FIXME

/// Contextual information about the state of the system that you use to create
/// and update your UIKit view.
///
/// A ``UIViewRepresentableContext`` structure contains details about the
/// current state of the system. When creating and updating your view, the
/// system creates one of these structures and passes it to the appropriate
/// method of your custom ``UIViewRepresentable`` instance. Use the information
/// in this structure to configure your view. For example, use the provided
/// environment values to configure the appearance of your view. Don't create
/// this structure yourself.
@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor
public struct UIViewRepresentableContext<Representable> where Representable: UIViewRepresentable {

    /// The view's associated coordinator.
    public let coordinator: Representable.Coordinator

    /// The current transaction.
    public private(set) var transaction: Transaction

    /// The current environment.
    ///
    /// Use the environment values to configure the state of your view when
    /// creating or updating it.
    public private(set) var environment: EnvironmentValues
    
    var preferenceBridge: PreferenceBridge
    
    init(coordinator: Representable.Coordinator, transaction: Transaction, environment: EnvironmentValues, preferenceBridge: PreferenceBridge) {
        self.coordinator = coordinator
        self.transaction = transaction
        self.environment = environment
        self.preferenceBridge = preferenceBridge
    }

//    public func animate(changes: () -> Void, completion: (() -> Void)? = nil) {
//
//    }
}

#endif
