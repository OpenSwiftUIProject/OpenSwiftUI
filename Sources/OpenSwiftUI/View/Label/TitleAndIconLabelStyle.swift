//
//  TitleAndIconLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

public import OpenSwiftUICore

// MARK: - LabelStyle + TitleAndIconLabelStyle

@available(OpenSwiftUI_v2_3, *)
extension LabelStyle where Self == TitleAndIconLabelStyle {
    /// A label style that shows both the title and icon of the label using a
    /// system-standard layout.
    ///
    /// In most cases, labels show both their title and icon by default. However,
    /// some containers might apply a different default label style to their
    /// content, such as only showing icons within toolbars on macOS and iOS. To
    /// opt in to showing both the title and the icon, you can apply the title
    /// and icon label style:
    ///
    ///     Label("Lightning", systemImage: "bolt.fill")
    ///         .labelStyle(.titleAndIcon)
    ///
    /// To apply the title and icon style to a group of labels, apply the style
    /// to the view hierarchy that contains the labels:
    ///
    ///     VStack {
    ///         Label("Rain", systemImage: "cloud.rain")
    ///         Label("Snow", systemImage: "snow")
    ///         Label("Sun", systemImage: "sun.max")
    ///     }
    ///     .labelStyle(.titleAndIcon)
    ///
    /// The relative layout of the title and icon is dependent on the context it
    /// is displayed in. In most cases, however, the label is arranged
    /// horizontally with the icon leading.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var titleAndIcon: TitleAndIconLabelStyle {
        .init()
    }
}

// MARK: - TitleAndIconLabelStyle

/// A label style that shows both the title and icon of the label using a
/// system-standard layout.
///
/// You can also use ``LabelStyle/titleAndIcon`` to construct this style.
@available(OpenSwiftUI_v2_3, *)
public struct TitleAndIconLabelStyle: LabelStyle {
    /// Creates a label style that shows both the title and icon of the label
    /// using a system-standard layout.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        StaticIf(MultiViewLabel.self) {
            TupleView((
                configuration.icon
                    .containerValue(\.labelItemRole, .icon),
                configuration.title
                    .containerValue(\.labelItemRole, .title)
            ))
        } else: {
            #if OPENSWIFTUI_SUPPORT_2024_API
            StaticIf(idiom: .vision) {
                HStack(alignment: ._firstTextLineCenter) {
                    configuration.icon
                        .modifier(LabelIconPlatformItemModifier())
                    configuration.title
                        .multilineTextAlignment(.leading)
                }
            } else: {
                HStack(alignment: ._firstTextLineCenter) {
                    configuration.icon
                        .modifier(LabelIconPlatformItemModifier())
                    configuration.title
                        .multilineTextAlignment(.leading)
                }
            }
            #else
            HStack(alignment: ._firstTextLineCenter) {
                configuration.icon
                    .modifier(LabelIconPlatformItemModifier())
                configuration.title
                    .multilineTextAlignment(.leading)
            }
            #endif
        }
    }
}

@available(*, unavailable)
extension TitleAndIconLabelStyle: Sendable {}
