//
//  LabelGroupStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: D603B70BAAC92B7EC91530E54167B115 (SwiftUI)

// MARK: - LabelGroupStyle_v0

@_spi(UIFrameworks)
@available(OpenSwiftUI_v6_0, *)
public protocol LabelGroupStyle_v0 {
    associatedtype Foreground: ShapeStyle = HierarchicalShapeStyle

    func font(at level: Int) -> Font

    func foregroundStyle(at level: Int) -> Self.Foreground
}

// MARK: - View + labelGroupStyle_v0

@_spi(UIFrameworks)
@available(OpenSwiftUI_v6_0, *)
extension View {
    nonisolated public func labelGroupStyle_v0(_ style: some LabelGroupStyle_v0) -> some View {
        modifier(LabelGroupStyleModifier(style: style))
    }
}

// MARK: - LabelGroupStyleConfiguration

struct LabelGroupStyleConfiguration {
    struct Content: ViewAlias {}

    let content: Content
}

// MARK: - LabelGroupStyleModifier

struct LabelGroupStyleModifier<S>: StyleModifier where S: LabelGroupStyle_v0 {
    var style: S

    init(style: S) {
        self.style = style
    }

    func styleBody(configuration: LabelGroupStyleConfiguration) -> some View {
        _VariadicView.Tree(StyleApplicator(style: style)) {
            configuration.content
        }
    }
}

// MARK: - ResolvedLabelGroupStyle

struct ResolvedLabelGroupStyle: StyleableView {
    static let defaultStyleModifier: LabelGroupStyleModifier<BodyLabelGroupStyle> = .init(style: .init())

    var configuration: LabelGroupStyleConfiguration { .init(content: .init()) }
}

// MARK: - StyleApplicator [WIP]

private struct StyleApplicator<S>: _VariadicView.MultiViewRoot where S: LabelGroupStyle_v0 {

    struct EnumeratedView {
        var view: _VariadicView.Children.Element
        var offset: Int
    }

    var style: S

    func body(children: _VariadicView.Children) -> some View {
        ForEach(
            children.enumerated().map { EnumeratedView(view: $0.element, offset: $0.offset) },
            id: \.view.id
        ) { view in
            view.view
            // defaultForegroundStyle
            // font
            // platformItem
        }
    }
}
