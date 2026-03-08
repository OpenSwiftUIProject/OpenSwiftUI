//
//  WritingMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 82074A2E22E8635055FCB3A2D5E40280 (SwiftUICore)

@available(OpenSwiftUI_v1_0, *)
extension Text {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public struct WritingMode: Sendable, Hashable {
        @_spi(Private)
        package enum Storage {
            case horizontalTopToBottom
            case verticalRightToLeft
        }

        package var storage: Text.WritingMode.Storage

        public static let horizontalTopToBottom: Text.WritingMode = .init(storage: .horizontalTopToBottom)

        public static let verticalRightToLeft: Text.WritingMode = .init(storage: .verticalRightToLeft)
    }
}

private struct WritingModeKey: EnvironmentKey {
    static let defaultValue: Text.WritingMode = .horizontalTopToBottom
}

extension EnvironmentValues {
    package var writingMode: Text.WritingMode {
        get { self[WritingModeKey.self] }
        set { self[WritingModeKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v5_0, *)
extension View {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func writingMode(_ mode: Text.WritingMode) -> some View {
        environment(\.writingMode, mode)
    }
}

@_spi(Private)
extension Text.WritingMode: ProtobufEnum {
    package var protobufValue: UInt {
        switch storage {
        case .horizontalTopToBottom: 0
        case .verticalRightToLeft: 1
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 0: self = .horizontalTopToBottom
        case 1: self = .verticalRightToLeft
        default: return nil
        }
    }
}

//#if canImport(UIFoundation_Private)
//import UIFoundation_Private
//
//extension NSTextHorizontalAlignment {
//    package init(
//        _ alignment: TextAlignment,
//        layoutDirection: LayoutDirection,
//        writingMode: Text.WritingMode
//    ) {
//        _openSwiftUIUnimplementedFailure()
//    }
//
//    package init(in environment: EnvironmentValues) {
//        _openSwiftUIUnimplementedFailure()
//    }
//}
//
//#endif

//extension NSWritingDirection {
//    package init(_ layoutDirection: LayoutDirection) {
//
//    }
//}
