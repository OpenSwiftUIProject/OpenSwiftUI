//
//  LabelGroup.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public struct LabelGroup<Content>: View where Content: View {
    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ResolvedLabelGroupStyle()
            .viewAlias(LabelGroupStyleConfiguration.Content.self) {
                content
            }
    }
}

@_spi(Private)
@available(*, unavailable)
extension LabelGroup: Sendable {}
