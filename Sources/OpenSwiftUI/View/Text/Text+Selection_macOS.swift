//
//  Text+Selection_macOS.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3295A461CF58C7D9B54CD05769AF1D5B (SwiftUI)

#if os(macOS)
import AppKit
import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AppKitTextSelectionRepresentation

struct AppKitTextSelectionRepresentation: PlatformTextSelectionRepresentation {
    static func makeSelectableText(
        resolvedText: Attribute<ResolvedStyledText>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let query = Attribute(SelectableTextChildQuery(resolvedText: resolvedText))
        return SelectableTextChildView.makeDebuggableView(
            view: _GraphValue(query),
            inputs: inputs
        )
    }

    struct SelectableTextChildQuery: Rule, AsyncAttribute {
        @Attribute var resolvedText: ResolvedStyledText

        var value: SelectableTextChildView {
            SelectableTextChildView(text: resolvedText)
        }
    }
}

// MARK: - SelectableTextChildView

struct SelectableTextChildView: View {
    var text: ResolvedStyledText

    @State var isSelecting = false

    var body: some View {
        StyledTextContentView(text: text)
            .opacity(isSelecting ? 0 : 1)
            .accessibilityDisabled()
            .overlay {
                GeometryReader { geometry in
                    SelectionOverlay(text: text, size: geometry.size, isSelecting: $isSelecting)
                        .textFieldScrollingDisabled()
                        .accessibilityConfiguration(AccessibilitySelectableTextModifier(configuration: .init(
                            label: text.accessibilityText,
                            layoutProperties: text.layoutProperties
                        )))
                }
            }
    }
}

// MARK: - SelectionOverlay

struct SelectionOverlay: NSViewRepresentable {
    var text: ResolvedStyledText
    var size: CGSize
    @Binding var isSelecting: Bool
    @Environment(\.allowsWindowActivationEvents) var acceptsFirstMouse: Bool?

    func makeNSView(context: Context) -> SelectionTextField {
        let view = SelectionTextField(wrappingLabelWithString: "")
        view.isSelectable = true
        view.allowsEditingTextAttributes = true
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: SelectionTextField, context: Context) {
        context.coordinator.overlay = self
        _ = nsView.update(in: context.environment, axis: .horizontal)
        let string = text.resolvedContent(
            in: ResolvableStringResolutionContext(environment: context.environment)
        )?.scaled(by: text.drawingScale(size: size))
        if let string, !string.string.isEmpty,
           let font = string.fontAttributes(in: NSRange(location: 0, length: 1))[.font] as? NSFont {
            nsView.font = font
        }
        if context.environment.lineLimit == 1 {
            nsView.cell?.usesSingleLineMode = true
            switch context.environment.truncationMode {
            case .head: nsView.lineBreakMode = .byTruncatingHead
            case .tail: nsView.lineBreakMode = .byTruncatingTail
            case .middle: nsView.lineBreakMode = .byTruncatingMiddle
            }
            nsView.attributedStringValue = string ?? NSAttributedString()
        } else {
            nsView.cell?.usesSingleLineMode = false
            nsView.lineBreakMode = .byWordWrapping
            nsView.attributedStringValue = (string ?? NSAttributedString()).replacingLineBreakModes(.byWordWrapping)
            nsView.cell?.truncatesLastVisibleLine = true
        }
        nsView.maximumNumberOfLines = context.environment.lineLimit ?? 0
        nsView.textInsets = text.layoutMargins
        nsView.openURL = context.environment.openURL
        nsView.customAcceptsFirstMouse = acceptsFirstMouse
    }

    func _resetNSView(_ nsView: SelectionTextField, coordinator: Coordinator, destroy: () -> Void) {
        if nsView.currentEditor() != nil {
            nsView.window?.endEditing(for: self)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(overlay: self)
    }

    class Coordinator: PlatformViewCoordinator, TextFieldSelectionDelegate {
        var overlay: SelectionOverlay

        init(overlay: SelectionOverlay) {
            self.overlay = overlay
            super.init()
        }

        func textFieldWillBeginSelection(_ textField: NSTextField) {
            Update.dispatchImmediately(reason: nil) {
                overlay.isSelecting = true
            }
        }

        func textFieldDidEndSelection(_ textField: NSTextField) {
            Update.dispatchImmediately(reason: nil) {
                overlay.isSelecting = false
            }
        }
    }
}

// MARK: - TextFieldSelectionDelegate

private protocol TextFieldSelectionDelegate: NSTextFieldDelegate {
    func textFieldWillBeginSelection(_ textField: NSTextField)
    func textFieldDidEndSelection(_ textField: NSTextField)
}

// MARK: - SelectionTextField

class SelectionTextField: NSTextField, AcceptsFirstMouseCustomizing {
    var textInsets: EdgeInsets = .zero
    var openURL: OpenURLAction?
    var customAcceptsFirstMouse: Bool?

    override init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        layerContentsRedrawPolicy = .never
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var cellClass: AnyClass? {
        get { Cell.self }
        set { _openSwiftUIEmptyStub() }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        if ResponderBasedHitTesting.isEnabled {
            customAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        } else {
            effectiveAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        }
    }

    override var alignmentRectInsets: NSEdgeInsets {
        var insets = super.alignmentRectInsets
        if alignment == .right {
            insets.left = 4
            insets.right = 4
        }
        return insets
    }

    override func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: UInt) -> Bool {
        guard let openURL, let url = link as? URL else {
            return false
        }
        openURL(url)
        return true
    }

    override func draw(_ dirtyRect: CGRect) {
        _openSwiftUIEmptyStub()
    }

    override func updateLayer() {
        _openSwiftUIEmptyStub()
    }

    override var wantsUpdateLayer: Bool { true }

    override func makeBackingLayer() -> CALayer {
        CALayer()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        size
    }

    override func _performMultiPassIntrinsicSize() -> Bool {
        false
    }

    override func accessibilityValue() -> String? {
        nil
    }

    class Cell: NSTextFieldCell {
        override func setUpFieldEditorAttributes(_ textObject: NSText) -> NSText {
            let editor = super.setUpFieldEditorAttributes(textObject)
            if let textView = editor as? NSTextView {
                var attributes = textView.linkTextAttributes ?? [:]
                attributes.removeValue(forKey: .foregroundColor)
                textView.linkTextAttributes = attributes
            }
            return editor
        }

        override func endEditing(_ textObject: NSText) {
            super.endEditing(textObject)
            if let textField = controlView as? NSTextField,
               let delegate = textField.delegate as? TextFieldSelectionDelegate {
                delegate.textFieldDidEndSelection(textField)
            }
        }

        override func _selectOrEdit(
            _ frame: UnsafePointer<CGRect>,
            in controlView: NSView?,
            target: Any?,
            editor: NSText?,
            event: NSEvent?,
            start: Int,
            end: Int
        ) -> Any? {
            if let textField = controlView as? NSTextField,
               let delegate = textField.delegate as? TextFieldSelectionDelegate {
                delegate.textFieldWillBeginSelection(textField)
            }
            var frame = frame.pointee
            if let textField = controlView as? SelectionTextField {
                frame = frame.insetBy(dx: textField.textInsets.leading, dy: textField.textInsets.top)
            }
            return super._selectOrEdit(
                &frame, in: controlView, target: target, editor: editor, event: event, start: start, end: end
            )
        }
    }
}
#endif
