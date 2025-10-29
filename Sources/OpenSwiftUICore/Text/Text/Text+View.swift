//
//  Text+View.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 641995D812913A47B866B20B88782376 (SwiftUICore)

// MARK: - Text + View [WIP]

@available(OpenSwiftUI_v1_0, *)
extension Text: UnaryView, PrimitiveView {
    public nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        // WIP
        return .init()
    }
}

package struct AccessibilityStyledTextContentView<Provider>: View where Provider: TextAccessibilityProvider {
    package var text: ResolvedStyledText

    package var unresolvedText: Text

    package var renderer: TextRendererBoxBase?

    package var needsDrawingGroup: Bool

    package init(
        text: ResolvedStyledText,
        unresolvedText: Text,
        renderer: TextRendererBoxBase? = nil,
        needsDrawingGroup: Bool = false
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    @MainActor
    @preconcurrency
    package var body: some View {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v1_0, *)
    package typealias Body = some View
}



// FIXME:
package class ResolvedStyledText {}

extension ResolvedStyledText {
    package class StringDrawing {}
}


private struct TextFilter {

}
