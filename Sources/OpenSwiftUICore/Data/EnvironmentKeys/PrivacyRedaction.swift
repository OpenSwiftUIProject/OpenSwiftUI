//
//  PrivacyRedaction.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7799685610985DBA9248562F2E4D5E6E (SwiftUICore)

import OpenAttributeGraphShims
import OpenCoreGraphicsShims

// MARK: - PrivacyRedactionViewModifier

private struct PrivacyRedactionViewModifier: ViewModifier {
    var sensitive: Bool

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let reasons = inputs.redactionReasons
        let sensitive = modifier.unsafeBitCast(to: Bool.self).value
        if inputs.hasWidgetMetadata {
            let child = Attribute(
                WidgetAuxiliaryChild(sensitive: sensitive, redactionReasons: reasons)
            )
            return WidgetAuxiliaryChild.Value._makeView(
                modifier: .init(child),
                inputs: inputs,
                body: body
            )
        } else {
            let provider = inputs.privacyReductionAccessibilityProvider
            return makeChild(
                modifier: modifier,
                type: provider,
                body: body,
                sensitive: sensitive,
                inputs: inputs,
                reasons: reasons
            )
        }
    }

    nonisolated static func makeChild<Provider>(
        modifier: _GraphValue<Self>,
        type: Provider.Type,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs,
        sensitive: Attribute<Bool>,
        inputs: _ViewInputs,
        reasons: Attribute<RedactionReasons>
    ) -> _ViewOutputs where Provider: PrivacyReductionAccessibilityProvider {
        let child = Attribute(
            Child<Provider>(sensitive: sensitive, redactionReasons: reasons)
        )
        return Child<Provider>.Value.makeDebuggableView(
            modifier: .init(child),
            inputs: inputs,
            body: body
        )
    }

    struct Child<Provider>: Rule where Provider: PrivacyReductionAccessibilityProvider {
        @Attribute var sensitive: Bool
        @Attribute var redactionReasons: RedactionReasons

        var value: some ViewModifier {
            Transform<Provider>(sensitive: sensitive, redactionReasons: redactionReasons)
        }
    }

    struct Transform<Provider>: ViewModifier where Provider: PrivacyReductionAccessibilityProvider {
        var sensitive: Bool
        var redactionReasons: RedactionReasons

        @inline(__always)
        private var shouldRedact: Bool {
            redactionReasons.contains(.privacy) && sensitive
        }

        func body(content: Content) -> some View {
            content
                .unredacted()
                .modifier(
                    PrivacyEffect(
                        sensitive: sensitive,
                        shouldRedact: shouldRedact,
                        hideForScreencapture: redactionReasons.contains(.screencaptureProhibited)
                    )
                )
                .opacity(shouldRedact ? 0 : 1)
                .modifier(Provider.makeModifier(shouldRedact: shouldRedact))
                .overlay {
                    if shouldRedact {
                        content
                            .environment(\.redactionReasons, .privacy)
                            .environment(\.sensitiveContent, sensitive)
                            .transition(.opacity)
                    }
                }
        }

        struct PrivacyEffect: RendererEffect {
            var sensitive: Bool
            var shouldRedact: Bool
            var hideForScreencapture: Bool

            func effectValue(size: CGSize) -> DisplayList.Effect {
                var properties: DisplayList.Properties = []
                if sensitive {
                    properties.formUnion(.privacySensitive)
                }
                if sensitive {
                    properties.formUnion(.screencaptureProhibited)
                }
                return .properties(properties)
            }

            static var isScrapeable: Bool { true }

            var scrapeableContent: ScrapeableContent.Content? {
                guard shouldRedact, hideForScreencapture else {
                    return nil
                }
                return .hidden
            }
        }
    }

    struct WidgetAuxiliaryChild: Rule {
        @Attribute var sensitive: Bool
        @Attribute var redactionReasons: RedactionReasons

        var value: some ViewModifier {
            let reasons: RedactionReasons = if redactionReasons.contains(.privacy), sensitive {
                .privacy
            } else {
                redactionReasons
            }
            return ModifiedContent(
                content: _EnvironmentKeyWritingModifier(
                    keyPath: \.redactionReasons,
                    value: reasons
                ),
                modifier: _EnvironmentKeyWritingModifier(
                    keyPath: \.sensitiveContent,
                    value: sensitive
                )
            )
        }
    }
}

// MARK: - View + privacySensitive

@available(OpenSwiftUI_v3_0, *)
extension View {

    /// Marks the view as containing sensitive, private user data.
    ///
    /// OpenSwiftUI redacts views marked with this modifier when you apply the
    /// ``RedactionReasons/privacy`` redaction reason.
    ///
    ///     struct BankAccountView: View {
    ///         var body: some View {
    ///             VStack {
    ///                 Text("Account #")
    ///
    ///                 Text(accountNumber)
    ///                     .font(.headline)
    ///                     .privacySensitive() // Hide only the account number.
    ///             }
    ///         }
    ///     }
    nonisolated public func privacySensitive(_ sensitive: Bool = true) -> some View {
        modifier(PrivacyRedactionViewModifier(sensitive: sensitive))
    }
}

// MARK: - PrivacyReductionAccessibilityProvider

package protocol PrivacyReductionAccessibilityProvider {
    associatedtype Modifier: ViewModifier

    static func makeModifier(shouldRedact: Bool) -> Modifier
}

extension _GraphInputs {
    private struct PrivacyReductionAccessibilityProviderKey: GraphInput {
        static let defaultValue: (any PrivacyReductionAccessibilityProvider.Type) = EmptyPrivacyReductionAccessibilityProvider.self
    }

    package var privacyReductionAccessibilityProvider: (any PrivacyReductionAccessibilityProvider.Type) {
        get { self[PrivacyReductionAccessibilityProviderKey.self] }
        set { self[PrivacyReductionAccessibilityProviderKey.self] = newValue }
    }
}

extension _ViewInputs {
    package var privacyReductionAccessibilityProvider: (any PrivacyReductionAccessibilityProvider.Type) {
        get { base.privacyReductionAccessibilityProvider }
        set { base.privacyReductionAccessibilityProvider = newValue }
    }
}

struct EmptyPrivacyReductionAccessibilityProvider: PrivacyReductionAccessibilityProvider {
    static func makeModifier(shouldRedact: Bool) -> some ViewModifier {
        EmptyModifier()
    }
}

// MARK: - EnvironmentValues + sensitiveContent

private struct SensitiveContentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    package var sensitiveContent: Bool {
        get { self[SensitiveContentKey.self] }
        set { self[SensitiveContentKey.self] = newValue }
    }
}
