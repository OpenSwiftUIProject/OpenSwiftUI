//
//  TextFormatter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

public import Foundation
package import OpenAttributeGraphShims

// MARK: - ReferenceDate

@available(OpenSwiftUI_v1_0, *)
extension View {
    @_spi(OpenSwiftUIPrivate)
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func referenceDate(_ date: Date?) -> some View {
        modifier(ReferenceDateModifier(date: date))
    }
}

package struct ReferenceDateInput: ViewInput {
    package static var defaultValue: WeakAttribute<Date?> {
        .init()
    }
}

extension _GraphInputs {
    @inline(__always)
    package var referenceDate: WeakAttribute<Date?> {
        get { self[ReferenceDateInput.self] }
        set { self[ReferenceDateInput.self] = newValue }
    }
}

package struct ReferenceDateModifier: PrimitiveViewModifier, ViewInputsModifier {
    package var date: Date?

    nonisolated package static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.base.referenceDate = WeakAttribute(
            modifier.value.unsafeBitCast(to: Date?.self)
        )
    }
}
