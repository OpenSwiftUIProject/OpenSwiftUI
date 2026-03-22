//
//  Never+View.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

// MARK: - Never + View

#if canImport(CoreTransferable)
public import CoreTransferable
#endif

@available(OpenSwiftUI_v1_0, *)
extension Never: View {
    #if !canImport(CoreTransferable)
    public typealias Body = Never

    public var body: Never { self }
    #endif

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs _: _ViewListCountInputs) -> Int? {
        nil
    }
}
