//
//  TruncationMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

@available(OpenSwiftUI_v1_0, *)
extension Text {

    /// The type of truncation to apply to a line of text when it's too long to
    /// fit in the available space.
    ///
    /// When a text view contains more text than it's able to display, the view
    /// might truncate the text and place an ellipsis (...) at the truncation
    /// point. Use the ``View/truncationMode(_:)`` modifier with one of the
    /// `TruncationMode` values to indicate which part of the text to
    /// truncate, either at the beginning, in the middle, or at the end.
    public enum TruncationMode: Sendable {

        /// Truncate at the beginning of the line.
        ///
        /// Use this kind of truncation to omit characters from the beginning of
        /// the string. For example, you could truncate the English alphabet as
        /// "...wxyz".
        case head

        /// Truncate at the end of the line.
        ///
        /// Use this kind of truncation to omit characters from the end of the
        /// string. For example, you could truncate the English alphabet as
        /// "abcd...".
        case tail

        /// Truncate in the middle of the line.
        ///
        /// Use this kind of truncation to omit characters from the middle of
        /// the string. For example, you could truncate the English alphabet as
        /// "ab...yz".
        case middle
    }

    /// A scheme for transforming the capitalization of characters within text.
    @available(OpenSwiftUI_v2_0, *)
    public enum Case: Sendable {

        /// Displays text in all uppercase characters.
        ///
        /// For example, "Hello" would be displayed as "HELLO".
        ///
        /// - SeeAlso: `StringProtocol.uppercased(with:)`
        case uppercase

        /// Displays text in all lowercase characters.
        ///
        /// For example, "Hello" would be displayed as "hello".
        ///
        /// - SeeAlso: `StringProtocol.lowercased(with:)`
        case lowercase
    }
}

extension Text.TruncationMode: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .head: 1
        case .tail: 2
        case .middle: 3
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 1: self = .head
        case 2: self = .tail
        case 3: self = .middle
        default: return nil
        }
    }
}
