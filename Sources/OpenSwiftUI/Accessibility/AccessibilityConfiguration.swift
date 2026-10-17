//
//  AccessibilityConfiguration.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 0D3243EDC3DD4D641848661DCC354D4B (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - AccessibilityConfigurationModifier

protocol AccessibilityConfigurationModifier {
    associatedtype Configuration = Never
    associatedtype Body
    associatedtype Content

    var configuration: Configuration { get }
    func body(content: Self.Content) -> Self.Body
}

extension AccessibilityConfigurationModifier where Configuration == Never {
    var configuration: Configuration { _openSwiftUIBaseClassAbstractMethod() }
}

// MARK: - AccessibilityTraitsModifier

struct AccessibilityTraitsModifier<Content: View>: AccessibilityConfigurationModifier {
    var traits: AccessibilityTraitSet

    init(traits: AccessibilityTraitSet) {
        self.traits = traits
    }

    func body(content: Content) -> some View {
        content
            .accessibilityCaptureViewResponders()
            .modifier(ChildModifier(traits: traits))
            .accessibilityIgnoreViewResponders()
    }

    private struct ChildModifier: AccessibilityViewModifier {
        var traits: AccessibilityTraitSet

        static var options: AccessibilityModifierOptions { [] }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            false
        }

        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            AccessibilityAttachment()
        }

        func updatedAttachment(
            for token: AccessibilityAttachmentToken,
            nodes: [AccessibilityNode],
            atIndex index: Int
        ) -> AccessibilityAttachment {
            guard index == 0 else {
                return .properties(AccessibilityProperties())
            }
            return .properties(AccessibilityProperties(
                AccessibilityProperties.TraitsKey.self,
                .init(implying: traits)
            ))
        }

        func createOrUpdateNode(
            viewRendererHost: (any ViewRendererHost)?,
            existingNode: AccessibilityNode?
        ) -> AccessibilityNode {
            existingNode ?? AccessibilityNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
        }

        static func makeAccessibilityViewModifier(
            modifier: _GraphValue<Self>,
            inputs: _ViewInputs,
            body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
        ) -> _ViewOutputs {
            body(_Graph(), inputs)
        }

        var supportsPlaceholders: Bool { false }
    }
}

// MARK: - AccessibilityLabelModifier

struct AccessibilityLabelModifier<Content: View>: AccessibilityConfigurationModifier {
    init() {
        _openSwiftUIEmptyStub()
    }

    func body(content: Content) -> some View {
        content
            .accessibilityCaptureViewResponders()
            .modifier(ChildModifier())
            .accessibilityIgnoreViewResponders()
    }

    private struct ChildModifier: AccessibilityViewModifier {
        let properties: AccessibilityProperties

        init() {
            properties = AccessibilityProperties(
                AccessibilityProperties.TraitsKey.self,
                .init(adding: .isLabel)
            )
        }

        static var options: AccessibilityModifierOptions { [] }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            false
        }

        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            AccessibilityAttachment()
        }

        func updatedAttachment(
            for token: AccessibilityAttachmentToken,
            nodes: [AccessibilityNode],
            atIndex index: Int
        ) -> AccessibilityAttachment {
            .properties(properties)
        }

        func createOrUpdateNode(
            viewRendererHost: (any ViewRendererHost)?,
            existingNode: AccessibilityNode?
        ) -> AccessibilityNode {
            existingNode ?? AccessibilityNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
        }

        static func makeAccessibilityViewModifier(
            modifier: _GraphValue<Self>,
            inputs: _ViewInputs,
            body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
        ) -> _ViewOutputs {
            body(_Graph(), inputs)
        }

        var supportsPlaceholders: Bool { false }
    }
}

// TODO: AccessibilityStepperModifier

// MARK: - AccessibilityAdjustableModifier

struct AccessibilityAdjustableModifier<Content, Value>: AccessibilityConfigurationModifier where Content: View, Value: AccessibilityValue, Value: Codable {
    struct Configuration {
        var value: Value?

        var continuous: Bool

        var onIncrement: (() -> Void)?

        var onDecrement: (() -> Void)?

        var onSet: (AccessibilityNumber) -> Void

        var onEditingChanged: (Bool) -> Void
    }

    var configuration: Configuration

    func body(content: Content) -> some View {
        var view = content.accessibilityAction(
            AccessibilityAdjustableAction(continuous: configuration.continuous)
        ) { direction -> AccessibilityActionResult in
            configuration.onEditingChanged(true)
            switch direction {
            case .increment: configuration.onIncrement?()
            case .decrement: configuration.onDecrement?()
            }
            configuration.onEditingChanged(false)
            return .success
        }
        if let value = configuration.value {
            view = view
                .accessibilityValue(AccessibilityValueStorage(value))
                .accessibilitySetValueAction { number in
                    configuration.onEditingChanged(true)
                    configuration.onSet(number)
                    configuration.onEditingChanged(false)
                }
        }
        return view
    }
}

// TODO: AccessibilityNavigationLinkButtonModifier
// TODO: AccessibilityNavigationLinkButtonModifier.Representable
// TODO: AccessibilityLinkModifier
// TODO: AccessibilityLinkModifier.Configuration

// MARK: - AccessibilitySliderModifier

struct AccessibilitySliderModifier<Content>: AccessibilityConfigurationModifier where Content: View {
    var base: AccessibilityAdjustableModifier<Content, AccessibilitySliderValue>

    init(_ configuration: SliderStyleConfiguration, value: AccessibilityBoundedNumber?) {
        base = AccessibilityAdjustableModifier(configuration: .init(
            value: value.map { AccessibilitySliderValue($0) },
            continuous: true,
            onIncrement: {
                configuration.value = (configuration.value + configuration.skipDistance).clamped(to: 0 ... 1)
            },
            onDecrement: {
                configuration.value = (configuration.value - configuration.skipDistance).clamped(to: 0 ... 1)
            },
            onSet: { number in
                guard let value,
                      let minValue = value.minValue?.doubleValue,
                      let maxValue = value.maxValue?.doubleValue else {
                    return
                }
                var newValue = number.value.doubleValue
                if let step = value.step {
                    newValue.round(.toNearestOrAwayFromZero, toMultipleOf: step.doubleValue)
                }
                configuration.value = (newValue - minValue) / (maxValue - minValue)
            },
            onEditingChanged: configuration.onEditingChanged
        ))
    }

    func body(content: Content) -> some View {
        base.body(content: content)
    }
}

// TODO: AccessibilityGroupBoxLabelModifier
// TODO: AccessibilityGroupBoxContentModifier
// TODO: AccessibilityDisclosureModifier
// TODO: AccessibilityTableCellModifier
// TODO: AccessibilityListCoreCellModifier
// TODO: AccessibilityButtonModifier.Attachment
// TODO: AccessibilityDefaultActionRepresentableConfiguration
// TODO: AccessibilityNavigationLinkButtonModifier.Attachment

// MARK: - AccessibilityToggleModifier

struct AccessibilityToggleModifier<Content: View>: AccessibilityConfigurationModifier {
    var configuration: ToggleStyleConfiguration

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .modifier(MacDefaultModifier(configuration: configuration))
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(AccessibilityValueStorage(AccessibilityToggleValue(configuration.toggleState), description: .empty))
        #else
        content
            .accessibilityCombinedElement(options: [.allActionsCustom, .includeHiddenChild], ignoredTraits: [.isImage, .isStaticText])
            .accessibilityActions(configuration.accessibilityActions)
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(AccessibilityValueStorage(AccessibilityToggleValue(configuration.toggleState), description: .empty))
            .staticIf(StyleContextAcceptsPredicate<AccessibilityRepresentableStyleContext>.self) {
                $0.modifier(RepresentationModifier(label: configuration.label, intent: configuration.appIntent))
            }
        #endif
    }

    #if os(macOS)
    private struct MacDefaultModifier: ViewModifier {
        var configuration: ToggleStyleConfiguration

        func body(content: MacDefaultModifier.Content) -> some View {
            StaticIf(StyleContextAcceptsPredicate<GroupedFormStyleContext>.Inverted.self) {
                content
                    .accessibilityCombinedElement(
                        options: [.reuseLabelNodes, .allActionsCustom, .includeHiddenChild],
                        ignoredTraits: [.isImage, .isStaticText]
                    )
                    .accessibilityActions(configuration.accessibilityActions)
                    .staticIf(StyleContextAcceptsPredicate<AccessibilityRepresentableStyleContext>.self) {
                        $0.modifier(RepresentationModifier(label: configuration.label, intent: configuration.appIntent))
                    }
            } else: {
                content.accessibilityCombinedElement(
                    options: [.reuseLabelNodes, .includeHiddenChild],
                    ignoredTraits: [.isImage, .isStaticText]
                )
            }
        }
    }
    #endif

    private struct RepresentationModifier<Label: View>: ViewModifier {
        var label: Label
        var intent: AppIntentAction?

        func body(content: RepresentationModifier.Content) -> some View {
            content.accessibilityAttachment(content: label) { tree in
                guard let intent else { return }
                let properties = tree.attachment?.properties
                let action = AnyAccessibilityAction(AccessibilityAppIntentHandler(
                    action: AccessibilityAppIntentAction(kind: .default, intent: intent),
                    category: nil,
                    label: properties?.labelStorage?.texts.first,
                    image: properties?.images.first,
                    supportsEncoding: true
                ), bridged: true)
                tree = .leaf(AccessibilityAttachment(properties: AccessibilityProperties(
                    AccessibilityProperties.ActionsKey.self, [action]
                )))
            }
        }
    }

    #if os(macOS)
    struct Radio: AccessibilityConfigurationModifier {
        struct Configuration {
            var isSelected: ToggleState
        }

        var configuration: Configuration

        init(_ state: ToggleState) {
            configuration = Configuration(isSelected: state)
        }

        func body(content: Content) -> some View {
            content
                .accessibilityCaptureViewResponders()
                .accessibilityAddTraits(.isRadioButton)
                .accessibilityAddTraits(configuration.isSelected == .on ? .isSelected : [])
                .accessibilityValue(AccessibilityToggleValue(configuration.isSelected))
                .accessibilityIgnoreViewResponders()
        }
    }
    #endif
}

// MARK: - ToggleStyleConfiguration + Accessibility

extension ToggleStyleConfiguration {
    fileprivate var appIntent: AppIntentAction? {
        switch effect {
        case let .appIntent(action): action
        case .binding: nil
        }
    }

    fileprivate var accessibilityActions: [AnyAccessibilityAction] {
        switch effect {
        case let .appIntent(action):
            [AnyAccessibilityAction(AccessibilityAppIntentHandler(
                action: AccessibilityAppIntentAction(kind: .default, intent: action),
                category: nil,
                label: nil,
                image: nil,
                supportsEncoding: false
            ), bridged: true)]
        case .binding:
            [AnyAccessibilityAction(action: AccessibilityVoidAction(kind: .default), label: nil, image: nil, handler: {
                isOn.toggle()
                return .success
            }, bridged: false)]
        }
    }
}

// TODO: AccessibilityButtonModifier
// TODO: AccessibilityButtonModifier.Representable
// TODO: AccessibilityBadgedViewNeedsValue
// TODO: AccessibilityNavigationLinkButtonModifier.Configuration
// TODO: AccessibilityBadgedViewProvidesOwnValue
// TODO: AccessibilityGaugeModifier
// TODO: AccessibilitySidebarListModifier
// TODO: AccessibilityButtonModifier.Configuration
// TODO: AccessibilityDisclosureModifier.Configuration
// TODO: AccessibilityDisclosureModifier.List
// TODO: AccessibilityPlaybackButtonModifier.Configuration
// TODO: AccessibilityPlaybackButtonModifier
// TODO: AccessibilityPlaybackButtonModifier.ValueStyle
// TODO: AccessibilityImageModifier.Configuration
// TODO: AccessibilityImageModifier
// TODO: AccessibilityStaticTextModifier.Configuration
// TODO: AccessibilityStaticTextModifier

// MARK: - AccessibilitySelectableTextModifier [TBA]

struct AccessibilitySelectableTextModifier<Content: View>: AccessibilityConfigurationModifier {
    struct Configuration {
        var label: Text
        var layoutProperties: TextLayoutProperties
    }

    var configuration: Configuration

    func body(content: Content) -> some View {
        content
            .accessibility(AccessibilityProperties.LabelKey.self, .init(texts: [configuration.label]))
            .update(AccessibilityProperties.TextLayoutPropertiesKey.self, replacing: .custom(configuration.layoutProperties))
    }
}

// TODO: AccessibilityDisclosureModifier.List.Configuration
// TODO: AccessibilityGaugeModifier.Configuration
// TODO: AccessibilityBadgedViewModifier.Badge
// TODO: AccessibilityBadgedViewModifier
// TODO: AccessibilityBadgedViewModifier.Configuration

// MARK: - View + AccessibilityConfiguration

extension View {
    func accessibilityConfiguration<M>(_ modifier: M) -> M.Body where M: AccessibilityConfigurationModifier, M.Content == Self, M.Body: View {
        modifier.body(content: self)
    }
}
