//
//  Text+Selection_iOS.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: ACB31533DB70E029184E072EF83FF254 (SwiftUI)

#if os(iOS) || os(visionOS)
import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - UIKitTextSelectionRepresentation

struct UIKitTextSelectionRepresentation: PlatformTextSelectionRepresentation {
    static func makeSelectableText(
        resolvedText: Attribute<ResolvedStyledText>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        makeSelectableTextChildView(
            inputs.textAccessibilityProvider,
            resolvedText: resolvedText,
            inputs: inputs
        )
    }

    static func makeSelectableTextChildView<P>(
        _: P.Type,
        resolvedText: Attribute<ResolvedStyledText>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where P: TextAccessibilityProvider {
        let query = Attribute(SelectableTextChildQuery<P>(resolvedText: resolvedText))
        return SelectableTextChildView<P>.makeDebuggableView(
            view: _GraphValue(query),
            inputs: inputs
        )
    }

    struct SelectableTextChildQuery<P>: Rule, AsyncAttribute where P: TextAccessibilityProvider {
        @Attribute var resolvedText: ResolvedStyledText

        var value: SelectableTextChildView<P> {
            SelectableTextChildView(text: resolvedText)
        }
    }
}

// MARK: - SelectableTextChildView

struct SelectableTextChildView<P>: View where P: TextAccessibilityProvider {
    var text: ResolvedStyledText

    @State var isSelecting = false

    var body: some View {
        AccessibilityStyledTextContentView<P>(
            text: text,
            unresolvedText: text.accessibilityText
        ).body
            .textSelectionMenu(text: text, isPresented: $isSelecting, anchor: .bounds)
            .gesture(TextSelectionGesture().callbacks(pressing: nil) {
                isSelecting = true
            })
    }
}

// MARK: - TextSelectionGesture

private struct TextSelectionGesture: Gesture {
    static let maximumDistance: CGFloat = 10

    var body: some Gesture<Bool> {
        let duration = EventListener<SpatialEvent>().duration(minimum: 0.5)
        let distance = DistanceGesture(maximumDistance: Self.maximumDistance)
            .coordinateSpace(.global)
        return EventListener<SpatialEvent>()
            .longPressPhase()
            .enabled(by: duration)
            .gated(by: distance)
            .eventFilter(forType: MouseEvent.self) { $0.button == .primary }
            .eventFilter(forType: SpatialEvent.self) { $0.kind != .pan }
            .dependency(.pausedUntilFailed)
    }
}
#endif
