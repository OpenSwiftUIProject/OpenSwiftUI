//
//  Toggle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - Toggle

/// A control that toggles between on and off states.
///
/// You create a toggle by providing an `isOn` binding and a label. Bind `isOn`
/// to a Boolean property that determines whether the toggle is on or off. Set
/// the label to a view that visually describes the purpose of switching between
/// toggle states. For example:
///
///     @State private var vibrateOnRing = false
///
///     var body: some View {
///         Toggle(isOn: $vibrateOnRing) {
///             Text("Vibrate on Ring")
///         }
///     }
///
/// For the common case of ``Label`` based labels, you can use the convenience
/// initializer that takes a title string (or localized string key) and the
/// name of a system image:
///
///     @State private var vibrateOnRing = true
///
///     var body: some View {
///         Toggle(
///             "Vibrate on Ring",
///             systemImage: "dot.radiowaves.left.and.right",
///             isOn: $vibrateOnRing
///         )
///     }
///
/// For text-only labels, you can use the convenience initializer that takes
/// a title string (or localized string key) as its first parameter, instead
/// of a trailing closure:
///
///     @State private var vibrateOnRing = true
///
///     var body: some View {
///         Toggle("Vibrate on Ring", isOn: $vibrateOnRing)
///     }
///
/// For cases where adding a subtitle to the label is desired, use a view
/// builder that creates multiple `Text` views where the first text represents
/// the title and the second text represents the subtitle:
///
///     @State private var vibrateOnRing = false
///
///     var body: some View {
///         Toggle(isOn: $vibrateOnRing) {
///             Text("Vibrate on Ring")
///             Text("Enable vibration when the phone rings")
///         }
///     }
/// > Note: This behavior does not apply to ``ToggleStyle/button``.
///
///
/// ### Styling toggles
///
/// Toggles use a default style that varies based on both the platform and
/// the context. For more information, read about the ``ToggleStyle/automatic``
/// toggle style.
///
/// You can customize the appearance and interaction of toggles by applying
/// styles using the ``View/toggleStyle(_:)`` modifier. You can apply built-in
/// styles, like ``ToggleStyle/switch``, to either a toggle, or to a view
/// hierarchy that contains toggles:
///
///     VStack {
///         Toggle("Vibrate on Ring", isOn: $vibrateOnRing)
///         Toggle("Vibrate on Silent", isOn: $vibrateOnSilent)
///     }
///     .toggleStyle(.switch)
///
/// You can also define custom styles by creating a type that conforms to the
/// ``ToggleStyle`` protocol.
@available(OpenSwiftUI_v1_0, *)
public struct Toggle<Label>: View where Label: View {
    var _toggleState: Binding<ToggleState>

    var label: Label

    var appIntentAction: AppIntentAction?

    /// Creates a toggle that displays a custom label.
    ///
    /// - Parameters:
    ///   - isOn: A binding to a property that determines whether the toggle is on
    ///     or off.
    ///   - label: A view that describes the purpose of the toggle.
    nonisolated public init(
        isOn: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self.init(toggledOn: [isOn], label: label)
    }

    @_spi(_)
    @available(OpenSwiftUI_v4_0, *)
    @available(*, deprecated, message: "Use Toggle.init(sources:isOn:label:).")
    nonisolated public init<C>(
        isOn: C,
        @ViewBuilder label: () -> Label
    ) where C: RandomAccessCollection, C.Element == Binding<Bool> {
        self.init(toggledOn: isOn, label: label)
    }

    /// Creates a toggle representing a collection of values with a custom label.
    ///
    /// The following example creates a single toggle that represents
    /// the state of multiple alarms:
    ///
    ///     struct Alarm: Hashable, Identifiable {
    ///         var id = UUID()
    ///         var isOn = false
    ///         var name = ""
    ///     }
    ///
    ///     @State private var alarms = [
    ///         Alarm(isOn: true, name: "Morning"),
    ///         Alarm(isOn: false, name: "Evening")
    ///     ]
    ///
    ///     Toggle(sources: $alarms, isOn: \.isOn) {
    ///         Text("Enable all alarms")
    ///     }
    ///
    /// - Parameters:
    ///   - sources: A collection of values used as the source for rendering the
    ///     Toggle's state.
    ///   - isOn: The key path of the values that determines whether the toggle
    ///     is on, mixed or off.
    ///   - label: A view that describes the purpose of the toggle.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public init<C>(
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>,
        @ViewBuilder label: () -> Label
    ) where C: RandomAccessCollection {
        self.init(toggledOn: sources.lazy.map { $0[keyPath: isOn] }, label: label)
    }

    nonisolated init<C>(
        toggledOn: C,
        @ViewBuilder label: () -> Label
    ) where C: Collection, C.Element == Binding<Bool> {
        self.label = label()
        appIntentAction = nil
        _toggleState = Binding(get: {
            ToggleState.stateFor(item: true, in: toggledOn)
        }, set: { value in
            for binding in toggledOn {
                binding.wrappedValue = (value == .on)
            }
        })
    }

    public var body: some View {
        ResolvedToggleStyle(
            configuration: ToggleStyleConfiguration(
                label: .init(),
                isOn: _toggleState.projecting(ToggleStateBool()),
                toggleState: _toggleState,
                isMixed: _toggleState.wrappedValue == .mixed,
                effect: appIntentAction.map(ToggleStyleConfiguration.Effect.appIntent) ?? .binding
            )
        ).viewAlias(ToggleStyleConfiguration.Label.self) {
            label
        }
    }
}

@available(*, unavailable)
extension Toggle: Sendable {}

extension Toggle where Label == ToggleStyleConfiguration.Label {
    /// Creates a toggle based on a toggle style configuration.
    ///
    /// You can use this initializer within the
    /// ``ToggleStyle/makeBody(configuration:)`` method of a ``ToggleStyle`` to
    /// create an instance of the styled toggle. This is useful for custom
    /// toggle styles that only modify the current toggle style, as opposed to
    /// implementing a brand new style.
    ///
    /// For example, the following style adds a red border around the toggle,
    /// but otherwise preserves the toggle's current style:
    ///
    ///     struct RedBorderToggleStyle: ToggleStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             Toggle(configuration)
    ///                 .padding()
    ///                 .border(.red)
    ///         }
    ///     }
    ///
    /// - Parameter configuration: The properties of the toggle, including a
    ///   label and a binding to the toggle's state.
    nonisolated public init(_ configuration: ToggleStyleConfiguration) {
        _toggleState = configuration.$toggleState
        label = configuration.label
        switch configuration.effect {
        case let .appIntent(action): appIntentAction = action
        case .binding: appIntentAction = nil
        }
    }
}

// MARK: - Toggle + Text

@available(OpenSwiftUI_v1_0, *)
extension Toggle where Label == Text {
    /// Creates a toggle that generates its label from a localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the toggle's localized title, that describes
    ///     the purpose of the toggle.
    ///   - isOn: A binding to a property that indicates whether the toggle is
    ///    on or off.
    nonisolated public init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            Text(titleKey)
        }
    }

    /// Creates a toggle that generates its label from a string.
    ///
    /// This initializer creates a ``Text`` view on your behalf. See `Text` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the toggle.
    ///   - isOn: A binding to a property that indicates whether the toggle is
    ///    on or off.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, isOn: Binding<Bool>) where S: StringProtocol {
        self.init(isOn: isOn) {
            Text(title)
        }
    }

    @_spi(_)
    @available(OpenSwiftUI_v4_0, *)
    @available(*, deprecated, message: "Use Toggle.init(_:sources:isOn).")
    nonisolated public init<C>(
        _ titleKey: LocalizedStringKey,
        isOn: C
    ) where C: RandomAccessCollection, C.Element == Binding<Bool> {
        self.init(toggledOn: isOn) {
            Text(titleKey)
        }
    }

    /// Creates a toggle representing a collection of values that generates its
    /// label from a localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    /// The following example creates a single toggle that represents
    /// the state of multiple alarms:
    ///
    ///     struct Alarm: Hashable, Identifiable {
    ///         var id = UUID()
    ///         var isOn = false
    ///         var name = ""
    ///     }
    ///
    ///     @State private var alarms = [
    ///         Alarm(isOn: true, name: "Morning"),
    ///         Alarm(isOn: false, name: "Evening")
    ///     ]
    ///
    ///     Toggle("Enable all alarms", sources: $alarms, isOn: \.isOn)
    ///
    /// - Parameters:
    ///   - titleKey: The key for the toggle's localized title, that describes
    ///     the purpose of the toggle.
    ///   - sources: A collection of values used as the source for rendering the
    ///     Toggle's state.
    ///   - isOn: The key path of the values that determines whether the toggle
    ///     is on, mixed or off.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public init<C>(
        _ titleKey: LocalizedStringKey,
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>
    ) where C: RandomAccessCollection {
        self.init(sources: sources, isOn: isOn) {
            Text(titleKey)
        }
    }

    @_spi(_)
    @available(OpenSwiftUI_v4_0, *)
    @available(*, deprecated, message: "Use Toggle.init(_:sources:isOn).")
    @_disfavoredOverload
    nonisolated public init<S, C>(
        _ title: S,
        isOn: C
    ) where S: StringProtocol, C: RandomAccessCollection, C.Element == Binding<Bool> {
        self.init(toggledOn: isOn) {
            Text(title)
        }
    }

    /// Creates a toggle representing a collection of values that generates its
    /// label from a string.
    ///
    /// This initializer creates a ``Text`` view on your behalf. See `Text` for more
    /// information about localizing strings.
    ///
    /// The following example creates a single toggle that represents
    /// the state of multiple alarms:
    ///
    ///     struct Alarm: Hashable, Identifiable {
    ///         var id = UUID()
    ///         var isOn = false
    ///         var name = ""
    ///     }
    ///
    ///     @State private var alarms = [
    ///         Alarm(isOn: true, name: "Morning"),
    ///         Alarm(isOn: false, name: "Evening")
    ///     ]
    ///
    ///     Toggle("Enable all alarms", sources: $alarms, isOn: \.isOn)
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the toggle.
    ///   - sources: A collection of values used as the source for rendering
    ///     the Toggle's state.
    ///   - isOn: The key path of the values that determines whether the toggle
    ///     is on, mixed or off.
    @available(OpenSwiftUI_v4_0, *)
    @_disfavoredOverload
    nonisolated public init<S, C>(
        _ title: S,
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>
    ) where S: StringProtocol, C: RandomAccessCollection {
        self.init(sources: sources, isOn: isOn) {
            Text(title)
        }
    }
}

// MARK: - Toggle + Label<Text, Image>

@available(OpenSwiftUI_v2_0, *)
extension Toggle where Label == OpenSwiftUI.Label<Text, Image> {
    /// Creates a toggle that generates its label from a localized string key
    /// and system image.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the toggle's localized title, that describes
    ///     the purpose of the toggle.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - isOn: A binding to a property that indicates whether the toggle is
    ///    on or off.
    @_alwaysEmitIntoClient
    nonisolated public init(_ titleKey: LocalizedStringKey, systemImage: String, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            OpenSwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }

    /// Creates a toggle that generates its label from a string and
    /// system image.
    ///
    /// This initializer creates a ``Text`` view on your behalf. See `Text` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the toggle.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - isOn: A binding to a property that indicates whether the toggle is
    ///    on or off.
    @_alwaysEmitIntoClient
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, systemImage: String, isOn: Binding<Bool>) where S: StringProtocol {
        self.init(isOn: isOn) {
            OpenSwiftUI.Label(title, systemImage: systemImage)
        }
    }

    /// Creates a toggle representing a collection of values that generates its
    /// label from a localized string key and system image.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    /// The following example creates a single toggle that represents
    /// the state of multiple alarms:
    ///
    ///     struct Alarm: Hashable, Identifiable {
    ///         var id = UUID()
    ///         var isOn = false
    ///         var name = ""
    ///     }
    ///
    ///     @State private var alarms = [
    ///         Alarm(isOn: true, name: "Morning"),
    ///         Alarm(isOn: false, name: "Evening")
    ///     ]
    ///
    ///     Toggle("Enable all alarms", sources: $alarms, isOn: \.isOn)
    ///
    /// - Parameters:
    ///   - titleKey: The key for the toggle's localized title, that describes
    ///     the purpose of the toggle.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - sources: A collection of values used as the source for rendering the
    ///     Toggle's state.
    ///   - isOn: The key path of the values that determines whether the toggle
    ///     is on, mixed or off.
    @available(OpenSwiftUI_v4_0, *)
    @_alwaysEmitIntoClient
    nonisolated public init<C>(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>
    ) where C: RandomAccessCollection {
        self.init(sources: sources, isOn: isOn) {
            OpenSwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }

    /// Creates a toggle representing a collection of values that generates its
    /// label from a string and system image.
    ///
    /// This initializer creates a ``Text`` view on your behalf. See `Text` for more
    /// information about localizing strings.
    ///
    /// The following example creates a single toggle that represents
    /// the state of multiple alarms:
    ///
    ///     struct Alarm: Hashable, Identifiable {
    ///         var id = UUID()
    ///         var isOn = false
    ///         var name = ""
    ///     }
    ///
    ///     @State private var alarms = [
    ///         Alarm(isOn: true, name: "Morning"),
    ///         Alarm(isOn: false, name: "Evening")
    ///     ]
    ///
    ///     Toggle("Enable all alarms", sources: $alarms, isOn: \.isOn)
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the toggle.
    ///   - systemImage: The name of the image resource to lookup.
    ///   - sources: A collection of values used as the source for rendering
    ///     the Toggle's state.
    ///   - isOn: The key path of the values that determines whether the toggle
    ///     is on, mixed or off.
    @available(OpenSwiftUI_v4_0, *)
    @_alwaysEmitIntoClient
    @_disfavoredOverload
    nonisolated public init<S, C>(
        _ title: S,
        systemImage: String,
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>
    ) where S: StringProtocol, C: RandomAccessCollection {
        self.init(sources: sources, isOn: isOn) {
            OpenSwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

#if canImport(DeveloperToolsSupport)
// MARK: - Toggle + ImageResource

@available(OpenSwiftUI_v5_0, *)
extension Toggle where Label == OpenSwiftUI.Label<Text, Image> {
    /// Creates a toggle that generates its label from a localized string key
    /// and image resource.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the toggle's localized title, that describes
    ///     the purpose of the toggle.
    ///   - image: The name of the image resource to lookup.
    ///   - isOn: A binding to a property that indicates whether the toggle is
    ///    on or off.
    nonisolated public init(_ titleKey: LocalizedStringKey, image: ImageResource, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            OpenSwiftUI.Label(titleKey, image: image)
        }
    }

    /// Creates a toggle that generates its label from a string and
    /// image resource.
    ///
    /// This initializer creates a ``Text`` view on your behalf.  See `Text` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the toggle.
    ///   - image: The name of the image resource to lookup.
    ///   - isOn: A binding to a property that indicates whether the toggle is
    ///    on or off.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, image: ImageResource, isOn: Binding<Bool>) where S: StringProtocol {
        self.init(isOn: isOn) {
            OpenSwiftUI.Label(title, image: image)
        }
    }

    /// Creates a toggle representing a collection of values that generates its
    /// label from a localized string key and image resource.
    ///
    /// This initializer creates a ``Text`` view on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    /// The following example creates a single toggle that represents
    /// the state of multiple alarms:
    ///
    ///     struct Alarm: Hashable, Identifiable {
    ///         var id = UUID()
    ///         var isOn = false
    ///         var name = ""
    ///     }
    ///
    ///     @State private var alarms = [
    ///         Alarm(isOn: true, name: "Morning"),
    ///         Alarm(isOn: false, name: "Evening")
    ///     ]
    ///
    ///     Toggle("Enable all alarms", sources: $alarms, isOn: \.isOn)
    ///
    /// - Parameters:
    ///   - titleKey: The key for the toggle's localized title, that describes
    ///     the purpose of the toggle.
    ///   - image: The name of the image resource to lookup.
    ///   - sources: A collection of values used as the source for rendering the
    ///     Toggle's state.
    ///   - isOn: The key path of the values that determines whether the toggle
    ///     is on, mixed or off.
    nonisolated public init<C>(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>
    ) where C: RandomAccessCollection {
        self.init(sources: sources, isOn: isOn) {
            OpenSwiftUI.Label(titleKey, image: image)
        }
    }

    /// Creates a toggle representing a collection of values that generates its
    /// label from a string and image resource.
    ///
    /// This initializer creates a ``Text`` view on your behalf. See `Text` for more
    /// information about localizing strings.
    ///
    /// The following example creates a single toggle that represents
    /// the state of multiple alarms:
    ///
    ///     struct Alarm: Hashable, Identifiable {
    ///         var id = UUID()
    ///         var isOn = false
    ///         var name = ""
    ///     }
    ///
    ///     @State private var alarms = [
    ///         Alarm(isOn: true, name: "Morning"),
    ///         Alarm(isOn: false, name: "Evening")
    ///     ]
    ///
    ///     Toggle("Enable all alarms", sources: $alarms, isOn: \.isOn)
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the toggle.
    ///   - image: The name of the image resource to lookup.
    ///   - sources: A collection of values used as the source for rendering
    ///     the Toggle's state.
    ///   - isOn: The key path of the values that determines whether the toggle
    ///     is on, mixed or off.
    @_disfavoredOverload
    nonisolated public init<S, C>(
        _ title: S,
        image: ImageResource,
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>
    ) where S: StringProtocol, C: RandomAccessCollection {
        self.init(sources: sources, isOn: isOn) {
            OpenSwiftUI.Label(title, image: image)
        }
    }
}
#endif
