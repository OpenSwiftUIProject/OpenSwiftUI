//
//  GestureMask.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - View + Gesture

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Attaches a gesture to the view with a lower precedence than gestures
    /// defined by the view.
    ///
    /// Use this method when you need to attach a gesture to a view. The
    /// example below defines a custom gesture that prints a message to the
    /// console and attaches it to the view's ``VStack``. Inside the ``VStack``
    /// a red heart ``Image`` defines its own ``TapGesture``
    /// handler that also prints a message to the console, and blue rectangle
    /// with no custom gesture handlers. Tapping or clicking the image
    /// prints a message to the console from the tap gesture handler on the
    /// image, while tapping or clicking  the rectangle inside the ``VStack``
    /// prints a message in the console from the enclosing vertical stack
    /// gesture handler.
    ///
    ///     struct GestureExample: View {
    ///         @State private var message = "Message"
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Tap on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Tap on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .gesture(newGesture)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - mask: A value that controls how adding this gesture to the view
    ///      affects other gestures recognized by the view and its subviews.
    ///      Defaults to ``OpenSwiftUI/GestureMask/all``.
    nonisolated public func gesture<T>(
        _ gesture: T,
        including mask: GestureMask = .all
    ) -> some View where T: Gesture {
        modifier(AddGestureModifier(gesture, gestureMask: mask))
    }

    /// Attaches a gesture to the view with a higher precedence than gestures
    /// defined by the view.
    ///
    /// Use this method when you need to define a high priority gesture
    /// to take precedence over the view's existing gestures. The
    /// example below defines a custom gesture that prints a message to the
    /// console and attaches it to the view's ``VStack``. Inside the ``VStack``
    /// a red heart ``Image`` defines its own ``TapGesture`` handler that
    /// also prints a message to the console, and a blue rectangle
    /// with no custom gesture handlers. Tapping or clicking any of the
    /// views results in a console message from the high priority gesture
    /// attached to the enclosing ``VStack``.
    ///
    ///     struct HighPriorityGestureExample: View {
    ///         @State private var message = "Message"
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Tap on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Tap on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .highPriorityGesture(newGesture)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - mask: A value that controls how adding this gesture to the view
    ///      affects other gestures recognized by the view and its subviews.
    ///      Defaults to ``OpenSwiftUI/GestureMask/all``.
    nonisolated public func highPriorityGesture<T>(
        _ gesture: T,
        including mask: GestureMask = .all
    ) -> some View where T: Gesture {
        modifier(HighPriorityGestureModifier(gesture, name: nil, gestureMask: mask))
    }

    /// Attaches a gesture to the view to process simultaneously with gestures
    /// defined by the view.
    ///
    /// Use this method when you need to define and process  a view specific
    /// gesture simultaneously with the same priority as the
    /// view's existing gestures. The example below defines a custom gesture
    /// that prints a message to the console and attaches it to the view's
    /// ``VStack``. Inside the ``VStack`` is a red heart ``Image`` defines its
    /// own ``TapGesture`` handler that also prints a message to the console
    /// and a blue rectangle with no custom gesture handlers.
    ///
    /// Tapping or clicking the "heart" image sends two messages to the
    /// console: one for the image's tap gesture handler, and the other from a
    /// custom gesture handler attached to the enclosing vertical stack.
    /// Tapping or clicking on the blue rectangle results only in the single
    /// message to the console from the tap recognizer attached to the
    /// ``VStack``:
    ///
    ///     struct SimultaneousGestureExample: View {
    ///         @State private var message = "Message"
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Gesture on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Gesture on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .simultaneousGesture(newGesture)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - mask: A value that controls how adding this gesture to the view
    ///      affects other gestures recognized by the view and its subviews.
    ///      Defaults to ``OpenSwiftUI/GestureMask/all``.
    nonisolated public func simultaneousGesture<T>(
        _ gesture: T,
        including mask: GestureMask = .all
    ) -> some View where T: Gesture {
        modifier(SimultaneousGestureModifier(gesture, name: nil, gestureMask: mask))
    }

    /// Attaches a gesture to the view with a lower precedence than gestures
    /// defined by the view.
    ///
    /// Use this method when you need to attach a gesture to a view. The
    /// example below defines a custom gesture that prints a message to the
    /// console and attaches it to the view's ``VStack``. Inside the ``VStack``
    /// a red heart ``Image`` defines its own ``TapGesture``
    /// handler that also prints a message to the console, and blue rectangle
    /// with no custom gesture handlers. Tapping or clicking the image
    /// prints a message to the console from the tap gesture handler on the
    /// image, while tapping or clicking  the rectangle inside the ``VStack``
    /// prints a message in the console from the enclosing vertical stack
    /// gesture handler.
    ///
    /// You can also use the ``isEnabled`` parameter to conditionally disable
    /// the gesture.
    ///
    ///     struct GestureExample: View {
    ///         @State private var message = "Message"
    ///         var isGestureEnabled: Bool
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Tap on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Tap on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .gesture(newGesture, isEnabled: isGestureEnabled)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - isEnabled: Whether the added gesture is enabled.
    @_alwaysEmitIntoClient
    nonisolated public func gesture<T>(
        _ gesture: T,
        isEnabled: Bool
    ) -> some View where T: Gesture {
        self.gesture(gesture, including: isEnabled ? .all : .subviews)
    }

    /// Attaches a gesture to the view with a higher precedence than gestures
    /// defined by the view.
    ///
    /// Use this method when you need to define a high priority gesture
    /// to take precedence over the view's existing gestures. The
    /// example below defines a custom gesture that prints a message to the
    /// console and attaches it to the view's ``VStack``. Inside the ``VStack``
    /// a red heart ``Image`` defines its own ``TapGesture`` handler that
    /// also prints a message to the console, and a blue rectangle
    /// with no custom gesture handlers. Tapping or clicking any of the
    /// views results in a console message from the high priority gesture
    /// attached to the enclosing ``VStack``.
    ///
    /// You can also use the ``isEnabled`` parameter to conditionally disable
    /// the gesture.
    ///
    ///     struct HighPriorityGestureExample: View {
    ///         @State private var message = "Message"
    ///         var isGestureEnabled: Bool
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Tap on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Tap on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .highPriorityGesture(
    ///                 newGesture, isEnabled: isGestureEnabled)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - isEnabled: Whether the added gesture is enabled.
    @_alwaysEmitIntoClient
    nonisolated public func highPriorityGesture<T>(
        _ gesture: T,
        isEnabled: Bool
    ) -> some View where T: Gesture {
        highPriorityGesture(gesture, including: isEnabled ? .all : .subviews)
    }

    /// Attaches a gesture to the view to process simultaneously with gestures
    /// defined by the view.
    ///
    /// Use this method when you need to define and process  a view specific
    /// gesture simultaneously with the same priority as the
    /// view's existing gestures. The example below defines a custom gesture
    /// that prints a message to the console and attaches it to the view's
    /// ``VStack``. Inside the ``VStack`` is a red heart ``Image`` defines its
    /// own ``TapGesture`` handler that also prints a message to the console
    /// and a blue rectangle with no custom gesture handlers.
    ///
    /// You can also use the ``isEnabled`` parameter to conditionally disable
    /// the gesture.
    ///
    /// Tapping or clicking the "heart" image sends two messages to the
    /// console: one for the image's tap gesture handler, and the other from a
    /// custom gesture handler attached to the enclosing vertical stack.
    /// Tapping or clicking on the blue rectangle results only in the single
    /// message to the console from the tap recognizer attached to the
    /// ``VStack``:
    ///
    ///     struct SimultaneousGestureExample: View {
    ///         @State private var message = "Message"
    ///         var isGestureEnabled: Bool
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Gesture on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Gesture on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .simultaneousGesture(
    ///                 newGesture, isEnabled: isGestureEnabled)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - isEnabled: Whether the added gesture is enabled.
    @_alwaysEmitIntoClient
    nonisolated public func simultaneousGesture<T>(
        _ gesture: T,
        isEnabled: Bool
    ) -> some View where T: Gesture {
        simultaneousGesture(gesture, including: isEnabled ? .all : .subviews)
    }
}

@available(OpenSwiftUI_v6_0, *)
extension View {
    /// Attaches a gesture to the view with a lower precedence than gestures
    /// defined by the view.
    ///
    /// Use this method when you need to attach a gesture to a view. The
    /// example below defines a custom gesture that prints a message to the
    /// console and attaches it to the view's ``VStack``. Inside the ``VStack``
    /// a red heart ``Image`` defines its own ``TapGesture``
    /// handler that also prints a message to the console, and blue rectangle
    /// with no custom gesture handlers. Tapping or clicking the image
    /// prints a message to the console from the tap gesture handler on the
    /// image, while tapping or clicking  the rectangle inside the ``VStack``
    /// prints a message in the console from the enclosing vertical stack
    /// gesture handler.
    ///
    /// You can also use the ``isEnabled`` parameter to conditionally disable
    /// the gesture.
    ///
    ///     struct GestureExample: View {
    ///         @State private var message = "Message"
    ///         var isGestureEnabled: Bool
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Tap on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Tap on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .gesture(newGesture, isEnabled: isGestureEnabled)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - name: A string that identifies the gesture. In iOS, the name can be
    ///      used to set up failure relationships between UIKit gesture
    ///      recognizers and this gesture.
    ///    - isEnabled: Whether the added gesture is enabled. The default value
    ///      is `true`.
    nonisolated public func gesture<T>(
        _ gesture: T,
        name: String,
        isEnabled: Bool = true
    ) -> some View where T: Gesture {
        modifier(AddGestureModifier(
            gesture,
            name: name,
            gestureMask: isEnabled ? .all : .subviews
        ))
    }

    /// Attaches a gesture to the view with a higher precedence than gestures
    /// defined by the view.
    ///
    /// Use this method when you need to define a high priority gesture
    /// to take precedence over the view's existing gestures. The
    /// example below defines a custom gesture that prints a message to the
    /// console and attaches it to the view's ``VStack``. Inside the ``VStack``
    /// a red heart ``Image`` defines its own ``TapGesture`` handler that
    /// also prints a message to the console, and a blue rectangle
    /// with no custom gesture handlers. Tapping or clicking any of the
    /// views results in a console message from the high priority gesture
    /// attached to the enclosing ``VStack``.
    ///
    /// You can also use the ``isEnabled`` parameter to conditionally disable
    /// the gesture.
    ///
    ///     struct HighPriorityGestureExample: View {
    ///         @State private var message = "Message"
    ///         var isGestureEnabled: Bool
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Tap on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Tap on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .highPriorityGesture(
    ///                 newGesture, isEnabled: isGestureEnabled)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - name: A string that identifies the gesture. In iOS, the name can be
    ///      used to set up failure relationships between UIKit gesture
    ///      recognizers and this gesture.
    ///    - isEnabled: Whether the added gesture is enabled. The default value
    ///      is `true`.
    nonisolated public func highPriorityGesture<T>(
        _ gesture: T,
        name: String,
        isEnabled: Bool = true
    ) -> some View where T: Gesture {
        modifier(HighPriorityGestureModifier(
            gesture,
            name: name,
            gestureMask: isEnabled ? .all : .subviews
        ))
    }

    /// Attaches a gesture to the view to process simultaneously with gestures
    /// defined by the view.
    ///
    /// Use this method when you need to define and process  a view specific
    /// gesture simultaneously with the same priority as the
    /// view's existing gestures. The example below defines a custom gesture
    /// that prints a message to the console and attaches it to the view's
    /// ``VStack``. Inside the ``VStack`` is a red heart ``Image`` defines its
    /// own ``TapGesture`` handler that also prints a message to the console
    /// and a blue rectangle with no custom gesture handlers.
    ///
    /// You can also use the ``isEnabled`` parameter to conditionally disable
    /// the gesture.
    ///
    /// Tapping or clicking the "heart" image sends two messages to the
    /// console: one for the image's tap gesture handler, and the other from a
    /// custom gesture handler attached to the enclosing vertical stack.
    /// Tapping or clicking on the blue rectangle results only in the single
    /// message to the console from the tap recognizer attached to the
    /// ``VStack``:
    ///
    ///     struct SimultaneousGestureExample: View {
    ///         @State private var message = "Message"
    ///         var isGestureEnabled: Bool
    ///         let newGesture = TapGesture().onEnded {
    ///             print("Gesture on VStack.")
    ///         }
    ///
    ///         var body: some View {
    ///             VStack(spacing:25) {
    ///                 Image(systemName: "heart.fill")
    ///                     .resizable()
    ///                     .frame(width: 75, height: 75)
    ///                     .padding()
    ///                     .foregroundColor(.red)
    ///                     .onTapGesture {
    ///                         print("Gesture on image.")
    ///                     }
    ///                 Rectangle()
    ///                     .fill(Color.blue)
    ///             }
    ///             .simultaneousGesture(
    ///                 newGesture, isEnabled: isGestureEnabled)
    ///             .frame(width: 200, height: 200)
    ///             .border(Color.purple)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - gesture: A gesture to attach to the view.
    ///    - name: A string that identifies the gesture. In iOS, the name can be
    ///      used to set up failure relationships between UIKit gesture
    ///      recognizers and this gesture.
    ///    - isEnabled: Whether the added gesture is enabled. The default value
    ///      is `true`.
    nonisolated public func simultaneousGesture<T>(
        _ gesture: T,
        name: String,
        isEnabled: Bool = true
    ) -> some View where T: Gesture {
        modifier(SimultaneousGestureModifier(
            gesture,
            name: name,
            gestureMask: isEnabled ? .all : .subviews
        ))
    }
}

// MARK: - GestureMask

/// Options that control how adding a gesture to a view affects other gestures
/// recognized by the view and its subviews.
@frozen
@available(OpenSwiftUI_v1_0, *)
public struct GestureMask: OptionSet {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Disable all gestures in the subview hierarchy, including the added
    /// gesture.
    public static let none: GestureMask = .init(rawValue: 0)

    /// Enable the added gesture but disable all gestures in the subview
    /// hierarchy.
    public static let gesture: GestureMask = .init(rawValue: 1 << 0)

    /// Enable all gestures in the subview hierarchy but disable the added
    /// gesture.
    public static let subviews: GestureMask = .init(rawValue: 1 << 1)

    /// Enable both the added gesture as well as all other gestures on the view
    /// and its subviews.
    public static let all: GestureMask = [.gesture, .subviews]
}
