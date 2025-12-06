//
//  Text+Renderer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: 7F70C8A76EE0356881289646072938C0 (SwiftUICore)

import OpenCoreGraphicsShims

// TODO

// MARK: - TextRendererBoxBase

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public class TextRendererBoxBase {
    let environment: EnvironmentValues

    init(environment: EnvironmentValues) {
        self.environment = environment
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func sizeThatFits(proposal: ProposedViewSize, text: TextProxy) -> CGSize {
        _openSwiftUIBaseClassAbstractMethod()
    }

    var displayPadding: EdgeInsets {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension TextRendererBoxBase: Sendable {}

// FIXME

extension Text {
    struct Layout {}
}

struct TextProxy {}
