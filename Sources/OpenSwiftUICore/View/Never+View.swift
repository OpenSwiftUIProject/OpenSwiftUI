//
//  Never+View.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

// MARK: - Never + View

#if !(OPENSWIFTUI_LVGL && hasFeature(Embedded)) && canImport(CoreTransferable)
public import CoreTransferable
#endif

@available(OpenSwiftUI_v1_0, *)
extension Never: View {
    #if (OPENSWIFTUI_LVGL && hasFeature(Embedded)) || !canImport(CoreTransferable)
    public typealias Body = Never

    public var body: Never { self }
    #endif

    #if OPENSWIFTUI_LVGL && hasFeature(Embedded)
    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize { switch self {} }
    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        switch self {}
    }
    #else
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs _: _ViewListCountInputs) -> Int? {
        nil
    }
    #endif
}
