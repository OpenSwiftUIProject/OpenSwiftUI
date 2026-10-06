//
//  AccessibilityRepresentation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by control style protocols and AccessibilityGeometry
//  ID: AAF5C5EDB558810623EAFD84FD4E7390 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - View + AccessibilityRepresentation

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Replaces one or more accessibility elements for this view with new
    /// accessibility elements.
    ///
    /// You can make controls accessible by using a custom style. For example, a custom
    /// ``ToggleStyle`` that you create inherits the accessibility features of ``Toggle``
    /// automatically. When you can't use the parent view's accessibility elements, use the
    /// `accessibilityRepresentation(representation:)`
    /// modifier instead. This modifier replaces default accessibility elements with different accessibility
    /// elements that you provide. You use synthetic, non-visual accessibility elements to represent
    /// what the view displays.
    ///
    /// The example below makes a custom adjustable control accessible by explicitly
    /// defining the representation of its step increments using a ``Slider``:
    ///
    ///     var body: some View {
    ///         VStack {
    ///             SliderTrack(...) // Custom slider implementation.
    ///         }
    ///         .accessibilityRepresentation {
    ///             Slider(value: $value, in: 0...100) {
    ///                 Text("Label")
    ///             }
    ///         }
    ///     }
    ///
    /// OpenSwiftUI hides the view that you provide in the `representation` closure
    /// and makes it non-interactive. The framework uses it only to
    /// generate accessibility elements.
    ///
    /// - Parameter representation: A hidden view that the accessibility
    ///   system uses to generate accessibility elements.
    nonisolated public func accessibilityRepresentation<Representation>(
        @ViewBuilder representation: () -> Representation
    ) -> some View where Representation: View {
        modifier(AccessibilityRepresentationModifier(representable: representation()))
    }

    func accessibilityRepresentationStyle() -> some View {
        modifier(AccessibilityRepresentableStyleModifier())
    }

    /// Replaces the existing accessibility element's children with one or
    /// more new synthetic accessibility elements.
    ///
    /// Use this modifier to replace an existing element's children with one
    /// or more new synthetic accessibility elements you provide. This allows
    /// for synthetic, non-visual accessibility elements to be set as children
    /// of a visual accessibility element.
    ///
    /// OpenSwiftUI creates an accessibility container implicitly when needed.
    /// If an accessibility element already exists, the framework converts it
    /// into an accessibility container.
    ///
    /// In the example below, a ``Canvas``
    /// displays a graph of vertical bars that don't have any inherent accessibility
    /// elements. You make the view accessible by adding the
    /// ``accessibilityChildren(children:)`` modifier with views whose accessibility
    /// elements represent the values of each bar drawn in the canvas:
    ///
    ///     var body: some View {
    ///         Canvas { context, size in
    ///             // Draw Graph
    ///             for data in dataSet {
    ///                 let path = Path(
    ///                     roundedRect: CGRect(
    ///                         x: (size.width / CGFloat(dataSet.count))
    ///                         * CGFloat(data.week),
    ///                         y: 0,
    ///                         width: size.width / CGFloat(dataSet.count),
    ///                         height: CGFloat(data.lines)),
    ///                     cornerRadius: 5)
    ///                 context.fill(path, with: .color(.blue))
    ///             }
    ///             // Draw Axis and Labels
    ///             ...
    ///         }
    ///         .accessibilityLabel("Lines of Code per Week")
    ///         .accessibilityChildren {
    ///             HStack {
    ///                 ForEach(dataSet) { data in
    ///                     RoundedRectangle(cornerRadius: 5)
    ///                         .accessibilityLabel("Week \(data.week)")
    ///                         .accessibilityValue("\(data.lines) lines")
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// OpenSwiftUI hides any views that you provide with the `children` parameter,
    /// then the framework uses the views to generate the accessibility elements.
    ///
    /// - Parameter children: A ``ViewBuilder`` that represents the replacement
    ///   child views the framework uses to generate accessibility elements.
    nonisolated public func accessibilityChildren<V>(
        @ViewBuilder children: () -> V
    ) -> some View where V: View {
        modifier(AccessibilityChildrenModifier(base: AccessibilityRepresentationModifier(representable: children())))
    }
}

// MARK: - AccessibilityRepresentableStyleModifier [FIXME]

private struct AccessibilityRepresentableStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .styleContext(.accessibilityRepresentable)
            .progressViewStyle(AccessibilityProgressViewStyle())
            // TODO: Apply Picker, List, Slider, Stepper, GroupBox, ControlGroup,
            // and Menu styles when their protocols and configurations are available.
    }
}

// MARK: - AccessibilityChildrenModifier

private struct AccessibilityChildrenModifier<Children>: PrimitiveViewModifier, MultiViewModifier where Children: View {
    var base: AccessibilityRepresentationModifier<Children>

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let originalOutputs = body(_Graph(), inputs)
        guard inputs.preferences.requiresAccessibilityNodes else {
            return originalOutputs
        }
        let bridgedNodes = originalOutputs.accessibilityNodes
        var outputs = AccessibilityRepresentationModifier<Children>._makeView(
            modifier: modifier[\.base],
            inputs: inputs,
            body: body
        )
        let container = _GraphValue(Attribute(value: AccessibilityContainerModifier(behavior: .contain)))
        outputs.accessibilityNodes = AccessibilityContainerModifier.makeAccessibilityTransform(
            modifier: container,
            inputs: inputs,
            outputs: outputs
        )
        let attachment = _GraphValue(BridgedAttachment(
            representedNodeList: .init(outputs.accessibilityNodes),
            bridgedNodeList: .init(bridgedNodes)
        ))
        outputs.accessibilityNodes = AccessibilityAttachmentModifier.makeAccessibilityPropertiesTransform(
            modifier: attachment,
            inputs: inputs,
            outputs: outputs
        )
        return outputs
    }

    struct BridgedAttachment: Rule {
        @OptionalAttribute var representedNodeList: AccessibilityNodeList?
        @OptionalAttribute var bridgedNodeList: AccessibilityNodeList?

        var value: AccessibilityAttachmentModifier {
            guard let representedNodeList, !representedNodeList.nodes.isEmpty,
                  let bridgedNodeList, bridgedNodeList.nodes.count == 1 else {
                return AccessibilityAttachmentModifier(AccessibilityProperties())
            }
            var properties = bridgedNodeList.nodes[0].properties
            properties.visibility = .init()
            return AccessibilityAttachmentModifier(properties)
        }
    }
}

// MARK: - AccessibilityToggleStyle

struct AccessibilityToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        AccessibilityControlStyle(label: configuration.label)
    }
}

// MARK: - AccessibilityLabeledContentStyle

struct AccessibilityLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            configuration.content
        }
    }
}

// MARK: - AccessibilityRepresentationModifier

private struct AccessibilityRepresentationModifier<Representation> where Representation: View {
    var representable: Representation

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        guard inputs.preferences.requiresAccessibilityNodes else {
            return outputs
        }
        let bridgedNodes = outputs.accessibilityNodes
        outputs = AccessibilityProxyModifier<Representation>._makeView(
            modifier: _GraphValue(ProxyModifier(representable: modifier[offset: { .of(&$0.representable) }].value)),
            inputs: inputs
        ) { _, _ in
            outputs
        }
        let attachment = _GraphValue(BridgedAttachment(
            representedNodeList: .init(outputs.accessibilityNodes),
            bridgedNodeList: .init(bridgedNodes)
        ))
        outputs.accessibilityNodes = AccessibilityAttachmentModifier.makeAccessibilityPropertiesTransform(
            modifier: attachment,
            inputs: inputs,
            outputs: outputs
        )
        return outputs
    }

    struct BridgedAttachment: Rule {
        @OptionalAttribute var representedNodeList: AccessibilityNodeList?
        @OptionalAttribute var bridgedNodeList: AccessibilityNodeList?

        var value: AccessibilityAttachmentModifier {
            var properties = AccessibilityProperties()
            if let representedNodeList, !representedNodeList.nodes.isEmpty,
               let bridgedNodeList, bridgedNodeList.nodes.count == 1 {
                let node = bridgedNodeList.nodes[0]
                properties.scrollableCollection = node.properties.scrollableCollection
                properties.scrollableContext = node.properties.scrollableContext
            }
            return AccessibilityAttachmentModifier(properties)
        }
    }

    struct ProxyModifier: Rule {
        @Attribute var representable: Representation

        var value: AccessibilityProxyModifier<Representation> {
            AccessibilityProxyModifier(representable)
        }
    }
}

extension AccessibilityRepresentationModifier: PrimitiveViewModifier, MultiViewModifier {}

// TODO: AccessibilityDisclosureGroupStyle requires DisclosureGroupStyleConfiguration.

// MARK: - AccessibilityLabelStyle

struct AccessibilityLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.title.accessibilityAttachment(content: configuration.icon) { tree in
            switch tree {
            case let .leaf(attachment):
                var properties = AccessibilityProperties()
                properties.images = attachment.properties.images
                tree = .leaf(.properties(properties))
            case .branch, .empty:
                tree = .empty
            }
        }
    }
}

// MARK: - AccessibilityButtonStyle

struct AccessibilityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        AccessibilityControlStyle(label: configuration.label)
    }
}

// MARK: - AccessibilityProxyModifier

private struct AccessibilityProxyModifier<Element>: ViewModifier where Element: View {
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    var element: Element

    init(_ element: Element) {
        self.element = element
    }

    func body(content: Content) -> some View {
        content
            .transformPreference(AccessibilityNodesKey.self) { $0 = AccessibilityNodesKey.defaultValue }
            .background {
                if accessibilityEnabled {
                    VStack { element }
                        .hiddenAllowingAccessibility()
                        .accessibilityRepresentationStyle()
                }
            }
            .modifier(GeometryTransformModifier())
    }

    struct GeometryTransformModifier: PrimitiveViewModifier, MultiViewModifier {
        nonisolated static func _makeView(
            modifier: _GraphValue<Self>,
            inputs: _ViewInputs,
            body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
        ) -> _ViewOutputs {
            var outputs = body(_Graph(), inputs)
            if inputs.preferences.requiresAccessibilityNodes {
                outputs.accessibilityNodes = makeAccessibilityGeometryTransform(
                    for: nil,
                    kind: nil,
                    inputs: inputs,
                    outputs: outputs
                )
            }
            return outputs
        }
    }
}

// MARK: - AccessibilityControlStyle

private struct AccessibilityControlStyle<Label>: View where Label: View {
    var label: Label

    var body: some View {
        // FIXME: accessibilityRemoveTraits
        var labelProperties = AccessibilityProperties()
        labelProperties.traits[.isLabel] = false
        var controlProperties = AccessibilityProperties(reserving: 4)
        controlProperties.traits[.isImage] = false
        controlProperties.traits[.isStaticText] = false
        controlProperties.visibility[.childrenIgnored] = true
        return Color.clear
            .overlay { label }
            .modifier(AccessibilityAttachmentModifier(labelProperties))
            .accessibilityIgnoreViewResponders()
            .modifier(AccessibilityAttachmentModifier(
                storage: MutableBox(.properties(controlProperties)),
                behavior: .combine
            ))
    }
}

// TODO: AccessibilityMenuStyle, AccessibilityControlGroupStyle, and
// AccessibilityGroupBoxStyle require their control style protocols and configurations.

// TODO: AccessibilityStepperStyle and AccessibilitySliderStyle require their
// current control style configurations.

// TODO: AccessibilityListStyle and AccessibilityPickerStyle require _ListValue,
// _PickerValue, ListStyleContent, PickerStyleConfiguration, and SelectionManager.

// MARK: - AccessibilityProgressViewStyle

struct AccessibilityProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            configuration.currentValueLabel
        }
    }
}
