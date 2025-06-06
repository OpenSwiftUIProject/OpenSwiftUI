//
//  Never+View.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

// MARK: - Never + View

#if canImport(CoreTransferable)
import CoreTransferable
#endif

@available(OpenSwiftUI_v1_0, *)
extension Never: View {
    #if !canImport(CoreTransferable)
    public var body: Never { self }
    #endif

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs _: _ViewListCountInputs) -> Int? {
        nil
    }
}
